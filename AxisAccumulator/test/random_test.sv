class random_test extends uvm_test;

    localparam DELAY_INSERT = 1;
    localparam S_TDATA_WIDTH = 8;
    localparam M_TDATA_WIDTH = 32;
    localparam SINGLE_WORD_OUTPUT = 0;
    localparam MAX_PACKETS_COUNT = 512;

    bit test_pass = 0;

    `uvm_component_utils(random_test)

    function new(string name = "random_test", uvm_component parent = null);
        super.new(name , parent);
    endfunction

    Environment #(
        .DELAY_INSERT(DELAY_INSERT),
        .S_TDATA_WIDTH(S_TDATA_WIDTH),
        .M_TDATA_WIDTH(M_TDATA_WIDTH),
        .SINGLE_WORD_OUTPUT(SINGLE_WORD_OUTPUT)
    ) env;

    PacketSequence #(
        .S_TDATA_WIDTH(S_TDATA_WIDTH),
        .MAX_PACKETS_COUNT(MAX_PACKETS_COUNT)
    ) addpktsq, subpktsq;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = Environment #(
            .DELAY_INSERT(DELAY_INSERT),
            .S_TDATA_WIDTH(S_TDATA_WIDTH),
            .M_TDATA_WIDTH(M_TDATA_WIDTH),
            .SINGLE_WORD_OUTPUT(SINGLE_WORD_OUTPUT)
        )::type_id::create("env", this);

        addpktsq = PacketSequence#(
            .S_TDATA_WIDTH(S_TDATA_WIDTH),
            .MAX_PACKETS_COUNT(MAX_PACKETS_COUNT)
        )::type_id::create(
            "addpktsq", this
        );

        subpktsq = PacketSequence#(
            .S_TDATA_WIDTH(S_TDATA_WIDTH),
            .MAX_PACKETS_COUNT(MAX_PACKETS_COUNT)
        )::type_id::create(
            "subpktsq", this
        );
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        addpktsq.start(env.add_master.sequencer);
        subpktsq.start(env.sub_master.sequencer);
        phase.drop_objection(this);
        `uvm_info(get_type_name, "End of testcase", UVM_LOW);
    endtask

    function void extract_phase(uvm_phase phase);
        if (env.scoreboard.sbd_error) test_pass = 0;
    endfunction

    function void report_phase(uvm_phase phase);
        if (test_pass) begin
            `uvm_info(get_type_name(), "** UVM TEST PASSED **", UVM_NONE)
        end else begin
            `uvm_error(get_type_name(), "** UVM TEST FAIL **")
        end
    endfunction
endclass
