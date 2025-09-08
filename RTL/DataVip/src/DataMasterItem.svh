class DataMasterItem #(
    parameter DATA_WIDTH
);
    local const int unsigned MAX_DELAY = 10;

    rand int unsigned delay;
    rand logic [DATA_WIDTH-1:0] data;

    constraint c_delay {delay inside {[0 : MAX_DELAY]};}
endclass
