class SlaveMonitor #(
    parameter M_TDATA_WIDTH
) extends uvm_monitor;

    `uvm_component_utils(SlaveMonitor#(M_TDATA_WIDTH))
    uvm_analysis_port #(AxisWord #(M_TDATA_WIDTH)) output_analysis_port;
    AxisWord #(.TDATA_WIDTH(M_TDATA_WIDTH)) output_word;

    local virtual AxisIf #(.TDATA_WIDTH(M_TDATA_WIDTH)) m_vif;

    function new(string name = "SlaveMonitor", uvm_component parent = null);
        super.new(name, parent);
        output_analysis_port = new("output_analysis_port", this);
        output_word = new();
    endfunction

    function void build_phase(uvm_phase phase);
        if (!uvm_config_db#(virtual AxisIf #(M_TDATA_WIDTH))::get(this, "", "m_vif", m_vif))
            `uvm_fatal("NOVIF", {"m_vif virtual interface must be set for: ", get_full_name(), ".m_vif"});
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            wait (m_vif.aresetn);
            @(posedge m_vif.aclk);
            output_word.tdata = m_vif.tdata;
            output_word.tlast = m_vif.tlast;
            output_analysis_port.write(output_word);
        end
    endtask

    virtual function void report_phase(uvm_phase phase);
        //todo
    endfunction
endclass
