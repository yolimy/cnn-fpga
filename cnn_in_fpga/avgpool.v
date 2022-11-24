module avgpool (
    input clk,
    input [3:0] pixel1,
    input [3:0] pixel2,
    input [3:0] pixel3,
    input [3:0] pixel4, // have to flatten image first
    output reg [3:0] average);

    always @ (posedge clk) begin
        average <= ( pixel1 + pixel2 + pixel3+ pixel4 ) / 4;
    end

endmodule