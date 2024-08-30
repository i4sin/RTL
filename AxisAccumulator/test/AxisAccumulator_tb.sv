`timescale 1ns / 1ps
`define PERIOD 20

import vunit_pkg::*;
`include "vunit_defines.svh"

module Divisible_adder_width_tb;
    parameter string runner_cfg = "";
    AxisAccumulator_tb #(
        .S_TDATA_WIDTH(8),
        .ADDER_WIDTH(4),
        .M_TDATA_WIDTH(32),
        .SINGLE_WORD_OUTPUT(0),
        .RANDOM_PACKETS_COUNT(512),
        .runner_config(runner_cfg)
    ) test ();
endmodule

module Divisible_adder_width_single_output_tb;
    parameter string runner_cfg = "";
    AxisAccumulator_tb #(
        .S_TDATA_WIDTH(8),
        .ADDER_WIDTH(2),
        .M_TDATA_WIDTH(16),
        .SINGLE_WORD_OUTPUT(1),
        .RANDOM_PACKETS_COUNT(512),
        .runner_config(runner_cfg)
    ) test ();
endmodule

module NDivisible_adder_width_tb;
    parameter string runner_cfg = "";
    AxisAccumulator_tb #(
        .S_TDATA_WIDTH(8),
        .ADDER_WIDTH(7),
        .M_TDATA_WIDTH(16),
        .SINGLE_WORD_OUTPUT(0),
        .RANDOM_PACKETS_COUNT(512),
        .runner_config(runner_cfg)
    ) test ();
endmodule

module NDivisible_adder_width_single_output_tb;
    parameter string runner_cfg = "";
    AxisAccumulator_tb #(
        .S_TDATA_WIDTH(8),
        .ADDER_WIDTH(3),
        .M_TDATA_WIDTH(16),
        .SINGLE_WORD_OUTPUT(1),
        .RANDOM_PACKETS_COUNT(512),
        .runner_config(runner_cfg)
    ) test ();
endmodule

module Same_width_tb;
    parameter string runner_cfg = "";
    AxisAccumulator_tb #(
        .S_TDATA_WIDTH(16),
        .ADDER_WIDTH(16),
        .M_TDATA_WIDTH(16),
        .SINGLE_WORD_OUTPUT(0),
        .RANDOM_PACKETS_COUNT(512),
        .runner_config(runner_cfg)
    ) test ();
endmodule

module Same_width_single_output_tb;
    parameter string runner_cfg = "";
    AxisAccumulator_tb #(
        .S_TDATA_WIDTH(8),
        .ADDER_WIDTH(8),
        .M_TDATA_WIDTH(8),
        .SINGLE_WORD_OUTPUT(1),
        .RANDOM_PACKETS_COUNT(512),
        .runner_config(runner_cfg)
    ) test ();
endmodule

module Bigger_adder_width_tb;
    parameter string runner_cfg = "";
    AxisAccumulator_tb #(
        .S_TDATA_WIDTH(8),
        .ADDER_WIDTH(16),
        .M_TDATA_WIDTH(32),
        .SINGLE_WORD_OUTPUT(0),
        .RANDOM_PACKETS_COUNT(512),
        .runner_config(runner_cfg)
    ) test ();
endmodule

module Bigger_adder_width_single_output_tb;
    parameter string runner_cfg = "";
    AxisAccumulator_tb #(
        .S_TDATA_WIDTH(8),
        .ADDER_WIDTH(16),
        .M_TDATA_WIDTH(32),
        .SINGLE_WORD_OUTPUT(1),
        .RANDOM_PACKETS_COUNT(512),
        .runner_config(runner_cfg)
    ) test ();
endmodule

module AxisAccumulator_tb ();
    import TestBench_classes::*;

    parameter S_TDATA_WIDTH = 0;
    parameter ADDER_WIDTH = 0;
    parameter M_TDATA_WIDTH = 0;
    parameter SINGLE_WORD_OUTPUT = 0;
    parameter RANDOM_PACKETS_COUNT = 0;

    typedef logic [S_TDATA_WIDTH-1:0] s_axis_data_array[RANDOM_PACKETS_COUNT][];

    bit clk;
    logic reset;

    initial clk = 0;
    always #(`PERIOD / 2) clk = ~clk;

    AxisIf #(
        .TDATA_WIDTH(S_TDATA_WIDTH)
    ) s_axis_add (
        clk,
        !reset
    );
    AxisIf #(
        .TDATA_WIDTH(S_TDATA_WIDTH)
    ) s_axis_sub (
        clk,
        !reset
    );
    AxisIf #(
        .TDATA_WIDTH(M_TDATA_WIDTH)
    ) m_axis (
        clk,
        !reset
    );

    AxisAccumulator #(
        .ADDER_WIDTH(ADDER_WIDTH),
        .SINGLE_WORD_OUTPUT(SINGLE_WORD_OUTPUT)
    ) axis_accumulator (
        .s_axis_add(s_axis_add),
        .s_axis_sub(s_axis_sub),
        .m_axis(m_axis)
    );

    SlaveDriver #(.TDATA_WIDTH(S_TDATA_WIDTH)) add_data_driver;
    SlaveDriver #(.TDATA_WIDTH(S_TDATA_WIDTH)) sub_data_driver;
    MasterDriver #(.TDATA_WIDTH(M_TDATA_WIDTH)) master_driver;
    OutputChecker #(S_TDATA_WIDTH) accumulator_checker;

    function automatic s_axis_data_array generate_random_data();
        logic [S_TDATA_WIDTH-1:0] random_packet[RANDOM_PACKETS_COUNT][];
        int random_pkt_length = $urandom_range(1, 100);
        foreach (random_packet[i]) begin
            random_packet[i] = new[random_pkt_length];
            random_pkt_length = $urandom_range(1, 100);
        end
        std::randomize(random_packet);
        return random_packet;
    endfunction

    task automatic check_required_clks(logic [S_TDATA_WIDTH-1:0] add_packet[RANDOM_PACKETS_COUNT][],
                                       logic [S_TDATA_WIDTH-1:0] sub_packet[RANDOM_PACKETS_COUNT][],
                                       ref bit finished_add, bit finished_sub);
        int required_clks = 0;
        int elapsed_clks = 0;
        for (int i = 0; i < RANDOM_PACKETS_COUNT; i++) begin
            required_clks += add_packet[i].size();
            required_clks += sub_packet[i].size();
        end
        required_clks = int'($ceil(real'(M_TDATA_WIDTH) / ADDER_WIDTH)) * required_clks;
        while (!finished_add || !finished_sub) begin
            elapsed_clks++;
            @(posedge clk);
        end
        assert (elapsed_clks <= required_clks + 10)
        else
            $error(
                "elapsed clocks are more than required! elapsed_clks: %d, required_clks: %d",
                elapsed_clks,
                required_clks
            );
        assert (elapsed_clks >= required_clks - 10)
        else
            $error(
                "elapsed clocks are less than required_clks-10! elapsed_clks: %d, required_clks: %d",
                elapsed_clks,
                required_clks
            );
    endtask

    task automatic random_test_module(logic delay_insertion);
        int required_clks = 0;
        bit finished_add = 0;
        bit finished_sub = 0;

        logic [S_TDATA_WIDTH-1:0] random_add_packet[RANDOM_PACKETS_COUNT][];
        logic [S_TDATA_WIDTH-1:0] random_sub_packet[RANDOM_PACKETS_COUNT][];

        sub_data_driver.set_delay_insertion(delay_insertion);
        add_data_driver.set_delay_insertion(delay_insertion);
        master_driver.set_delay_insertion(delay_insertion);

        random_add_packet = generate_random_data();
        random_sub_packet = generate_random_data();

        fork
            begin
                master_driver.generate_m_tready(finished_add, finished_sub);
            end
            begin
                for (int data_counter = 0; data_counter < RANDOM_PACKETS_COUNT; data_counter++) begin
                    add_data_driver.push_packet(random_add_packet[data_counter]);
                end
                finished_add = 1;
            end
            begin
                for (int data_counter = 0; data_counter < RANDOM_PACKETS_COUNT; data_counter++) begin
                    sub_data_driver.push_packet(random_sub_packet[data_counter]);
                end
                finished_sub = 1;
            end
            begin
                for (int data_counter = 0; data_counter < RANDOM_PACKETS_COUNT; data_counter++) begin
                    accumulator_checker.check(random_add_packet[data_counter], random_sub_packet[data_counter]);
                end
            end
            begin
                if (!delay_insertion)
                    check_required_clks(random_add_packet, random_sub_packet, finished_add, finished_sub);
            end
        join
    endtask

    `TEST_SUITE_FROM_PARAMETER(runner_config) begin
        `TEST_SUITE_SETUP begin
            $display("Running test suite setup code");

            add_data_driver = new(s_axis_add);
            sub_data_driver = new(s_axis_sub);

            if (SINGLE_WORD_OUTPUT) begin
                automatic SingleWordOutputChecker #(S_TDATA_WIDTH, M_TDATA_WIDTH) output_checker = new(m_axis);
                accumulator_checker = output_checker;
            end else begin
                automatic MultiWordOutputChecker #(S_TDATA_WIDTH, M_TDATA_WIDTH) output_checker = new(m_axis);
                accumulator_checker = output_checker;
            end
            master_driver = new(m_axis);
        end

        `TEST_CASE_SETUP begin
            $display("Running random test case setup code");

            reset = 1;
            add_data_driver.initialize();
            sub_data_driver.initialize();
            master_driver.initialize();
            repeat (3) @(posedge clk);
            reset = 0;
            repeat (3) @(posedge clk);
        end

        `TEST_CASE("random_test") begin
            random_test_module(.delay_insertion(1));
        end

        `TEST_CASE("all_m_tready_random_test") begin
            random_test_module(.delay_insertion(0));
        end

        `TEST_CASE_CLEANUP begin
            repeat (10) @(posedge clk);
            $display("Cleaning up after a test case");
        end

        `TEST_SUITE_CLEANUP begin
            $display("Cleaning up after running the complete test suite");
        end
    end

    `WATCHDOG(100000000ns)
endmodule
