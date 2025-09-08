class DataSlaveItem;
    local const int unsigned MAX_DELAY = 10;
    rand int unsigned delay;
    constraint c_delay {delay inside {[0 : MAX_DELAY]};}
endclass
