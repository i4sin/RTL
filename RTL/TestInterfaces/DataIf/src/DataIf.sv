interface DataIf #(
    parameter DATA_WIDTH
) (
    input clk,
    input resetn
);
    logic valid;
    logic [DATA_WIDTH-1:0] data;
    logic ready;

    modport master(input clk, resetn, valid, data, output ready);
    modport slave(input clk, resetn, output valid, data, input ready);

    function bit transfer();
        return valid & ready;
    endfunction
endinterface
