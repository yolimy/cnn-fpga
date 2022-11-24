`timescale 1ns/1ns
`include "maxpool.v"

module maxpool_tb;

    reg clk = 1'b0;
    reg [3:0] pixel1;
    reg [3:0] pixel2;
    reg [3:0] pixel3;
    reg [3:0] pixel4; 
    wire [3:0] maximum;

    maxpool uut1 (clk, pixel1, pixel2, pixel3, pixel4, maximum);
    
    always #1 clk <= ~clk;

    initial begin


        $dumpfile("maxpool_tb.vcd");
        $dumpvars(0,maxpool_tb);

        pixel4 = 4'b0001;
        pixel3 = 4'b0010;
        pixel2 = 4'b0011;
        pixel1 = 4'b0100;

        #2

        pixel4 = 4'b1010;
        pixel3 = 4'b1001;
        pixel2 = 4'b1000;
        pixel1 = 4'b0111;
        
        #2

        $display("Test complete!");


    end

endmodule