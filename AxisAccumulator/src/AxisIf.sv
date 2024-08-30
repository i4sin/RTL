interface AxisIf #(
    parameter TDATA_WIDTH
) (
    input aclk,
    input aresetn
);
    logic tvalid;
    logic tready;
    logic [TDATA_WIDTH-1:0] tdata;
    logic tlast;
    modport slave(input aclk, aresetn, tvalid, tdata, tlast, output tready);
    modport master(output tvalid, tdata, tlast, input aclk, aresetn, tready);
endinterface
