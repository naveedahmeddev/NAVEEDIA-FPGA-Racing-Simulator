`timescale 1ns / 1ps

module pedals_and_gears (
    input wire clk_25MHz,
    input wire reset,
    
    input wire [11:0] gas_val,
    input wire [11:0] brake_val,
    
    // [0]=Rev, [1]=G1, [2]=G2, [3]=G3, [4]=G4, [5]=G5
    input wire [5:0] gear_btn, 
    
    output reg signed [3:0] current_gear,
    output reg [24:0] target_speed_delay
);

    localparam [24:0] STOP_DELAY = 25_000_000;

    // --- LATCHING GEAR LOGIC ---
    // Remembers the last pressed button. Defaults to 0 (Neutral) on reset.
    always @(posedge clk_25MHz) begin
        if (reset) begin
            current_gear <= 0; 
        end else begin
            if      (gear_btn[5]) current_gear <= 5;  // Gear 5
            else if (gear_btn[4]) current_gear <= 4;  // Gear 4
            else if (gear_btn[3]) current_gear <= 3;  // Gear 3
            else if (gear_btn[2]) current_gear <= 2;  // Gear 2
            else if (gear_btn[1]) current_gear <= 1;  // Gear 1
            else if (gear_btn[0]) current_gear <= -1; // Reverse
        end
    end

    // --- ENGINE SIMULATION ---
    integer calculated_delay;
    wire [3:0] abs_gear = (current_gear < 0) ? -current_gear : current_gear;
    wire gas_active = (gas_val != 12'h000);

    always @(*) begin
        if (current_gear == 0 || !gas_active) begin
            target_speed_delay = STOP_DELAY;
        end else begin
            // Speed scaling algorithm
            calculated_delay = 400_000 - (gas_val * abs_gear * 50) + (brake_val * 300);
            if (calculated_delay < 20_000)       target_speed_delay = 20_000;
            else if (calculated_delay > 999_999) target_speed_delay = 999_999;
            else                                 target_speed_delay = calculated_delay;
        end
    end

endmodule