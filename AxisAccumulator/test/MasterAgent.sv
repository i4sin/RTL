class MasterAgent #(
    parameter ADD_SUBN,
    parameter DELAY_INSERT  = 0,
    parameter S_TDATA_WIDTH
) extends uvm_agent;

    `uvm_component_utils(MasterAgent#(ADD_SUBN, DELAY_INSERT, S_TDATA_WIDTH))

    MasterDriver #(
        .ADD_SUBN(ADD_SUBN),
        .DELAY_INSERT(DELAY_INSERT),
        .S_TDATA_WIDTH(S_TDATA_WIDTH)
    ) driver;

    uvm_sequencer #(AxisWord #(.TDATA_WIDTH(S_TDATA_WIDTH))) sequencer;

    MasterMonitor #(
        .ADD_SUBN(ADD_SUBN),
        .S_TDATA_WIDTH(S_TDATA_WIDTH)
    ) monitor;

    function new(string name = "MasterAgent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (get_is_active() == UVM_ACTIVE) begin
            driver = MasterDriver#(ADD_SUBN, DELAY_INSERT, S_TDATA_WIDTH)::type_id::create("driver", this);
            sequencer = uvm_sequencer#(AxisWord#(.TDATA_WIDTH(S_TDATA_WIDTH)))::type_id::create("sequencer", this);
            monitor = MasterMonitor#(ADD_SUBN, S_TDATA_WIDTH)::type_id::create("monitor", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        if (get_is_active() == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
            // monitor.input_analysis_port.connect(sequencer.seq_item_export);
        end
    endfunction
endclass
