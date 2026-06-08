`timescale 1ns/1ps
// ============================================================
//  UART Loopback Testbench — uart_tb.v
//  TX output connected directly to RX input
//  Sends bytes: H E L L O (0x48 0x45 0x4C 0x4C 0x4F)
// ============================================================

module uart_tb;

    parameter CLK_FREQ  = 50000000;
    parameter BAUD_RATE = 115200;
    parameter CLK_PERIOD = 20;

    reg        clk, rst;
    reg        tx_start;
    reg  [7:0] tx_data;
    wire       tx_line;
    wire       tx_busy;
    wire [7:0] rx_data;
    wire       rx_done;

    uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) u_tx (
        .clk(clk), .rst(rst),
        .tx_start(tx_start), .tx_data(tx_data),
        .tx(tx_line), .tx_busy(tx_busy)
    );

    uart_rx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) u_rx (
        .clk(clk), .rst(rst),
        .rx(tx_line),
        .rx_data(rx_data), .rx_done(rx_done)
    );

    initial begin
        $dumpfile("uart_waves.vcd");
        $dumpvars(0, uart_tb);
    end

    always #(CLK_PERIOD/2) clk = ~clk;

    task send_byte;
        input [7:0] data;
        input [7:0] expected;
        begin
            @(posedge clk);
            tx_data  = data;
            tx_start = 1'b1;
            @(posedge clk);
            tx_start = 1'b0;
            wait(rx_done == 1'b1);
            @(posedge clk);
            if (rx_data === expected)
                $display("PASS | sent=0x%h received=0x%h ('%s')",
                          data, rx_data, data);
            else
                $display("FAIL | sent=0x%h expected=0x%h got=0x%h",
                          data, expected, rx_data);
        end
    endtask

    initial begin
        clk      = 0;
        rst      = 1;
        tx_start = 0;
        tx_data  = 0;
        #100;
        rst = 0;
        #100;

        $display("========================================");
        $display("       UART Loopback Testbench");
        $display("========================================");

        send_byte(8'h48, 8'h48);   // H
        send_byte(8'h45, 8'h45);   // E
        send_byte(8'h4C, 8'h4C);   // L
        send_byte(8'h4C, 8'h4C);   // L
        send_byte(8'h4F, 8'h4F);   // O

        $display("========================================");
        $display("  UART loopback test complete");
        $display("========================================");
        #1000;
        $finish;
    end

endmodule
