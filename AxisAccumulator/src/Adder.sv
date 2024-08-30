module Adder #(
    parameter WIDTH
) (
    input cin,
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output logic cout,
    output logic [WIDTH-1:0] adder_output
);
    assign {cout, adder_output} = a + b + cin;
endmodule
