class DataMasterDriver #(
    parameter DATA_WIDTH
);
    typedef virtual DataIf #(DATA_WIDTH) DataVif;
    typedef DataMasterItem #(DATA_WIDTH) DataMasterItem;

    local DataVif vif;
    local const int unsigned MAX_DELAY = 10;

    function new(DataVif vif);
        this.vif = vif;
    endfunction

    local task delay_item();
        vif.valid <= 0;
        repeat ($urandom_range(0, MAX_DELAY)) @(posedge vif.clk);
    endtask

    local task drive_bus(DataMasterItem item);
        vif.valid <= 1;
        vif.data <= item.data;
    endtask
    
    local task wait_for_handshake();
        do begin
            @(posedge vif.clk);
        end while (!vif.transfer());
    endtask

    local function void deassert_valid();
        vif.valid <= 0;
    endfunction

    task drive(DataMasterItem item);
        delay_item();
        drive_bus(item);
        wait_for_handshake();
        deassert_valid();
    endtask
endclass