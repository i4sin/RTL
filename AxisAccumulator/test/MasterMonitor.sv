class MasterMonitor #(
    parameter ADD_SUBN,
    parameter S_TDATA_WIDTH
) extends uvm_monitor;

    `uvm_component_utils(MasterMonitor#(ADD_SUBN, S_TDATA_WIDTH))
    uvm_analysis_port #(AxisWord #(.TDATA_WIDTH(S_TDATA_WIDTH))) add_analysis_port;
    uvm_analysis_port #(AxisWord #(.TDATA_WIDTH(S_TDATA_WIDTH))) sub_analysis_port;

    local virtual AxisIf #(.TDATA_WIDTH(S_TDATA_WIDTH)) add_vif;
    local virtual AxisIf #(.TDATA_WIDTH(S_TDATA_WIDTH)) sub_vif;

    local AxisWord #(.TDATA_WIDTH(S_TDATA_WIDTH)) input_word;

    function new(string name = "MasterMonitor", uvm_component parent = null);
        super.new(name, parent);
        input_word = new();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual AxisIf #(S_TDATA_WIDTH))::get(this, "", "add_vif", add_vif))
            `uvm_fatal("NOVIF", {"add_vif virtual interface must be set for: ", get_full_name(), ".add_vif"});
        if (!uvm_config_db#(virtual AxisIf #(S_TDATA_WIDTH))::get(this, "", "sub_vif", sub_vif))
            `uvm_fatal("NOVIF", {"sub_vif virtual interface must be set for: ", get_full_name(), ".sub_vif"});
        add_analysis_port = new("add_analysis_port", this);
        sub_analysis_port = new("sub_analysis_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            wait (add_vif.aresetn);
            @(posedge add_vif.aclk);
            if (ADD_SUBN) begin
                input_word.tdata = add_vif.tdata;
                input_word.tlast = add_vif.tlast;
                add_analysis_port.write(input_word);
            end else begin
                input_word.tdata = sub_vif.tdata;
                input_word.tlast = sub_vif.tlast;
                sub_analysis_port.write(input_word);
            end
        end
    endtask

endclass
