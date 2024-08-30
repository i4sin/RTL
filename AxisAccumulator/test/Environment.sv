class Environment #(
    parameter DELAY_INSERT = 0,
    parameter S_TDATA_WIDTH,
    parameter M_TDATA_WIDTH,
    parameter SINGLE_WORD_OUTPUT
) extends uvm_env;

    `uvm_component_utils(Environment#(DELAY_INSERT, S_TDATA_WIDTH, M_TDATA_WIDTH, SINGLE_WORD_OUTPUT))

    MasterAgent #(
        .ADD_SUBN(1),
        .DELAY_INSERT(DELAY_INSERT),
        .S_TDATA_WIDTH(S_TDATA_WIDTH)
    ) add_master;

    MasterAgent #(
        .ADD_SUBN(0),
        .DELAY_INSERT(DELAY_INSERT),
        .S_TDATA_WIDTH(S_TDATA_WIDTH)
    ) sub_master;

    SlaveAgent #(
        .DELAY_INSERT(DELAY_INSERT),
        .M_TDATA_WIDTH(M_TDATA_WIDTH)
    ) slave;

    Scoreboard #(
        .S_TDATA_WIDTH(S_TDATA_WIDTH),
        .M_TDATA_WIDTH(M_TDATA_WIDTH),
        .SINGLE_WORD_OUTPUT(SINGLE_WORD_OUTPUT)
    ) scoreboard;

    function new(string name = "Environment", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        add_master = MasterAgent#(
            .ADD_SUBN(1),
            .DELAY_INSERT(DELAY_INSERT),
            .S_TDATA_WIDTH(S_TDATA_WIDTH)
        )::type_id::create(
            "add_master", this
        );

        sub_master = MasterAgent#(
            .ADD_SUBN(0),
            .DELAY_INSERT(DELAY_INSERT),
            .S_TDATA_WIDTH(S_TDATA_WIDTH)
        )::type_id::create(
            "sub_master", this
        );

        slave = SlaveAgent#(
            .DELAY_INSERT(DELAY_INSERT),
            .M_TDATA_WIDTH(M_TDATA_WIDTH)
        )::type_id::create(
            "slave", this
        );

        scoreboard = Scoreboard#(S_TDATA_WIDTH, M_TDATA_WIDTH, SINGLE_WORD_OUTPUT)::type_id::create("scoreboard", this);

    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        add_master.monitor.add_analysis_port.connect(scoreboard.add_analysis_port);
        sub_master.monitor.sub_analysis_port.connect(scoreboard.sub_analysis_port);
        slave.monitor.output_analysis_port.connect(scoreboard.out_analysis_port);
    endfunction

endclass
