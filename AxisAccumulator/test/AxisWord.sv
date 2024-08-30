class AxisWord #(
    parameter TDATA_WIDTH
) extends uvm_sequence_item;
    rand logic [TDATA_WIDTH-1:0] tdata;
    logic tlast;

    `uvm_object_utils_begin(AxisWord#(TDATA_WIDTH))
        `uvm_field_int(tdata, UVM_DEFAULT)
        `uvm_field_int(tlast, UVM_DEFAULT)
    `uvm_object_utils_end

    virtual function string convert2str();
        return $sformatf("Random AxisWord is: %p", tdata);
    endfunction

    function new(string name = "AxisWord");
        super.new(name);
    endfunction
endclass
