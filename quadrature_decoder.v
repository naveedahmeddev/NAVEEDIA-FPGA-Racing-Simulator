`timescale 1ns / 1ps

module quadrature_decoder(
    input clk,           // 25MHz clock from top module
    input reset,
    input quadA,
    input quadB,
    output reg [9:0] position
);
    reg [1:0] syncA, syncB;
    always @(posedge clk) begin
        syncA <= {syncA[0], quadA};
        syncB <= {syncB[0], quadB};
    end

    reg [15:0] tick_counter;
    wire sample_tick = (tick_counter == 25000 - 1); 

    always @(posedge clk) begin
        if (reset) tick_counter <= 0;
        else if (sample_tick) tick_counter <= 0;
        else tick_counter <= tick_counter + 1;
    end

    reg last_A, last_B;
    always @(posedge clk) begin
        if (reset) begin
            last_A <= 0;
            last_B <= 0;
        end else if (sample_tick) begin
            last_A <= syncA[1];
            last_B <= syncB[1];
        end
    end

    // --- CHANGED: Max Width Boundaries (90 to 550) & Faster Step (4) ---
    always @(posedge clk) begin
        if (reset) begin
            position <= 320; // Start exactly in the center
        end else if (sample_tick) begin
            
            if (syncA[1] == 1'b1 && last_A == 1'b0) begin
                if (syncB[1] == 1'b0) begin
                    if (position < 550) position <= position + 4; // Turn Right
                end else begin
                    if (position > 90) position <= position - 4;  // Turn Left
                end
            end
            else if (syncA[1] == 1'b0 && last_A == 1'b1) begin
                if (syncB[1] == 1'b1) begin
                    if (position < 550) position <= position + 4; // Turn Right
                end else begin
                    if (position > 90) position <= position - 4;  // Turn Left
                end
            end
            
        end
    end
endmodule