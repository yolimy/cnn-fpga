`include "fulladder.v"
`timescale 1ns/1ns

module fulladder_tb;
    reg clk = 1'b0;
    reg x1;
    reg x2;
    reg cin;
    wire s;
    wire c;

    fulladder adder (clk, x1, x2, cin, s, c);

    always #1 clk = ~clk;

    initial begin

        $dumpfile("fulladder_tb.vcd");
        $dumpvars(0,fulladder_tb);        

        x1 = 1'b1;
        x2 = 1'b0;
        cin = 1'b1;

        #2

        x1 = 1'b1;
        x2 = 1'b1;
        cin = 1'b1;

        #2

        x1 = 1'b0;
        x2 = 1'b0; 
        cin = 1'b1;

        #2 

        $display("Test complete!");

    end
endmodule