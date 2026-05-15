`timescale 1ns / 1ps

module racing_car_sprite_rom (
    input wire [9:0] addr,
    output reg [11:0] data
);
    reg [11:0] mem [0:1023];
    initial $readmemh("racing_car_sprite.mem", mem);
    always @(*) data = mem[addr];
endmodule

module reward_coin_sprite_rom (
    input wire [9:0] addr,
    output reg [11:0] data
);
    reg [11:0] mem [0:1023];
    initial $readmemh("reward_coin_sprite.mem", mem);
    always @(*) data = mem[addr];
endmodule

module collision_car_sprite_3_rom (
    input wire [9:0] addr,
    output reg [11:0] data
);
    reg [11:0] mem [0:1023];
    initial $readmemh("collision_car_sprite_3.mem", mem);
    always @(*) data = mem[addr];
endmodule