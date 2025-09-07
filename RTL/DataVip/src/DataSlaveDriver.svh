class DataSlaveDriver #(
    parameter DATA_WIDTH
);
    typedef virtual DataIf #(DATA_WIDTH) DataVif;

    local DataVif vif;
    local const int unsigned MAX_DELAY = 10;

    function new(DataVif vif);
        this.vif = vif;
    endfunction

    local task delay();
        vif.ready <= 0;
        repeat ($urandom_range(0, MAX_DELAY)) @(posedge vif.clk);
    endtask

    local task drive_bus();
        vif.ready <= 1;
    endtask
    
    local task wait_for_handshake();
        do begin
            @(posedge vif.clk);
        end while (!vif.transfer());
    endtask

    local function void deassert_ready();
        vif.valid <= 0;
    endfunction

    task drive();
        delay();
        drive_bus();
        wait_for_handshake();
        deassert_ready();
    endtask
endclass