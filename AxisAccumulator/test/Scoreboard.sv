`uvm_analysis_imp_decl(_add)
`uvm_analysis_imp_decl(_sub)
`uvm_analysis_imp_decl(_out)

class Scoreboard #(
    parameter S_TDATA_WIDTH,
    parameter M_TDATA_WIDTH,
    parameter SINGLE_WORD_OUTPUT
) extends uvm_scoreboard;

    typedef Scoreboard#(S_TDATA_WIDTH, M_TDATA_WIDTH, SINGLE_WORD_OUTPUT) ParameterizedScoreboard_t;

    `uvm_component_utils(ParameterizedScoreboard_t)

    uvm_analysis_imp_add #(AxisWord #(.TDATA_WIDTH(S_TDATA_WIDTH)), ParameterizedScoreboard_t) add_analysis_port;
    uvm_analysis_imp_sub #(AxisWord #(.TDATA_WIDTH(S_TDATA_WIDTH)), ParameterizedScoreboard_t) sub_analysis_port;
    uvm_analysis_imp_out #(AxisWord #(.TDATA_WIDTH(M_TDATA_WIDTH)), ParameterizedScoreboard_t) out_analysis_port;

    local virtual AxisIf #(.TDATA_WIDTH(S_TDATA_WIDTH)) add_vif;
    local virtual AxisIf #(.TDATA_WIDTH(S_TDATA_WIDTH)) sub_vif;
    local virtual AxisIf #(.TDATA_WIDTH(M_TDATA_WIDTH)) m_vif;

    int sbd_error = 0;

    AxisWord #(S_TDATA_WIDTH) add_words[$];
    AxisWord #(S_TDATA_WIDTH) sub_words[$];
    AxisWord #(M_TDATA_WIDTH) output_words[$];

    function new(string name = "Scoreboard", uvm_component parent = null);
        super.new(name, parent);
        add_analysis_port = new("add_analysis_port", this);
        sub_analysis_port = new("sub_analysis_port", this);
        out_analysis_port = new("out_analysis_port", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual AxisIf #(S_TDATA_WIDTH))::get(this, "", "add_vif", add_vif))
            `uvm_fatal("NOVIF", {"add_vif virtual interface must be set for: ", get_full_name(), ".add_vif"});
        if (!uvm_config_db#(virtual AxisIf #(S_TDATA_WIDTH))::get(this, "", "sub_vif", sub_vif))
            `uvm_fatal("NOVIF", {"sub_vif virtual interface must be set for: ", get_full_name(), ".sub_vif"});
        if (!uvm_config_db#(virtual AxisIf #(M_TDATA_WIDTH))::get(this, "", "m_vif", m_vif))
            `uvm_fatal("NOVIF", {"m_vif virtual interface must be set for: ", get_full_name(), ".m_vif"});
    endfunction

    virtual function void write_add(input AxisWord #(S_TDATA_WIDTH) word);
        add_words.push_back(word);
    endfunction

    virtual function void write_sub(input AxisWord #(S_TDATA_WIDTH) word);
        sub_words.push_back(word);
    endfunction

    virtual function void write_out(input AxisWord #(M_TDATA_WIDTH) word);
        output_words.push_back(word);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        if (SINGLE_WORD_OUTPUT) begin
            check_single_word_output();
        end else begin
            check_multi_word_output();
        end
    endtask

    task check_multi_word_output();  //todo adding tlast checking mechanism and associative array resetion
        logic [S_TDATA_WIDTH-1:0] current_add, current_sub;
        logic [M_TDATA_WIDTH-1:0] exp_add, exp_sub, prev_result;
        logic was_add = 0;
        logic zero_flag_add = 0;
        logic special_case_occurunce = 0;
        while (add_words.size() || sub_words.size()) begin
            @(posedge m_vif.aclk);
            while (!(m_vif.tvalid && m_vif.tready)) begin
                @(posedge m_vif.aclk);
            end

            special_case_occurunce = (exp_add == exp_sub) | special_case_occurunce;
            if (special_case_occurunce) begin
                if (add_words.size()) add_words.pop_front();
                else sub_words.pop_front();
                continue;
            end

            current_add = add_words.size() ? add_words[0].tdata : 0;
            current_sub = sub_words.size() ? sub_words[0].tdata : 0;
            zero_flag_add = !add_words.size();
            exp_add = prev_result + current_add;
            exp_sub = prev_result + ~{{(M_TDATA_WIDTH - S_TDATA_WIDTH) {0}}, current_sub} + 1;

            assert (((m_vif.tdata == exp_add) || (m_vif.tdata == exp_sub)) && m_vif.tvalid)
            else begin
                `uvm_error("SCBRD", $sformatf(
                           "accumulation wasn't done correctly m_tdata: %h, prev_result: %h, exp_add: %h, exp_sub: %h, current_add: %h, current_sub: %h, was_add: %b, s_add: %h, s_sub: %h",
                           m_vif.tdata,
                           prev_result,
                           exp_add,
                           exp_sub,
                           current_add,
                           current_sub,
                           was_add,
                           add_words.size(),
                           sub_words.size()
                           ))
                sbd_error = 1;
            end

            was_add = (m_vif.tdata == exp_add && !zero_flag_add);
            if (was_add) add_words.pop_front();
            else sub_words.pop_front();
            prev_result = was_add ? exp_add : exp_sub;
        end
    endtask

    task check_single_word_output();
        logic [M_TDATA_WIDTH-1:0] exp_val = 0;
        foreach (add_words[i]) begin
            exp_val += add_words[i].tdata;
        end
        foreach (sub_words[i]) begin
            exp_val = exp_val + ~{{(M_TDATA_WIDTH - S_TDATA_WIDTH) {0}}, sub_words[i].tdata} + 1;
        end
        @(posedge m_vif.aclk);
        while (!(m_vif.tvalid && m_vif.tready && m_vif.tlast)) begin
            @(posedge m_vif.aclk);
        end
        assert (m_vif.tdata == exp_val)
        else begin
            `uvm_error("SCBRD", $sformatf(
                       "accumulation wasn't done correctly; m_tdata: %h, exp_val: %h", m_vif.tdata, exp_val))
            sbd_error = 1;
        end
    endtask

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Reporting scoreboard information...\n%s", this.sprint()), UVM_LOW)
    endfunction
endclass
