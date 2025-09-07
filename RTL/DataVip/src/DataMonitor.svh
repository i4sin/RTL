class DataMonitor #(
    parameter DATA_WIDTH
);
    typedef virtual DataIf #(DATA_WIDTH) DataVif;
    typedef DataTransaction #(DATA_WIDTH) DataTransaction;

    local DataVif vif;

    function new(DataVif vif);
        this.vif = vif;
    endfunction

    task get_transaction(output DataTransaction tr);
        do begin
            @(posedge vif.clk);
        end while (!vif.transfer());
        tr = new(vif.data);
    endtask
endclass
