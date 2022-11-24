`timescale 1ns/1ns
`include "relu.v"

module relu_tb;

    reg [11:0] in;
    reg clk = 1'b0;
    wire [11:0] out;

    relu uut3 (clk, in, out);

    always #1 clk <= ~clk;

    initial begin

        $dumpfile("relu_tb.vcd");
        $dumpvars(0,relu_tb);


        in = 12'b000011110001;
        #2

        in = 12'b111100101110;
        #2

        in = 12'b010101010101;
        #2

        in = 12'b100010101101;
        #2

        $display("Test complete!");
    end


endmodule