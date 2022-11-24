module convolution (
    input clk,
    input [3:0] pixel1,
    input [3:0] pixel2,
    input [3:0] pixel3,
    input [3:0] pixel4,
    input [3:0] pixel5,
    input [3:0] pixel6,
    input [3:0] pixel7,
    input [3:0] pixel8,
    input [3:0] pixel9,
    input [3:0] kernel1,
    input [3:0] kernel2,
    input [3:0] kernel3,
    input [3:0] kernel4,
    input [3:0] kernel5,
    input [3:0] kernel6,
    input [3:0] kernel7,
    input [3:0] kernel8,
    input [3:0] kernel9,
    output reg [15:0] sum
);


    always @ (posedge clk) begin
        sum = pixel1*kernel1 + pixel2*kernel2 + pixel3*kernel3 + pixel4*kernel4 + pixel5*kernel5 + pixel6*kernel6 + pixel7*kernel7 + pixel8*kernel8 + pixel9*kernel9;
    end
    
endmodule