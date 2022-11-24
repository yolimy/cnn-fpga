module relu (
    input clk,
    input [11:0] in,
    output reg [11:0] out
);
    always @ (posedge clk) begin
        if (in[11] == 1'b1) begin
            out <= 12'b000000000000;
        end else begin
            out <= in;
        end
    end
endmodule
