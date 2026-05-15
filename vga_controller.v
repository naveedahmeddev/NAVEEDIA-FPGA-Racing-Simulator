`timescale 1ns / 1ps

module vga_controller(
    input wire clk,       // 25 MHz clock from the main module
    input wire reset,     // System reset
    output wire h_sync,   // Horizontal sync for the monitor
    output wire v_sync,   // Vertical sync for the monitor
    output wire video_on, // Tells the main module when it's safe to draw
    output wire p_tick,   // Pixel tick (unused right now, but good to have)
    output wire [9:0] x,  // Current X pixel coordinate
    output wire [9:0] y   // Current Y pixel coordinate
);

    // VGA 640x480 @ 60Hz Industry Standard Parameters
    localparam HD = 640; // horizontal display area
    localparam HF = 16;  // horizontal front porch
    localparam HB = 48;  // horizontal back porch
    localparam HR = 96;  // horizontal retrace
    localparam HMAX = HD+HF+HB+HR-1; // 799

    localparam VD = 480; // vertical display area
    localparam VF = 10;  // vertical front porch
    localparam VB = 33;  // vertical back porch
    localparam VR = 2;   // vertical retrace
    localparam VMAX = VD+VF+VB+VR-1; // 524

    // Counters to keep track of X and Y pixels
    reg [9:0] h_count_reg, h_count_next;
    reg [9:0] v_count_reg, v_count_next;

    // Output Registers
    reg v_sync_reg, h_sync_reg;
    wire v_sync_next, h_sync_next;

    // Status signals
    wire h_end, v_end;

    // Update registers on every clock tick
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            v_count_reg <= 0;
            h_count_reg <= 0;
            v_sync_reg  <= 1'b0;
            h_sync_reg  <= 1'b0;
        end else begin
            v_count_reg <= v_count_next;
            h_count_reg <= h_count_next;
            v_sync_reg  <= v_sync_next;
            h_sync_reg  <= h_sync_next;
        end
    end

    // End of row / end of screen logic
    assign h_end = (h_count_reg == HMAX);
    assign v_end = (v_count_reg == VMAX);

    // Horizontal pixel counter
    always @* begin
        if (h_end)
            h_count_next = 0;
        else
            h_count_next = h_count_reg + 1;
    end

    // Vertical line counter
    always @* begin
        if (h_end) begin
            if (v_end)
                v_count_next = 0;
            else
                v_count_next = v_count_reg + 1;
        end else begin
            v_count_next = v_count_reg;
        end
    end

    // Generate Sync signals (Active Low for 640x480)
    assign h_sync_next = (h_count_reg < (HD+HF) || h_count_reg > (HD+HF+HR-1));
    assign v_sync_next = (v_count_reg < (VD+VF) || v_count_reg > (VD+VF+VR-1));

    // Video ON signal (only draw when inside the 640x480 visible area)
    assign video_on = (h_count_reg < HD) && (v_count_reg < VD);

    // Route internal signals to outputs
    assign h_sync = h_sync_reg;
    assign v_sync = v_sync_reg;
    assign x      = h_count_reg;
    assign y      = v_count_reg;
    assign p_tick = clk;

endmodule