module AxisAccumulator #(
    parameter ADDER_WIDTH,
    parameter SINGLE_WORD_OUTPUT
) (
    AxisIf.slave s_axis_add,
    AxisIf.slave s_axis_sub,
    AxisIf.master m_axis
);
    if (s_axis_add.TDATA_WIDTH != s_axis_sub.TDATA_WIDTH) $error("Input interfaces are not of same size!");

    localparam S_TDATA_WIDTH = s_axis_add.TDATA_WIDTH;
    localparam M_TDATA_WIDTH = m_axis.TDATA_WIDTH;
    localparam OP_WIDTH = (M_TDATA_WIDTH % ADDER_WIDTH == 0)? M_TDATA_WIDTH : M_TDATA_WIDTH + ADDER_WIDTH - (M_TDATA_WIDTH % ADDER_WIDTH);
    localparam OP_COUNT = OP_WIDTH / ADDER_WIDTH;

    logic clk, resetn;

    logic [OP_WIDTH-1:0] ext_op_tdata;
    logic [OP_WIDTH-1:0] ext_m_tdata;

    logic [M_TDATA_WIDTH-1:0] m_tdata_d, m_tdata_q;
    logic m_tvalid_d, m_tvalid_q;

    logic [ADDER_WIDTH-1:0] port_a;
    logic [ADDER_WIDTH-1:0] port_b;
    logic [ADDER_WIDTH-1:0] adder_output;
    logic [$clog2(OP_WIDTH):0] i_d, i_q;
    logic cin;
    logic cout_d, cout_q;
    logic sub_flag, sub_flag_d, sub_flag_q;
    logic add_finished_d, add_finished_q;
    logic sub_finished_d, sub_finished_q;
    logic waiting_for_m_tready;
    logic last_flag;

    Adder #(
        .WIDTH(ADDER_WIDTH)
    ) adder (
        .cin(cin),
        .a(port_a),
        .b(port_b),
        .cout(cout),
        .adder_output(adder_output)
    );

    assign clk = m_axis.aclk;
    assign resetn = m_axis.aresetn;

    assign m_axis.tdata = m_tdata_q;
    assign m_axis.tlast = (add_finished_q && sub_finished_q);
    assign m_axis.tvalid = m_tvalid_q;

    assign ext_op_tdata = sub_flag ? ~s_axis_sub.tdata : s_axis_add.tdata;
    assign ext_m_tdata = {{(OP_WIDTH - M_TDATA_WIDTH) {m_tdata_q[M_TDATA_WIDTH-1]}}, m_tdata_q};

    assign cin = i_q == 0 ? (sub_flag) : cout_q;
    assign sub_flag = (s_axis_sub.tvalid && (!sub_finished_q || (m_axis.tlast)) && i_q == 0) ? 1 : sub_flag_q;
    assign port_a = ext_op_tdata[i_q*ADDER_WIDTH+:ADDER_WIDTH];
    assign port_b = (m_tvalid_q && m_axis.tlast && m_axis.tready) ? 0 : ext_m_tdata[i_q*ADDER_WIDTH+:ADDER_WIDTH];
    assign waiting_for_m_tready = (i_q == 0 && m_tvalid_q && !m_axis.tready);
    assign last_flag = (add_finished_q && sub_finished_q) || (add_finished_q && sub_finished_d) || (add_finished_d && sub_finished_q);

    task determine_ready_last();
        if (sub_flag) begin
            s_axis_sub.tready = 1;
            sub_finished_d = s_axis_sub.tlast;
        end else begin
            s_axis_add.tready = 1;
            add_finished_d = s_axis_add.tlast;
        end
    endtask

    always_ff @(posedge clk, negedge resetn) begin
        if (!resetn) begin
            m_tdata_q <= 0;
            m_tvalid_q <= 0;
            i_q <= 0;
            cout_q <= 0;
            sub_flag_q <= 0;
            add_finished_q <= 0;
            sub_finished_q <= 0;
        end else begin
            m_tdata_q <= m_tdata_d;
            m_tvalid_q <= m_tvalid_d;
            i_q <= i_d;
            cout_q <= cout_d;
            sub_flag_q <= sub_flag_d;
            add_finished_q <= add_finished_d;
            sub_finished_q <= sub_finished_d;
        end
    end

    always_comb begin
        s_axis_add.tready = 0;
        s_axis_sub.tready = 0;
        m_tdata_d = m_tdata_q;
        m_tvalid_d = m_tvalid_q;
        i_d = i_q;
        cout_d = cout;
        sub_flag_d = (OP_COUNT == 1) ? 0 : ((sub_flag) ? 1 : sub_flag_q);
        add_finished_d = add_finished_q;
        sub_finished_d = sub_finished_q;
        if ((s_axis_add.tvalid && !add_finished_q) || (s_axis_sub.tvalid && !sub_finished_q)) begin
            if (!waiting_for_m_tready) m_tdata_d[i_q*ADDER_WIDTH+:ADDER_WIDTH] = adder_output;
            if (i_q < OP_COUNT - 1 && !waiting_for_m_tready) begin
                m_tvalid_d = 0;
                i_d = i_q + 1;
            end else if (i_q == OP_COUNT - 1) begin
                m_tvalid_d = SINGLE_WORD_OUTPUT ? last_flag : 1;
                i_d = 0;
                sub_flag_d = 0;
                determine_ready_last();
            end
        end else if (m_tvalid_q && m_axis.tready) begin
            m_tvalid_d = 0;
            if (m_axis.tlast) begin
                m_tdata_d = 0;
                add_finished_d = 0;
                sub_finished_d = 0;
                if (s_axis_add.tvalid || s_axis_sub.tvalid) begin
                    m_tdata_d = adder_output;
                    if (i_q < OP_COUNT - 1) begin
                        i_d = 1;
                    end else begin
                        determine_ready_last();
                    end
                end
            end
        end
    end
endmodule
