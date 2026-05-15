`timescale 1ns / 1ps

// Debouncer specifically for Active-Low IR sensors
module ir_sensor_debounce (
    input wire clk,
    input wire reset,
    input wire ir_in,
    output reg ir_out_clean // Outputs 1 when object is detected reliably
);
    reg [15:0] count;
    reg sync_0, sync_1;

    // Double-flop synchronizer to prevent metastability
    always @(posedge clk) begin
        sync_0 <= ir_in;
        sync_1 <= sync_0;
    end

    always @(posedge clk) begin
        if (reset) begin
            count <= 0;
            ir_out_clean <= 0;
        end else begin
            // IR sensor outputs 0 when an object is detected
            if (sync_1 == 1'b0) begin
                if (count < 16'hFFFF) count <= count + 1;
                else ir_out_clean <= 1'b1; // Fully detected
            end else begin
                if (count > 0) count <= count - 1;
                else ir_out_clean <= 1'b0; // Nothing detected
            end
        end
    end
endmodule

// Main Pedal Source Selector
module pedal_source_select #(
    parameter USE_IR_SENSORS = 1'b1 // Set to 1 to use IR, 0 to use FPGA buttons
)(
    input  wire clk,
    input  wire reset,
    
    input  wire btn_gas,     // Fallback Push Button Up
    input  wire btn_brake,   // Fallback Push Button Down
    
    input  wire ir_gas,      // New IR Sensor (Gas)
    input  wire ir_brake,    // New IR Sensor (Brake)

    output wire [11:0] gas_out,
    output wire [11:0] brake_out
);

    wire clean_ir_gas;
    wire clean_ir_brake;

    // Instantiate Debouncers
    ir_sensor_debounce gas_deb (
        .clk(clk), .reset(reset), .ir_in(ir_gas), .ir_out_clean(clean_ir_gas)
    );

    ir_sensor_debounce brake_deb (
        .clk(clk), .reset(reset), .ir_in(ir_brake), .ir_out_clean(clean_ir_brake)
    );

    // Multiplexer: Choose between IR Sensors or physical Buttons
    assign gas_out   = USE_IR_SENSORS ? (clean_ir_gas   ? 12'hFFF : 12'h000) : (btn_gas   ? 12'hFFF : 12'h000);
    assign brake_out = USE_IR_SENSORS ? (clean_ir_brake ? 12'hFFF : 12'h000) : (btn_brake ? 12'hFFF : 12'h000);

endmodule