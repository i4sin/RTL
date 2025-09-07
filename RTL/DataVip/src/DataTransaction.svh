class DataTransaction #(
    parameter DATA_WIDTH
);
    logic [DATA_WIDTH-1:0] data;

    function new(logic [DATA_WIDTH-1:0] data);
        this.data = data;
    endfunction
endclass
