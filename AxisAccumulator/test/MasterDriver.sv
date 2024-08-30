class MasterDriver #(
    parameter ADD_SUBN,
    parameter DELAY_INSERT  = 0,
    parameter S_TDATA_WIDTH
) extends uvm_driver #(AxisWord #(
    .TDATA_WIDTH(S_TDATA_WIDTH)
));

    local virtual AxisIf #(.TDATA_WIDTH(S_TDATA_WIDTH)) add_vif;
    local virtual AxisIf #(.TDATA_WIDTH(S_TDATA_WIDTH)) sub_vif;

    `uvm_component_utils(MasterDriver#(ADD_SUBN, DELAY_INSERT, S_TDATA_WIDTH))

    function new(string name = "MasterDriver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task initialize();
        if (ADD_SUBN) begin
            add_vif.tdata <= 0;
            add_vif.tlast <= 0;
            add_vif.tvalid <= 0;
        end else begin
            sub_vif.tdata <= 0;
            sub_vif.tlast <= 0;
            sub_vif.tvalid <= 0;
        end
    endtask

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual AxisIf #(S_TDATA_WIDTH))::get(this, "", "add_vif", add_vif))
            `uvm_fatal("NOVIF", {"add_vif virtual interface must be set for: ", get_full_name(), ".add_vif"});
        if (!uvm_config_db#(virtual AxisIf #(S_TDATA_WIDTH))::get(this, "", "sub_vif", sub_vif))
            `uvm_fatal("NOVIF", {"sub_vif virtual interface must be set for: ", get_full_name(), ".sub_vif"});
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        initialize();
        forever begin
            AxisWord #(.TDATA_WIDTH(S_TDATA_WIDTH)) word;
            seq_item_port.get_next_item(word);
            if (DELAY_INSERT) wait_before_push();
            push_Word(word);
            seq_item_port.item_done();
        end
    endtask

    task automatic wait_before_push();
        int random_wait = $urandom_range(0, 100);
        if (ADD_SUBN) begin
            add_vif.tdata <= $urandom();
            add_vif.tvalid <= 0;
            add_vif.tlast <= $urandom_range(0, 1);
        end else begin
            sub_vif.tdata <= $urandom();
            sub_vif.tvalid <= 0;
            sub_vif.tlast <= $urandom_range(0, 1);
        end
        repeat (random_wait) @(posedge add_vif.aclk);
    endtask

    task automatic push_Word(AxisWord#(.TDATA_WIDTH(S_TDATA_WIDTH)) word);
        if (ADD_SUBN) begin
            add_vif.tdata <= word.tdata;
            add_vif.tlast <= word.tlast;
            add_vif.tvalid <= 1;
        end else begin
            sub_vif.tdata <= word.tdata;
            sub_vif.tlast <= word.tlast;
            sub_vif.tvalid <= 1;
        end
        @(posedge add_vif.aclk);
        while (!(ADD_SUBN ? add_vif.tready : sub_vif.tready)) begin
            @(posedge add_vif.aclk);
        end
    endtask
endclass
