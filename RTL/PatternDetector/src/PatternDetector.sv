module PatternDetector #(
    parameter PATTERN,
    parameter WIDTH
) (
    DataIf.slave s_data,
    DataIf.master m_data
);
    localparam PURE_PATTERN = PATTERN[WIDTH-1:0];

    logic clk;
    logic resetn;
    logic [WIDTH-1:0] buf_d, buf_q;

    assign clk = s_data.clk;
    assign resetn = s_data.resetn;
    assign m_data.data = (buf_d == PURE_PATTERN);

    always_ff @(posedge clk) begin
        if (!resetn) begin
            buf_q <= 0;
        end else begin
            buf_q <= buf_d;
        end
    end

    always_comb begin
        s_data.ready = 1;
        m_data.valid = 0;
        buf_d = buf_q;
        if (s_data.valid) begin
            s_data.ready = m_data.ready;
            m_data.valid = 1;
            if (m_data.ready) buf_d = {buf_q, s_data.data};
        end
    end
endmodule
