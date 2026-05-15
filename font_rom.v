`timescale 1ns / 1ps

module font_rom(
    input wire [6:0] char_code, 
    input wire [2:0] row,       
    input wire [2:0] col,       
    output wire pixel           
);

    reg [63:0] bitmap;

    always @* begin
        case(char_code)
            7'h20: bitmap = 64'h00_00_00_00_00_00_00_00; // [Space]
            7'h2D: bitmap = 64'h00_00_00_3C_00_00_00_00; // - 
            7'h3A: bitmap = 64'h00_18_18_00_18_18_00_00; // :
            7'h30: bitmap = 64'h3C_42_42_42_42_42_3C_00; // 0
            7'h31: bitmap = 64'h18_28_08_08_08_08_3E_00; // 1
            7'h32: bitmap = 64'h3C_42_02_3C_40_40_7E_00; // 2
            7'h33: bitmap = 64'h3C_42_02_1C_02_42_3C_00; // 3
            7'h34: bitmap = 64'h0C_14_24_44_7E_04_04_00; // 4
            7'h35: bitmap = 64'h7E_40_7C_02_02_42_3C_00; // 5
            7'h36: bitmap = 64'h3C_40_40_7C_42_42_3C_00; // 6
            7'h37: bitmap = 64'h7E_02_04_08_10_10_10_00; // 7
            7'h38: bitmap = 64'h3C_42_42_3C_42_42_3C_00; // 8
            7'h39: bitmap = 64'h3C_42_42_3E_02_02_3C_00; // 9
            7'h41: bitmap = 64'h3C_42_42_7E_42_42_42_00; // A
            7'h43: bitmap = 64'h3C_42_40_40_40_42_3C_00; // C
            7'h44: bitmap = 64'h7C_42_42_42_42_42_7C_00; // D
            7'h45: bitmap = 64'h7E_40_40_7C_40_40_7E_00; // E
            7'h47: bitmap = 64'h3C_42_40_40_4E_42_3C_00; // G
            7'h49: bitmap = 64'h3C_18_18_18_18_18_3C_00; // I
            7'h4C: bitmap = 64'h40_40_40_40_40_40_7E_00; // L
            7'h4D: bitmap = 64'h42_66_5A_42_42_42_42_00; // M
            7'h4E: bitmap = 64'h42_62_52_4A_46_42_42_00; // N
            7'h4F: bitmap = 64'h3C_42_42_42_42_42_3C_00; // O
            7'h50: bitmap = 64'h7C_42_42_7C_40_40_40_00; // P
            7'h52: bitmap = 64'h7C_42_42_7C_48_44_42_00; // R
            7'h53: bitmap = 64'h3C_42_40_3C_02_42_3C_00; // S
            7'h54: bitmap = 64'h7E_18_18_18_18_18_18_00; // T
            7'h55: bitmap = 64'h42_42_42_42_42_42_3C_00; // U
            7'h56: bitmap = 64'h42_42_42_42_42_24_18_00; // V
            7'h57: bitmap = 64'h42_42_42_5A_66_42_42_00; // W
            7'h59: bitmap = 64'h42_42_24_18_18_18_18_00; // Y
            default: bitmap = 64'h0;
        endcase
    end

    wire [7:0] active_row = bitmap >> ((7 - row) * 8);
    assign pixel = active_row[7 - col];

endmodule