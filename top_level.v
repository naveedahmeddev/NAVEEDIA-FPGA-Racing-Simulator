`timescale 1ns / 1ps

module top_level(
    input wire clk_100MHz,
    input wire reset,
    
    // NEW: Push Button Gear Array
    input wire [5:0] gear_btn_in, 
    
    input wire btnU,   // Fallback Gas
    input wire btnD,   // Fallback Brake
    input wire quadA,       
    input wire quadB,
    
    // IR Sensor Inputs
    input wire ir_gas_pin,
    input wire ir_brake_pin,
    
    output wire h_sync,
    output wire v_sync,
    output wire [11:0] rgb
);

    reg [1:0] q_reg;
    always @(posedge clk_100MHz) q_reg <= q_reg + 1;
    wire clk_25MHz = q_reg[1];

    wire [11:0] gas_pedal, brake_pedal;

    pedal_source_select #(.USE_IR_SENSORS(1'b1)) pedal_select (
        .clk(clk_25MHz),
        .reset(reset),
        .btn_gas(btnU), 
        .btn_brake(btnD), 
        .ir_gas(ir_gas_pin),      
        .ir_brake(ir_brake_pin),  
        .gas_out(gas_pedal), 
        .brake_out(brake_pedal)
    );

    wire signed [3:0] active_gear;
    wire [24:0] active_speed_delay;

    pedals_and_gears transmission_inst (
        .clk_25MHz(clk_25MHz), 
        .reset(reset), 
        .gas_val(gas_pedal), 
        .brake_val(brake_pedal),
        .gear_btn(gear_btn_in),  // Passed from physical push buttons
        .current_gear(active_gear), 
        .target_speed_delay(active_speed_delay)
    );

    racing_display display_inst (
        .clk_25MHz(clk_25MHz), .reset(reset), .quadA(quadA), .quadB(quadB),
        .current_gear(active_gear), .target_speed_delay(active_speed_delay),
        .h_sync(h_sync), .v_sync(v_sync), .rgb(rgb)
    );

endmodule