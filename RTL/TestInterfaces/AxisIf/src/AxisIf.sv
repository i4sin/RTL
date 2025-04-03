interface AxisIf #(
    parameter DATA_WIDTH
) (
    input aclk,
    input aresetn
);
    logic tvalid;
    logic tready;
    logic [DATA_WIDTH-1:0] tdata;
    logic [DATA_WIDTH/8-1:0] tkeep;
    logic tlast;

    modport master(input aclk, aresetn, output tvalid, tdata, tkeep, tlast, input tready);
    modport slave(input aclk, aresetn, input tvalid, tdata, tkeep, tlast, output tready);

    function bit transfer();
        return tvalid & tready;
    endfunction

    function bit last_transfer();
        return tvalid & tlast & tready;
    endfunction
endinterface
