module fulladder(
    input clk,
    input x1, 
    input x2, 
    input cin,
    output reg s,
    output reg c
);

    always @ (posedge clk) begin
        s <= cin ^ x1 ^ x2;
        c <= x1 & x2 | cin & (x1 ^ x2);
    end

endmodule