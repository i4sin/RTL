`timescale 1ps /1ps
`define PERIOD 10

module PatternDetector_tb();
    localparam DATA_WIDTH = 1;
    localparam OVERLAPPING_PATTERN = 2'b10;
    localparam BASE_PATTERN = 1'b1;
    localparam PATTERN = {OVERLAPPING_PATTERN, BASE_PATTERN, OVERLAPPING_PATTERN};
    localparam OVERLAPPING_PATTERN_WIDTH = $bits(OVERLAPPING_PATTERN);
    localparam BASE_PATTERN_WIDTH = $bits(BASE_PATTERN);
    localparam PATTERN_WIDTH = OVERLAPPING_PATTERN_WIDTH * 2 + BASE_PATTERN_WIDTH;

    import vunit_pkg::*;
    `include "vunit_defines.svh"

    typedef logic LogicQueue[$];
    typedef DATA_VIP::DataMasterItem #(DATA_WIDTH) DataMasterItem;
    typedef DATA_VIP::DataMasterDriver #(DATA_WIDTH) DataMasterDriver;
    typedef DATA_VIP::DataMonitor #(DATA_WIDTH) DataMonitor;
    typedef DATA_VIP::DataSlaveDriver #(DATA_WIDTH) DataSlaveDriver;
    typedef DATA_VIP::DataSlaveItem DataSlaveItem;
    typedef DATA_VIP::DataTransaction #(DATA_WIDTH) DataTransaction;

    bit clk;
    bit resetn;

    DataIf #(
        .DATA_WIDTH(DATA_WIDTH)
    ) s_data (
        .clk(clk),
        .resetn(resetn)
    );

    DataIf #(
        .DATA_WIDTH(DATA_WIDTH)
    ) m_data (
        .clk(clk),
        .resetn(resetn)
    );

    const int unsigned PATTERNS_COUNT = 2048;
    const int unsigned MAX_DELAY = 10;

    initial clk = 0;
    always #(`PERIOD / 2) clk = ~clk;

    PatternDetector #(
        .PATTERN(PATTERN),
        .WIDTH(PATTERN_WIDTH)
    ) dut (
        .s_data(s_data),
        .m_data(m_data)
    );

    task automatic initial_reset();
        int unsigned count = 3;
        resetn <= 0;
        repeat (count) @(posedge clk); 
        resetn <= 1;
        repeat (count) @(posedge clk); 
    endtask

    function automatic LogicQueue create_pattern();
        LogicQueue pattern;
        repeat (PATTERNS_COUNT) begin
            int seed = $urandom_range(0, 4);
            case (seed)
                0: pattern = append_pattern(pattern, create_random_pattern());
                1: pattern = append_pattern(pattern, create_base_pattern());
                2: pattern = append_pattern(pattern, create_overlapping_pattern());
                3: pattern = append_pattern(pattern, create_incomplete_pattern());
                4: pattern = append_pattern(pattern, create_complete_pattern());
                default: pattern = append_pattern(pattern, create_random_pattern());
            endcase
        end
        return pattern;
    endfunction

    function automatic LogicQueue create_random_pattern();
        LogicQueue random_pattern;
        std::randomize(random_pattern) with {random_pattern.size() inside {[OVERLAPPING_PATTERN_WIDTH : PATTERN_WIDTH]};};
        return random_pattern;
    endfunction

    function automatic LogicQueue create_complete_pattern();
        LogicQueue complete_pattern;
        complete_pattern = append_pattern(complete_pattern, create_incomplete_pattern());
        complete_pattern = append_pattern(complete_pattern, create_overlapping_pattern());
        return complete_pattern;
    endfunction

    function automatic LogicQueue create_incomplete_pattern();
        LogicQueue incomplete_pattern;
        incomplete_pattern = append_pattern(incomplete_pattern, create_overlapping_pattern());
        incomplete_pattern = append_pattern(incomplete_pattern, create_base_pattern());
        return incomplete_pattern;
    endfunction

    function automatic LogicQueue create_base_pattern();
        LogicQueue base_pattern;
        for (int i = 0; i < BASE_PATTERN_WIDTH; i++) base_pattern.push_back(BASE_PATTERN[i]);
        return base_pattern;
    endfunction

    function automatic LogicQueue create_overlapping_pattern();
        LogicQueue overlapping_pattern;
        for (int i = 0; i < OVERLAPPING_PATTERN_WIDTH; i++) overlapping_pattern.push_back(OVERLAPPING_PATTERN[i]);
        return overlapping_pattern;
    endfunction

    function automatic LogicQueue append_pattern(LogicQueue to, LogicQueue from);
        while (from.size()) to.push_back(from.pop_front());
        return to;
    endfunction

    task automatic drive_slave();
        DataSlaveDriver slave_driver = new(m_data);
        forever begin
            DataSlaveItem item = new();
            assert(item.randomize());
            slave_driver.drive(item);
        end
    endtask

    function automatic LogicQueue get_expected_queue(LogicQueue pattern);
        logic [PATTERN_WIDTH-1:0] buff = 0;
        LogicQueue expected_queue;
        while (pattern.size()) begin
            expected_queue.push_back(buff == PATTERN);
            buff = {buff, pattern.pop_front()};
        end
        return expected_queue;
    endfunction

    function automatic void check(logic out, logic expected);
        if (out !== expected) $error("Expected %h, but got %h", expected, out);
    endfunction

    `TEST_SUITE begin
        `TEST_CASE_SETUP begin
            initial_reset();
        end
        `TEST_CASE("test") begin
            automatic LogicQueue pattern = create_pattern();
            automatic DataMasterDriver master_driver = new(s_data);
            automatic DataMonitor monitor = new(m_data);
            fork
                forever drive_slave();
                begin
                    automatic LogicQueue expected_queue = get_expected_queue(pattern);
                    while (expected_queue.size()) begin
                        DataTransaction out;
                        monitor.get_transaction(out);
                        check(out.data, expected_queue.pop_front());
                    end
                end
            join_none
            while (pattern.size()) begin
                automatic logic current_data = pattern.pop_front();
                automatic DataMasterItem item = new();
                assert (item.randomize() with {
                    data == current_data;
                });
                master_driver.drive(item);
            end
        end
        // `WATCHDOG(10000ns)
    end
endmodule
