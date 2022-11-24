module maxpool (
    input clk,
    input [3:0] pixel1,
    input [3:0] pixel2,
    input [3:0] pixel3,
    input [3:0] pixel4, // have to flatten image first
    output reg [3:0] maximum);

    wire [3:0] max1;
    wire [3:0] max2;

    always @ (posedge clk) begin
        maximum <= (pixel1 > (pixel2 > (pixel3 > pixel4 ? pixel3 : pixel4) ? pixel2 : (pixel3 > pixel4 ? pixel3 : pixel4)) ? pixel1 : (pixel2 > (pixel3 > pixel4 ? pixel3 : pixel4) ? pixel2 : (pixel3 > pixel4 ? pixel3 : pixel4)));
    end

endmodule