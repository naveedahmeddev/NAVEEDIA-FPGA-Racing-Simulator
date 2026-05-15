`timescale 1ns/1ps

module sprite_controller (
    input  wire        clk,
    input  wire        rst,
    input  wire [9:0]  pixel_x,
    input  wire [9:0]  pixel_y,
    input  wire [9:0]  sprite_x,
    input  wire [9:0]  sprite_y,
    input  wire [2:0]  sprite_id,

    // other sprite for collision check
    input  wire [9:0]  other_x,
    input  wire [9:0]  other_y,
    input  wire        other_active,

    output reg  [11:0] pixel_color,
    output reg         pixel_valid,
    output wire        collision
);

    localparam SPRITE_W = 32;
    localparam SPRITE_H = 32;
    localparam TRANSPARENT = 12'hF0F;

    wire in_sprite_x = (pixel_x >= sprite_x) && (pixel_x < sprite_x + SPRITE_W);
    wire in_sprite_y = (pixel_y >= sprite_y) && (pixel_y < sprite_y + SPRITE_H);
    wire in_sprite   = in_sprite_x && in_sprite_y;

    wire [4:0] rel_x = pixel_x - sprite_x;
    wire [4:0] rel_y = pixel_y - sprite_y;
    wire [9:0] rom_addr = (rel_y * SPRITE_W) + rel_x;

    wire [11:0] rom_data_0, rom_data_1, rom_data_2, rom_data_3, rom_data_4;

    racing_car_sprite_rom      rom0 (.addr(rom_addr), .data(rom_data_0));
    collision_car_sprite_1_rom rom1 (.addr(rom_addr), .data(rom_data_1));
    collision_car_sprite_2_rom rom2 (.addr(rom_addr), .data(rom_data_2));
    collision_car_sprite_3_rom rom3 (.addr(rom_addr), .data(rom_data_3));
    reward_coin_sprite_rom     rom4 (.addr(rom_addr), .data(rom_data_4));

    reg [11:0] selected_color;
    always @(*) begin
        case (sprite_id)
            3'd0: selected_color = rom_data_0;
            3'd1: selected_color = rom_data_1;
            3'd2: selected_color = rom_data_2;
            3'd3: selected_color = rom_data_3;
            3'd4: selected_color = rom_data_4;
            default: selected_color = TRANSPARENT;
        endcase
    end

    always @(posedge clk) begin
        if (!in_sprite || selected_color == TRANSPARENT) begin
            pixel_valid <= 1'b0;
            pixel_color <= 12'h000;
        end else begin
            pixel_valid <= 1'b1;
            pixel_color <= selected_color;
        end
    end

    // simple bounding-box collision (32x32)
    assign collision = other_active &&
                       (sprite_x < other_x + SPRITE_W) &&
                       (sprite_x + SPRITE_W > other_x) &&
                       (sprite_y < other_y + SPRITE_H) &&
                       (sprite_y + SPRITE_H > other_y);
endmodule