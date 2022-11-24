`timescale 1ns/1ns
`include "test.v"

module test_tb;
    reg a;
    wire b;

    notgate uut (a,b);

    initial begin

        $dumpfile("test_tb.vcd");
        $dumpvars(0,test_tb);

        a = 0;
        #20

        a = 1;
        #20

        a = 0;
        #20

        $display("Test complete!");


    end

endmodule