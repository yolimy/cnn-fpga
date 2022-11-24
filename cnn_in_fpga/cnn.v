`timescale 1ns / 1ns
`include "include.v"



module WeightMemory #(parameter numWeight = 3, neuronNo=5,layerNo=1, addressWidth=10, dataWidth=16, weightFile="w_1_15.mif")
    (input clk, 
    input wen, 
    input ren,
    input [addressWidth-1:0] wadd,
    input [addressWidth-1:0] radd,
    input [dataWidth-1:0] win,
    output reg [dataWidth-1:0] wout);

    reg [dataWidth-1:0] mem [numWeight-1:0];

    `ifdef pretrained // determine if is RAM or ROM
        initial begin // if define, it's more like a ROM
            $readmemb(weightFile, mem); // file must be in binary format
        end
    `else // if not define, it's more like a RAM
        always @ (posedge clk) begin
            if (wen) begin // when write enable is valid
                mem[wadd] <= win;  // store weight value in memory
            end
        end
    `endif 

    always @ (posedge clk) begin // sequential, if we use (*) combination, vivaldo canno† recognise to use block ram
        if (ren) begin //when read enable is valid
            wout <= mem[radd]; // take data from the memory
        end
    end

endmodule

module ReLU #(parameter dataWidth = 16, weightInWidth = 4)
    (input clk,
    input [2*dataWidth-1:0] x,
    output reg [dataWidth-1:0] out);

    always @ (posedge clk) begin
        if ($signed(x) >= 0) begin // check if it's a + ve or -ve answer 
            if (|x[2*dataWidth-1-:weightInWidth]) begin // overflow to sign bit of integer part
                out <= {1'b0, {(dataWidth-1){1'b1}}}; // positive saturate
            end else begin 
                out <= x[2*dataWidth-weightInWidth-1-:dataWidth]; 
            end
        end else begin
            out <= 0;
        end
    end

endmodule

module Sig_ROM #(parameter inWidth = 10, dataWidth = 16)
    (input clk,
    input [inWidth-1:0] x,
    output [dataWidth-1:0] out); 

    reg [dataWidth-1:0] mem [2**inWidth-1:0];
    reg [inWidth-1:0] y;

    initial begin
        @readmemb("sigContent.mif", mem);
    end

    always @ (posedge clk) begin
        if ($signed(x) >= 0) begin
            y <= x+(2**(inWidth-1));
        end else begin
            y <= x-(2**(inWidth-1));
        end
    end

    assign out = mem[y];  // wont be implemented in block RAM, but weighted RAM, not sequential 

endmodule


module neuron #(parameter layerNo = 0, neuronNo = 0, numWeight = 704, dataWidth = 16, sigmoidSize = 5, weightInWidth = 1, actType = "relu", biasFile =) // weightInWidth is to make sure that number is positive
    (input clk,
    input rst,
    input [dataWidth-1:0] myinput, // some bits are integer some are for decimal
    input myinputValid,
    input weightValid,
    input [31:0] weightValue, // use bus so that all neurons are hooked up to the same bus
    input [31:0] biasValue,
    input [31:0] config_layer_num,
    input [31:0] config_neuron_num, // can address particular weight value to the particular neuron
    output [dataWidth-1:0] out,
    output reg outvalid);

    parameter addressWidth = $clog2(numWeight);  // log base 2 of number of weight

    reg wen;
    wire ren;
    reg [addressWidth-1:0] w_addr;  // width is not fixed
    reg [addressWidth:0] r_addr; 
    reg [dataWidth-1:0] w_in;
    wire [dataWidth-1:0] w_out;
    reg [2*dataWidth-1:0] mul;
    reg [2*dataWidth-1:0] sum;
    reg [2*dataWidth-1:0] bias;
    reg [31:0] biasReg[0:0];
    
    reg weight_valid;
    reg mul_valid;
    wire mux_valid;
    reg sigValid;
    wire [2*dataWidth:0] comboAdd;
    wire [2*dataWidth:0] BiasAdd;
    reg [dataWidth-1:0] myinputd;
    reg muxValid_d;
    reg muxValid_f;
    reg addr = 0;

    //Loading weight into the memory
    always @ (posedge clk) begin
        if (rst) begin
        w_addr <= {addressWidth{1'b1'}};  //  duplicate 1, all write address will be initialise to 1
        wen <= 0;
        end else if (weightValid & (config_layer_num == layerNo) & (config_neuron_num == neuronNo)) begin 
            w_in <= weightValue;
            w_addr <= w_addr + 1; //write address going into neuron is always current value +1
            wen <= 1;
        end else begin
            wen <= 0;
        end
    end

    assign mux_valid = mul_valid;
    assign comboAdd = mul + sum;
    assign BiasAdd = bias + sum;
    assign ren = myinputValid;

    `ifdef pretrained
        initial begin
            @readmemb(biasFile, biasReg);
        end
        always @ (posedge clk) begin
            bias <= {biasReg[addr][dataWidth-1:0], {dataWidth{1'b0}}};
        end
    `else 
        always @ (posedge clk) begin
            if (bias & (config_layer_num == layerNo) & (config_neuron_num == neuronNo)) begin
                bias <= {biasValue[dataWidth-1:0], {dataWidth{1'b0}}};
            end
        end
    `endif   
    
    always @ (posedge clk) begin
        if (rst | outvalid) begin
            r_addr <= 0;
        end else if (myinputValid) begin
            r_addr <= r_addr + 1;
        end
    end

    always @ (posedge clk) begin
        mul <= $signed(myinput) * $signed(w_out);  // sign multiplication, corresponding weight and input. uses 2's compliment
    end

    always @ (posedge clk) begin 
        if (rst | outvalid) begin // reset or neuron give out an output, sum is reset to 0
            sum <= 0;
        end else if ((r_addr == numWeight) & muxValid_f) begin  // if numWeight is max value, mux is falling
            if (!bias[2*dataWidth-1] & !sum[2*dataWidth-1] & BiasAdd[2*dataWidth-1]) begin // if bias and sum are +ve
                sum[2*dataWidth-1] <= 1'b0;
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b1}}; 
            end else if (bias[2*dataWidth-1] & sum[2*dataWidth-1] & !BiasAdd[2*dataWidth-1]) begin // if bias and sum are -ve
                sum[2*dataWidth-1] <= 1'b1;
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b0}};
            end else begin
                sum <= BiasAdd;
            end 
        end else if (mux_valid) begin // during normal multiplication 
            if (!mul[2*dataWidth-1] & !sum[2*dataWidth-1] & comboAdd[2*dataWidth-1]) begin  // if previous sum and mul is +ve, and current comboadd is -ve, something went wrong too big
                sum[2*dataWidth-1] <= 1'b0;  // indicate +ve number
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b1}};  // saturate the output sum largest positive number
            end else if (mul[2*dataWidth-1] & sum[2*dataWidth-1] & !comboAdd[2*dataWidth-1]) begin //if previous sum and mul is -ve, and current comboadd is +ve, something went wrong too small
                sum[2*dataWidth-1] <= 1'b1;
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b0}};
            end else begin
                sum <= comboAdd;  // comboadd add the multiplication and the previous sum 
            end
        end
    end

    always @ (posedge clk) begin // pipeline delay so need to adjust accordingly
        myinputd <= myinput;
        weight_valid <= myinputValid;
        mul_valid <= weight_valid;
        sigValid <= ((r_addr == numWeight) & muxValid_f) ? 1'b1 : 1'b0;
        outvalid <= sigValid;
        muxValid_d <= mux_valid;
        muxValid_f <= !mux_valid & muxValid_d;
    end


    //Instatiate weight memory
    WeightMemory #(.numWeight(numWeight), .neuronNo(neuronNo), .layerNo(layerNo), .addressWidth(addressWidth), .dataWidth(dataWidth), .weightFile(weightFile)) WM 
        (.clk(clk),
        .wen(wen),
        .ren(ren),
        .wadd(w_addr),
        .radd(r_addr),
        .win(w_in),
        .wout(w_out));

    generate // instantiate module a few times, normal for loop does not work
        if (actType == "sigmoid") begin : siginst
        // instantiation of ROM for sigmoid
            Sig_ROM #(.inWidth(sigmoidSize), .dataWidth(dataWidth)) sl 
            (.clk(clk), 
            .x(sum[2*dataWidth-1-:sigmoidSize]), // sum = multiply accumulate all inputs and weights and bias. sigmoid is a memory, upper bits - size of sigmoid, the more deep more preicison but....
            .out(out)); // represent sigmoid value for that particular input
        end else begin : ReLUinst
            // instatiate ReLU
            ReLU #(.dataWidth(dataWidth), .weightInWidth(weightInWidth)) sl (.clk(clk), .x(sum), .out(out));
        end
    endgenerate

    `ifdef DEBUG
        always @ (posedge clk) begin 
            if (outvalid) begin
                $display(neuronNo,,,,"%b", out);
            end
        end
    `endif


endmodule