class DataMasterDriver #(
    parameter DATA_WIDTH
);
    typedef virtual DataIf #(DATA_WIDTH) DataVif;
    typedef DataMasterItem #(DATA_WIDTH) DataMasterItem;

    local DataVif vif;

    function new(DataVif vif);
        this.vif = vif;
    endfunction

    local task delay_item(int unsigned delay);
        vif.valid <= 0;
        repeat (delay) @(posedge vif.clk);
    endtask

    local task drive_bus(DataMasterItem item);
        vif.valid <= 1;
        vif.data <= item.data;
        @(posedge vif.clk);
    endtask

    local task wait_for_handshake();
        while (!vif.transfer()) @(posedge vif.clk);
    endtask

    local function void deassert_valid();
        vif.valid <= 0;
    endfunction

    task drive(DataMasterItem item);
        delay_item(item.delay);
        drive_bus(item);
        wait_for_handshake();
        deassert_valid();
    endtask
endclass