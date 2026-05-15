`timescale 1ns / 1ps

module object_logic (
    input wire clk_25MHz,
    input wire reset,
    input wire game_over,
    input wire game_started,
    input wire [8:0] speed_val,
    input wire signed [3:0] current_gear,
    output reg [9:0] obj_y,
    output reg obj_active,
    output reg obj_is_coin,
    output reg [2:0] obj_lane // CHANGED: Now 3 bits to support 5 lanes (0 to 4)
);
    localparam OBSTACLE_INTERVAL = 28'd75_000_000;  
    localparam COIN_INTERVAL     = 28'd125_000_000; 
    
    // CHANGED: Horizon moved WAY up. Road now takes up 80% of the screen.
    localparam HORIZON_Y         = 10'd100;         

    localparam MOVE_TICK = 19'd416_666; 
    
    reg [27:0] obstacle_timer;
    reg [27:0] coin_timer;
    reg [18:0] move_timer;

    // --- PSEUDO-RANDOM NUMBER GENERATOR (LFSR) ---
    // This scrambles an 8-bit number every clock cycle
    reg [7:0] lfsr;
    always @(posedge clk_25MHz) begin
        if (reset) lfsr <= 8'hAC; // Must start at a non-zero value
        else lfsr <= {lfsr[6:0], lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3]};
    end

    // Map the random 3 bits (0-7) down to exactly 5 lanes (0-4)
    wire [2:0] random_lane = (lfsr[2:0] > 4) ? (lfsr[2:0] - 3) : lfsr[2:0];

    wire [9:0] move_step = (speed_val >> 5) + 1; 

    always @(posedge clk_25MHz) begin
        if (reset) begin
            obstacle_timer <= 0;
            coin_timer     <= 0;
            move_timer     <= 0;
            obj_active     <= 0;
            obj_is_coin    <= 0;
            obj_y          <= HORIZON_Y;
            obj_lane       <= 0;
        end else if (game_started && !game_over) begin

            if (!obj_active) begin
                obstacle_timer <= obstacle_timer + 1;
                coin_timer     <= coin_timer + 1;

                if (obstacle_timer >= OBSTACLE_INTERVAL) begin
                    obstacle_timer <= 0;
                    coin_timer     <= 0;
                    obj_active  <= 1;
                    obj_is_coin <= 0;
                    obj_y <= HORIZON_Y;
                    obj_lane <= random_lane; // Assign random lane
                end else if (coin_timer >= COIN_INTERVAL) begin
                    coin_timer     <= 0;
                    obstacle_timer <= 0;
                    obj_active  <= 1;
                    obj_is_coin <= 1;
                    obj_y <= HORIZON_Y;
                    obj_lane <= random_lane; // Assign random lane
                end
            end

            if (obj_active) begin
                move_timer <= move_timer + 1;
                if (move_timer >= MOVE_TICK) begin
                    move_timer <= 0;
                    if (obj_y < 480 && obj_y >= HORIZON_Y) begin
                        if (current_gear < 0) obj_y <= obj_y - move_step;
                        else                  obj_y <= obj_y + move_step;
                    end else begin
                        obj_active <= 0; 
                    end
                end
            end
        end
    end
endmodule