`timescale 10ns/1ns

module FullAdder_tb();
    parameter string runner_cfg = "";
    FullAdderTest #(
        .DATA_WIDTH(64),
        .runner_config(runner_cfg)
    ) test ();
endmodule

module FullAdderTest;
    parameter DATA_WIDTH;
    localparam TOTAL_WORDS_COUNT = 2048;

    import vunit_pkg::*;
    `include "vunit_defines.svh"

    typedef logic LogicQueue[$];
    typedef logic [DATA_WIDTH-1:0] DataLogicQueue[$];
    typedef logic [DATA_WIDTH:0] ExpectedLogicQueue[$];

    bit clk = 0;
    initial forever #10 clk = ~clk;

    logic cin;
    logic [DATA_WIDTH-1:0] in1;
    logic [DATA_WIDTH-1:0] in2;
    logic cout;
    logic [DATA_WIDTH-1:0] out;
    
    FullAdder #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .cin(cin),
        .in1(in1),
        .in2(in2),
        .cout(cout),
        .out(out)
    );

    function automatic LogicQueue generate_cins(int count);
        LogicQueue cin_queue;
        repeat (count) begin
            logic cin;
            assert(std::randomize(cin));
            cin_queue.push_back(cin);
        end
        return cin_queue;
    endfunction

    function automatic DataLogicQueue generate_inputs(int count);
        DataLogicQueue input_queue;
        repeat (count) begin
            logic [DATA_WIDTH-1:0] in;
            assert(std::randomize(in));
            input_queue.push_back(in);
        end
        return input_queue;
    endfunction

    task drive(logic cin_stimuli, logic [DATA_WIDTH-1:0] in1_stimuli, logic [DATA_WIDTH-1:0] in2_stimuli);
        cin <= cin_stimuli;
        in1 <= in1_stimuli;
        in2 <= in2_stimuli;
        @(posedge clk);
    endtask

    function automatic ExpectedLogicQueue calculate_expected_queue(LogicQueue cin_queue, DataLogicQueue in1_queue, DataLogicQueue in2_queue);
        ExpectedLogicQueue expected_queue;
        assert (in1_queue.size() == cin_queue.size());
        assert (in1_queue.size() == in2_queue.size());
        foreach (cin_queue[i]) begin
            expected_queue.push_back(cin_queue[i] + in1_queue[i] + in2_queue[i]);
        end
        return expected_queue;
    endfunction

    task automatic check(logic [DATA_WIDTH:0] expected);
        @(posedge clk);
        if ({cout, out} !== expected) $error("Expected %x, Received %b, %x", expected, cout, out);
    endtask

    `TEST_SUITE_FROM_PARAMETER(runner_config) begin
        `TEST_CASE_SETUP begin
            cin <= 0;
            in1 <= 0;
            in2 <= 0;
        end
        `TEST_CASE("test") begin
            automatic LogicQueue cin_queue = generate_cins(TOTAL_WORDS_COUNT);
            automatic DataLogicQueue in1_queue = generate_inputs(TOTAL_WORDS_COUNT);
            automatic DataLogicQueue in2_queue = generate_inputs(TOTAL_WORDS_COUNT);
            automatic ExpectedLogicQueue expected_queue = calculate_expected_queue(cin_queue, in1_queue, in2_queue);
            fork
                forever check (expected_queue.pop_front());
            join_none
            while (expected_queue.size()) begin
                drive (cin_queue.pop_front(), in1_queue.pop_front(), in2_queue.pop_front());
            end
        end
    end
endmodule
