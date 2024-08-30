class PacketSequence #(
    parameter S_TDATA_WIDTH,
    parameter MAX_PACKETS_COUNT
) extends uvm_sequence #(RandomPacket #(S_TDATA_WIDTH));

    `uvm_object_utils(PacketSequence#(S_TDATA_WIDTH, MAX_PACKETS_COUNT));

    function new(string name = "PacketSequence");
        super.new(name);
    endfunction

    rand int packets_count;
    constraint c_packets_count_limit {packets_count inside {1, MAX_PACKETS_COUNT};}

    virtual task body();
        for (int i = 0; i < packets_count; i++) begin
            RandomPacket #(S_TDATA_WIDTH) random_packet = RandomPacket#(S_TDATA_WIDTH)::type_id::create(
                "random_packet"
            );
            start_item(random_packet);
            // random_packet.set_item_context(this, MasterAgent.sequencer);
            std::randomize(random_packet.packet_length);
            // random_packet.set_starting_phase(get_starting_phase());
            // random_packet.start(MasterAgent.sequencer, this);
            finish_item(random_packet);
        end
        `uvm_info("SEQ", $sformatf("Done generation of %0d random packets", packets_count), UVM_HIGH)
    endtask
endclass
