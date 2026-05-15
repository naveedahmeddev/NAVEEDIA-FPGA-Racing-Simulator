`timescale 1ns / 1ps

module racing_display (
    input wire clk_25MHz,
    input wire reset,
    input wire quadA,       
    input wire quadB,      
    input wire signed [3:0] current_gear,
    input wire [24:0] target_speed_delay,
    output wire h_sync,
    output wire v_sync,
    output reg [11:0] rgb
);

    localparam [24:0] STOP_DELAY      = 25_000_000;
    localparam [15:0] TARGET_DISTANCE = 16'd1900;

    // --- CHANGED: Huge 128x128 Car, placed properly so it doesn't clip the bottom
    localparam [9:0] CAR_Y = 10'd352; 
    localparam [9:0] CAR_W = 10'd128;
    localparam [9:0] CAR_H = 10'd128;

    wire [9:0] x, y;
    wire video_on;
    wire text_white, text_black;

    vga_controller vga_inst (
        .clk(clk_25MHz), .reset(reset),
        .h_sync(h_sync), .v_sync(v_sync),
        .video_on(video_on), .p_tick(), .x(x), .y(y)
    );

    reg [15:0] timer_count;
    reg game_over, game_won, game_started;
    reg [24:0] tick_reg, road_speed_counter;
    reg [15:0] distance_count, road_scroll;
    reg [31:0] distance_accum;
    reg [8:0]  speed_val;

    wire [9:0] car_x;
    quadrature_decoder encoder_inst (
        .clk(clk_25MHz), .reset(reset || game_over), 
        .quadA(quadA), .quadB(quadB), .position(car_x)
    );

    wire [9:0] obj_y;
    wire obj_active, obj_is_coin;
    wire [2:0] obj_lane; 

    object_logic obj_unit (
        .clk_25MHz(clk_25MHz), .reset(reset),
        .game_over(game_over), .game_started(game_started),
        .speed_val(speed_val), .current_gear(current_gear),
        .obj_y(obj_y), .obj_active(obj_active), .obj_is_coin(obj_is_coin),
        .obj_lane(obj_lane)
    );

    // --- CHANGED: Thinner Horizon (Base width dropped to 15) ---
    wire [9:0] road_hw_at_obj = (obj_y >= 10'd100) ? (10'd15 + (((obj_y - 10'd100) * 3) >> 2)) : 10'd15;
    wire [9:0] lane_offset    = road_hw_at_obj >> 1; 

    wire [9:0] obj_x = (obj_lane == 0) ? (320 - road_hw_at_obj + 10) : 
                       (obj_lane == 1) ? (320 - lane_offset) :         
                       (obj_lane == 2) ? (320) :                       
                       (obj_lane == 3) ? (320 + lane_offset) :         
                                         (320 + road_hw_at_obj - 10);  

    wire [1:0] obj_scale_mode = (obj_y < 10'd160) ? 2'd0 : (obj_y < 10'd260) ? 2'd1 : 2'd2;
    wire [9:0] obj_size = (obj_scale_mode == 2'd0) ? 10'd16 : (obj_scale_mode == 2'd1) ? 10'd32 : 10'd64;
    wire [9:0] obj_half = obj_size >> 1;

    wire [9:0] obj_left   = obj_x - obj_half;
    wire [9:0] obj_right  = obj_x + obj_half;
    wire [9:0] obj_top    = obj_y;
    wire [9:0] obj_bottom = obj_y + obj_size;

    reg [9:0] obj_rom_addr;
    always @(*) begin
        case (obj_scale_mode)
            2'd0: obj_rom_addr = ((x - obj_left) << 1) + (((y - obj_top) << 1) << 5);
            2'd1: obj_rom_addr = (x - obj_left) + ((y - obj_top) << 5);
            default: obj_rom_addr = ((x - obj_left) >> 1) + (((y - obj_top) >> 1) << 5);
        endcase
    end

    wire [11:0] car_pixel, coin_pixel, obs_pixel;
    
    // --- CHANGED: Perfect 4x Scaling (>> 2) to eliminate blur on the 128x128 car ---
    racing_car_sprite_rom rom_car (.addr(((x - (car_x - 64)) >> 2) + (((y - CAR_Y) >> 2) << 5)), .data(car_pixel));
    
    reward_coin_sprite_rom rom_coin (.addr(obj_rom_addr), .data(coin_pixel));
    collision_car_sprite_3_rom rom_obs (.addr(obj_rom_addr), .data(obs_pixel));

    always @(posedge clk_25MHz) begin
        if (reset) begin
            road_scroll <= 0; road_speed_counter <= 0;
        end else if (game_started && !game_over) begin
            if (target_speed_delay != STOP_DELAY) begin
                road_speed_counter <= road_speed_counter + 1;
                if (road_speed_counter >= target_speed_delay) begin
                    road_speed_counter <= 0;
                    if (current_gear < 0) road_scroll <= road_scroll - 1; 
                    else                  road_scroll <= road_scroll + 1; 
                end
            end
        end
    end

    // --- CHANGED: Bounding Box updated to match the massive 128-width car ---
    wire [9:0] car_left   = car_x - 64;
    wire [9:0] car_right  = car_x + 64;
    wire [9:0] car_top    = CAR_Y;
    wire [9:0] car_bottom = CAR_Y + CAR_H;

    wire bbox_overlap = obj_active && (car_right > obj_left) && (car_left < obj_right) && 
                        (car_bottom > obj_top) && (car_top < obj_bottom);

    wire coin_hit     = bbox_overlap &&  obj_is_coin;
    wire obstacle_hit = bbox_overlap && !obj_is_coin;
    reg collision_done;

    always @(posedge clk_25MHz) begin
        if (reset) begin
            timer_count    <= 60; game_over      <= 0; game_won       <= 0;
            tick_reg       <= 0;  game_started   <= 0; distance_count <= 0;
            distance_accum <= 0;  collision_done <= 0;
        end else begin
            if (current_gear >= 1 || current_gear < 0) game_started <= 1;

            if (game_started && !game_over) begin
                if ((coin_hit || obstacle_hit) && !collision_done) begin
                    collision_done <= 1;
                    if (coin_hit) timer_count <= (timer_count > 55) ? 60 : timer_count + 5;
                    else          timer_count <= (timer_count < 5) ? 0 : timer_count - 5;
                end
                if (!obj_active) collision_done <= 0;

                tick_reg <= tick_reg + 1;
                if (tick_reg == 25_000_000) begin
                    tick_reg <= 0;
                    if (timer_count > 0) timer_count <= timer_count - 1;
                    if (current_gear > 0) begin
                        distance_accum <= distance_accum + ((speed_val * 5 * 32'd65536) / 18);
                        distance_count <= distance_accum[31:16];
                    end
                end

                if (timer_count == 0) begin game_over <= 1; game_won <= 0; end
                if (distance_count >= TARGET_DISTANCE) begin game_over <= 1; game_won <= 1; end
            end
        end
    end

    reg [8:0] max_speed, desired_speed;
    always @* begin
        case ((current_gear < 0) ? -current_gear : current_gear)
            4'd1: max_speed = 30; 4'd2: max_speed = 50; 4'd3: max_speed = 70;
            4'd4: max_speed = 95; 4'd5: max_speed = 120; default: max_speed = 0;
        endcase
        if (current_gear < 0) max_speed = 20;
        desired_speed = (target_speed_delay >= STOP_DELAY) ? 0 : max_speed;
    end

    always @(posedge clk_25MHz) begin
        if (reset) speed_val <= 0;
        else if (tick_reg[17:0] == 0) begin
            if      (speed_val < desired_speed) speed_val <= speed_val + 1;
            else if (speed_val > desired_speed) speed_val <= speed_val - 1;
        end
    end

    text_engine ui_text (
        .x(x), .y(y),
        .timer_val(timer_count), .gear_val(current_gear),
        .game_over(game_over), .game_won(game_won),
        .game_started(game_started), 
        .distance_val(distance_count), .speed_val(speed_val),
        .text_on_white(text_white), .text_on_black(text_black)
    );

    localparam [9:0] BAR_X = 200, BAR_Y = 64, BAR_W = 240, BAR_H = 12;
    wire [31:0] prog_tmp = distance_count * BAR_W;
    wire [9:0]  prog_w   = prog_tmp / TARGET_DISTANCE;
    wire in_bar        = (x >= BAR_X && x < BAR_X + BAR_W && y >= BAR_Y && y < BAR_Y + BAR_H);
    wire in_bar_fill   = in_bar && (x < BAR_X + prog_w);
    wire in_bar_border = in_bar && (y == BAR_Y || y == BAR_Y + BAR_H - 1);

    wire in_start_menu = !game_started && (y >= 198 && y <= 282 && x >= 208 && x <= 432);

    // --- CHANGED: Thinner Horizon Base (15) ---
    wire [9:0] road_width = (y > 100) ? (15 + (((y - 100) * 3) >> 2)) : 0;
    wire [9:0] scroll_y   = y - road_scroll;
    
    wire in_obj_bounds = obj_active && (y >= obj_top) && (y < obj_bottom) && (x >= obj_left) && (x < obj_right);
    
    // --- CHANGED: Draw bounds updated for 128 width ---
    wire draw_car  = (y >= CAR_Y && y < CAR_Y + CAR_H && x >= car_x - 64 && x < car_x + 64 && car_pixel != 12'hF0F);
    wire draw_coin = in_obj_bounds &&  obj_is_coin && (coin_pixel != 12'hF0F);
    wire draw_obs  = in_obj_bounds && !obj_is_coin && (obs_pixel != 12'hF0F);

    always @(*) begin
        if (!video_on)          rgb = 12'h000;
        else if (text_white)    rgb = 12'hFFF;
        else if (text_black)    rgb = 12'h000;
        else if (in_start_menu) rgb = 12'h000; 
        else if (in_bar_border) rgb = 12'hFFF;
        else if (in_bar_fill)   rgb = 12'h3F6;
        else if (draw_car)      rgb = car_pixel;
        else if (draw_coin)     rgb = coin_pixel;
        else if (draw_obs)      rgb = obs_pixel;

        else if (y <= 100)  rgb = 12'hCEE;
        else if (x > (320 - road_width) && x < (320 + road_width)) begin
            rgb = 12'h444; 
            if (x < (328 - road_width) || x > (312 + road_width))
                rgb = (y[5] == 0) ? 12'hEAA : 12'h222;
            else if (x > 319 && x < 321 && (scroll_y[4] == 0)) 
                rgb = 12'hFFF;
        end else rgb = 12'h3E7; 
    end
endmodule