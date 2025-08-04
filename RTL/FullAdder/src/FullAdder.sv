module FullAdder #(
    parameter DATA_WIDTH
)(
    input logic cin,
    input logic [DATA_WIDTH-1:0] in1,
    input logic [DATA_WIDTH-1:0] in2,
    output cout,
    output logic [DATA_WIDTH-1:0] out
);
    assign {cout, out} = cin + in1 + in2;
endmodule
