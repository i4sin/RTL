class SlaveDriver #(
    parameter DELAY_INSERT  = 0,
    parameter M_TDATA_WIDTH
) extends uvm_driver;

    local virtual AxisIf #(.TDATA_WIDTH(M_TDATA_WIDTH)) m_vif;

    `uvm_component_utils(SlaveDriver#(DELAY_INSERT, M_TDATA_WIDTH))

    function new(string name = "SlaveDriver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task initialize();
        m_vif.tready <= 0;
    endtask

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual AxisIf #(M_TDATA_WIDTH))::get(this, "", "m_vif", m_vif))
            `uvm_fatal("NOVIF", {"m_vif virtual interface must be set for: ", get_full_name(), ".m_vif"});
    endfunction

    virtual task run_phase(uvm_phase phase);
        initialize();
        forever begin
            if (DELAY_INSERT) begin
                if ($urandom_range(0, 1)) begin
                    logic random_ready;
                    $urandom(random_ready);
                    m_vif.tready <= random_ready;
                end else begin
                    while (!m_vif.tvalid) @(posedge m_vif.aclk);
                    m_vif.tready <= 1;
                end
            end else begin
                m_vif.tready <= 1;
            end
            @(posedge m_vif.aclk);
        end
    endtask

endclass
