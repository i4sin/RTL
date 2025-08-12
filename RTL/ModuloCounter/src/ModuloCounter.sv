module ModuloCounter #(
    parameter MODULUS,
    localparam LG_MODULUS = $clog2(MODULUS)
) (
    input clk,
    input resetn,
    output logic [LG_MODULUS-1:0] counted
);
    logic [LG_MODULUS-1:0] counted_d, counted_q;

    assign counted = counted_q;

    always_ff @(posedge clk) begin
        if (!resetn) begin
            counted_q <= 0;
        end else begin
            counted_q <= counted_d;
        end
    end

    always_comb begin
        counted_d = counted_q;
        if (counted_q == MODULUS - 1) counted_d = 0;
        else if (counted_q < MODULUS) counted_d = counted_q + 1;
    end
endmodule
