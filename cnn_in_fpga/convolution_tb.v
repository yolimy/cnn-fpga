`timescale 1ns/1ns
`include "convolution.v"


module convolution_tb;
    
    reg clk = 1'b0;
    reg [3:0] pixel1;
    reg [3:0] pixel2;
    reg [3:0] pixel3;
    reg [3:0] pixel4;
    reg [3:0] pixel5;
    reg [3:0] pixel6;
    reg [3:0] pixel7;
    reg [3:0] pixel8;
    reg [3:0] pixel9;
    reg [3:0] kernel1;
    reg [3:0] kernel2;
    reg [3:0] kernel3;
    reg [3:0] kernel4;
    reg [3:0] kernel5;
    reg [3:0] kernel6;
    reg [3:0] kernel7;
    reg [3:0] kernel8;
    reg [3:0] kernel9;
    wire [15:0] sum;

    convolution uut4 (clk, pixel1, pixel2, pixel3, pixel4, pixel5, pixel6, pixel7, pixel8, pixel9, kernel1, pixel2, pixel3, pixel4, pixel5, pixel6, pixel7, pixel8, pixel9, sum);

    always #1 clk = ~clk;

    initial begin 

        $dumpfile("convolution_tb.vcd");
        $dumpvars(0,convolution_tb);

        pixel1 = 4'b1111;
        pixel2 = 4'b1010;
        pixel3 = 4'b0111;
        pixel4 = 4'b1100;
        pixel5 = 4'b0101;
        pixel6 = 4'b0110;
        pixel7 = 4'b0001;
        pixel8 = 4'b0011;
        pixel9 = 4'b0010;

        kernel1 = 4'b0001;
        kernel2 = 4'b0001;
        kernel3 = 4'b0001;
        kernel4 = 4'b0000;
        kernel5 = 4'b0000;
        kernel6 = 4'b0000;
        kernel7 = 4'b0001;
        kernel8 = 4'b0001;
        kernel9 = 4'b0001;

        #2

        pixel1 = 4'b1110;
        pixel2 = 4'b1011;
        pixel3 = 4'b0110;
        pixel4 = 4'b1110;
        pixel5 = 4'b0100;
        pixel6 = 4'b0010;
        pixel7 = 4'b0011;
        pixel8 = 4'b0010;
        pixel9 = 4'b1010;

        kernel1 = 4'b0001;
        kernel2 = 4'b0000;
        kernel3 = 4'b0001;
        kernel4 = 4'b0001;
        kernel5 = 4'b0000;
        kernel6 = 4'b0001;
        kernel7 = 4'b0001;
        kernel8 = 4'b0000;
        kernel9 = 4'b0001;

        #2

        $display("Test complete!");
    end

endmodule