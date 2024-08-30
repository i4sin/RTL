class SlaveAgent #(
    parameter DELAY_INSERT  = 0,
    parameter M_TDATA_WIDTH
) extends uvm_agent;

    SlaveDriver #(
        .DELAY_INSERT(DELAY_INSERT),
        .M_TDATA_WIDTH(M_TDATA_WIDTH)
    ) driver;

    SlaveMonitor #(.M_TDATA_WIDTH(M_TDATA_WIDTH)) monitor;

    `uvm_component_utils(SlaveAgent#(DELAY_INSERT, M_TDATA_WIDTH))

    function new(string name = "SlaveAgent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (get_is_active() == UVM_ACTIVE) begin
            driver = SlaveDriver#(DELAY_INSERT, M_TDATA_WIDTH)::type_id::create("driver", this);
            monitor = SlaveMonitor#(.M_TDATA_WIDTH(M_TDATA_WIDTH))::type_id::create("monitor", this);
        end
    endfunction
endclass
