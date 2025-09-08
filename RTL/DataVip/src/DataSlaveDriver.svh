class DataSlaveDriver #(
    parameter DATA_WIDTH
);
    typedef virtual DataIf #(DATA_WIDTH) DataVif;

    local DataVif vif;

    function new(DataVif vif);
        this.vif = vif;
    endfunction

    local task delay_item(int unsigned delay);
        vif.ready <= 0;
        repeat (delay) @(posedge vif.clk);
    endtask

    local task drive_bus();
        vif.ready <= 1;
        @(posedge vif.clk);
    endtask
    
    local task wait_for_handshake();
        while (!vif.transfer()) @(posedge vif.clk);
    endtask

    local function void deassert_ready();
        vif.ready <= 0;
    endfunction

    task drive(DataSlaveItem item);
        delay_item(item.delay);
        drive_bus();
        wait_for_handshake();
        deassert_ready();
    endtask
endclass
