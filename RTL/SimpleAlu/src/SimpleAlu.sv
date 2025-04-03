module SimpleAlu #(
    parameter DATA_WIDTH,
    parameter OP_WIDTH
)(
    input clk,
    input resetn,
    input [DATA_WIDTH-1:0] A,
    input [DATA_WIDTH-1:0] B,
    input [OP_WIDTH-1:0] OP,
    output [DATA_WIDTH-1:0] X,
    output Z
);
    logic [DATA_WIDTH-1:0] output_d, output_q;

    assign Z = (X == 0);
    assign X = output_q;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            output_q <= 0;
        end else begin
            output_q <= output_d;
        end
    end

    always_comb begin
        output_d = output_q;
        case (OP)
            3'b000 : output_d = A + B;
            3'b001 : output_d = A - B;
            3'b010 : output_d = ~(A | B);
            3'b011 : output_d = A | B;
            3'b100 : output_d = ~(A & B);
            3'b101 : output_d = A & B;
            3'b110 : output_d = A ~^ B;
            default: output_d = 0;
        endcase
    end
endmodule