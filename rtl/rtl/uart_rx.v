`timescale 1ns/1ps
// ============================================================
//  UART Receiver — uart_rx.v
//  Oversampling at 16x for center-sampling
// ============================================================

module uart_rx #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       rx,
    output reg  [7:0] rx_data,
    output reg        rx_done
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0]  state;
    reg [15:0] clk_count;
    reg [2:0]  bit_index;
    reg [7:0]  rx_shift;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            rx_done   <= 1'b0;
            clk_count <= 0;
            bit_index <= 0;
        end else begin
            rx_done <= 1'b0;
            case (state)
                IDLE: begin
                    if (rx == 1'b0) begin
                        clk_count <= 0;
                        state     <= START;
                    end
                end

                START: begin
                    if (clk_count == (CLKS_PER_BIT/2) - 1) begin
                        if (rx == 1'b0) begin
                            clk_count <= 0;
                            state     <= DATA;
                            bit_index <= 0;
                        end else
                            state <= IDLE;
                    end else
                        clk_count <= clk_count + 1;
                end

                DATA: begin
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1;
                    else begin
                        clk_count        <= 0;
                        rx_shift[bit_index] <= rx;
                        if (bit_index < 7)
                            bit_index <= bit_index + 1;
                        else begin
                            bit_index <= 0;
                            state     <= STOP;
                        end
                    end
                end

                STOP: begin
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1;
                    else begin
                        rx_done   <= 1'b1;
                        rx_data   <= rx_shift;
                        clk_count <= 0;
                        state     <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule
