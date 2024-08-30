class RandomPacket #(
    parameter S_TDATA_WIDTH
) extends uvm_sequence #(AxisWord #(S_TDATA_WIDTH));
    `uvm_object_utils(RandomPacket#(S_TDATA_WIDTH))

    AxisWord #(S_TDATA_WIDTH) random_word;
    rand int packet_length;

    constraint c_rnd_pkt_len {packet_length inside {1, 100};}

    function new(string name = "RandomPacket");
        super.new(name);
    endfunction

    virtual task body();
        for (int i = 0; i < packet_length; i++) begin
            AxisWord #(
                .TDATA_WIDTH(S_TDATA_WIDTH)
            ) random_word = AxisWord#(
                .TDATA_WIDTH(S_TDATA_WIDTH)
            )::type_id::create(
                "random_word"
            );
            start_item(random_word);
            std::randomize(random_word.tdata);
            random_word.tlast = (i == packet_length - 1);
            `uvm_info("SEQ", $sformatf("Genrate new random AxisWord: %s", random_word.convert2str()), UVM_HIGH)
            finish_item(random_word);
        end
        `uvm_info("SEQ", $sformatf("Done generation of %0d random Words", packet_length), UVM_HIGH)
    endtask
endclass
