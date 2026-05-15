`timescale 1ns / 1ps

module text_engine(
    input wire [9:0] x,
    input wire [9:0] y,
    input wire [15:0] timer_val,
    input wire signed [3:0] gear_val, 
    input wire game_over,
    input wire game_won,
    input wire game_started,     
    input wire [15:0] distance_val,
    input wire [8:0] speed_val,
    output wire text_on_white,
    output wire text_on_black
);

    wire [2:0] row = y[3:1];
    wire [2:0] col = x[3:1];

    // HUD Bounds
    wire in_hud_bounds = (x >= 16 && x < 16 + (8*16)) && (y >= 16 && y < 48);
    wire [3:0] hud_char_index = (x - 16) >> 4; 

    wire in_right_bounds = (x >= 400 && x < 400 + (14*16)) && (y >= 16 && y < 48);
    wire [3:0] right_char_index = (x - 400) >> 4;

    wire in_go_bounds = game_over && (x >= 256 && x < 256 + (9*16)) && (y >= 224 && y < 256);
    wire [3:0] go_char_index = (x - 256) >> 4;
    wire go_line = (y >= 240);

    // START SCREEN BOUNDS (Centered at Y=240)
    wire in_start_bounds = !game_started && (x >= 224 && x < 224 + (12*16)) && (y >= 208 && y < 272);
    wire [3:0] start_char_index = (x - 224) >> 4;
    wire [1:0] start_line = (y - 208) >> 4;

    // CHANGED: Shifted Grass Text Up to Y=144
    wire in_left_grass = (x >= 32 && x < 32 + (8*16)) && (y >= 144 && y < 160);
    wire [3:0] left_char_index = (x - 32) >> 4;

    wire in_right_grass = (x >= 480 && x < 480 + (10*16)) && (y >= 144 && y < 160);
    wire [3:0] right_grass_index = (x - 480) >> 4;

    wire text_active_white = in_hud_bounds || in_right_bounds || in_go_bounds || in_start_bounds;
    wire text_active_black = in_left_grass || in_right_grass;

    // Logic for digits
    wire [3:0] timer_tens = (timer_val >= 60) ? 6 : (timer_val >= 50) ? 5 :
                            (timer_val >= 40) ? 4 : (timer_val >= 30) ? 3 :
                            (timer_val >= 20) ? 2 : (timer_val >= 10) ? 1 : 0;
    wire [3:0] timer_ones = timer_val - (timer_tens * 10);

    wire [3:0] speed_hundreds = speed_val / 100;
    wire [3:0] speed_tens     = (speed_val / 10) % 10;
    wire [3:0] speed_ones     = speed_val % 10;

    wire [3:0] dist_thousands = (distance_val / 1000);
    wire [3:0] dist_hundreds  = (distance_val / 100) % 10;
    wire [3:0] dist_tens      = (distance_val / 10) % 10;
    wire [3:0] dist_ones      = distance_val % 10;

    reg [6:0] char_code_white;
    reg [6:0] char_code_black;

    always @* begin
        char_code_white = 7'h20; // Default Space

        if (in_start_bounds) begin
            if (start_line == 0) begin
                case (start_char_index)
                    0: char_code_white = 7'h47; 1: char_code_white = 7'h4F;
                    2: char_code_white = 7'h41; 3: char_code_white = 7'h4C;
                    4: char_code_white = 7'h3A; 6: char_code_white = 7'h31;
                    7: char_code_white = 7'h39; 8: char_code_white = 7'h30;
                    9: char_code_white = 7'h30; 10: char_code_white = 7'h4D;
                endcase
            end else if (start_line == 1) begin
                case (start_char_index)
                    0: char_code_white = 7'h41; 1: char_code_white = 7'h56;
                    2: char_code_white = 7'h4F; 3: char_code_white = 7'h49;
                    4: char_code_white = 7'h44; 6: char_code_white = 7'h43;
                    7: char_code_white = 7'h41; 8: char_code_white = 7'h52;
                    9: char_code_white = 7'h53;
                endcase
            end else if (start_line == 2) begin
                case (start_char_index)
                    0: char_code_white = 7'h2D; 1: char_code_white = 7'h35;
                    2: char_code_white = 7'h53; 4: char_code_white = 7'h50;
                    5: char_code_white = 7'h45; 6: char_code_white = 7'h4E;
                    7: char_code_white = 7'h41; 8: char_code_white = 7'h4C;
                    9: char_code_white = 7'h54; 10: char_code_white = 7'h59;
                endcase
            end else begin
                case (start_char_index)
                    0: char_code_white = 7'h47; 1: char_code_white = 7'h45;
                    2: char_code_white = 7'h41; 3: char_code_white = 7'h52;
                    5: char_code_white = 7'h31; 7: char_code_white = 7'h54;
                    8: char_code_white = 7'h4F; 10: char_code_white = 7'h47;
                    11: char_code_white = 7'h4F;
                endcase
            end

        end else if (in_hud_bounds) begin
            if (y < 32) begin 
                case (hud_char_index)
                    0: char_code_white = 7'h54; 1: char_code_white = 7'h49; 
                    2: char_code_white = 7'h4D; 3: char_code_white = 7'h45; 
                    4: char_code_white = 7'h3A; 
                    6: char_code_white = 7'h30 + timer_tens; 
                    7: char_code_white = 7'h30 + timer_ones;
                endcase
            end else begin 
                case (hud_char_index)
                    0: char_code_white = 7'h47; 1: char_code_white = 7'h45; 
                    2: char_code_white = 7'h41; 3: char_code_white = 7'h52; 
                    4: char_code_white = 7'h3A; 
                    6: char_code_white = (gear_val == -1) ? 7'h2D : 7'h20; 
                    7: char_code_white = (gear_val == -1) ? 7'h31 : (7'h30 + gear_val[2:0]);
                endcase
            end

        end else if (in_right_bounds) begin
            if (y < 32) begin
                case (right_char_index)
                    0: char_code_white = 7'h53; 1: char_code_white = 7'h50;
                    2: char_code_white = 7'h45; 3: char_code_white = 7'h45;
                    4: char_code_white = 7'h44; 5: char_code_white = 7'h3A;
                    6: char_code_white = 7'h30 + speed_hundreds;
                    7: char_code_white = 7'h30 + speed_tens;
                    8: char_code_white = 7'h30 + speed_ones;
                endcase
            end else begin
                case (right_char_index)
                    0:  char_code_white = 7'h44; 1:  char_code_white = 7'h49;
                    2:  char_code_white = 7'h53; 3:  char_code_white = 7'h54;
                    4:  char_code_white = 7'h41; 5:  char_code_white = 7'h4E;
                    6:  char_code_white = 7'h43; 7:  char_code_white = 7'h45;
                    8:  char_code_white = 7'h3A; 9:  char_code_white = 7'h30 + dist_thousands;
                    10: char_code_white = 7'h30 + dist_hundreds;
                    11: char_code_white = 7'h30 + dist_tens;
                    12: char_code_white = 7'h30 + dist_ones;
                    13: char_code_white = 7'h4D;
                endcase
            end

        end else if (in_go_bounds) begin
            if (!go_line) begin
                case (go_char_index)
                    0: char_code_white = 7'h47; 1: char_code_white = 7'h41;
                    2: char_code_white = 7'h4D; 3: char_code_white = 7'h45;
                    5: char_code_white = 7'h4F; 6: char_code_white = 7'h56;
                    7: char_code_white = 7'h45; 8: char_code_white = 7'h52;
                endcase
            end else begin
                if (game_won) begin
                    case (go_char_index)
                        2: char_code_white = 7'h59; 3: char_code_white = 7'h4F;
                        4: char_code_white = 7'h55; 6: char_code_white = 7'h57;
                        7: char_code_white = 7'h49; 8: char_code_white = 7'h4E;
                    endcase
                end else begin
                    case (go_char_index)
                        1: char_code_white = 7'h59; 2: char_code_white = 7'h4F;
                        3: char_code_white = 7'h55; 5: char_code_white = 7'h4C;
                        6: char_code_white = 7'h4F; 7: char_code_white = 7'h53;
                        8: char_code_white = 7'h45;
                    endcase
                end
            end
        end
    end

    // Grass Text: NAVEEDIA RACING CAR
    always @* begin
        char_code_black = 7'h20;
        if (in_left_grass) begin
            case (left_char_index)
                0: char_code_black = 7'h4E; 1: char_code_black = 7'h41;
                2: char_code_black = 7'h56; 3: char_code_black = 7'h45;
                4: char_code_black = 7'h45; 5: char_code_black = 7'h44;
                6: char_code_black = 7'h49; 7: char_code_black = 7'h41;
            endcase
        end else if (in_right_grass) begin
            case (right_grass_index)
                0: char_code_black = 7'h52; 1: char_code_black = 7'h41;
                2: char_code_black = 7'h43; 3: char_code_black = 7'h49;
                4: char_code_black = 7'h4E; 5: char_code_black = 7'h47;
                7: char_code_black = 7'h43; 8: char_code_black = 7'h41;
                9: char_code_black = 7'h52;
            endcase
        end
    end

    wire font_pixel_white;
    wire font_pixel_black;

    font_rom rom_white(.char_code(char_code_white), .row(row), .col(col), .pixel(font_pixel_white));
    font_rom rom_black(.char_code(char_code_black), .row(row), .col(col), .pixel(font_pixel_black));

    assign text_on_white = text_active_white ? font_pixel_white : 1'b0;
    assign text_on_black = text_active_black ? font_pixel_black : 1'b0;

endmodule