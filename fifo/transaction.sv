`timescale 1ns/1ns
class transaction #(parameter DEPTH=8, DATA_WIDTH=8);
    rand bit w_en;
    rand bit r_en;
    randc bit [DATA_WIDTH-1:0] data_in; 
    logic [DATA_WIDTH-1:0] data_out;
    logic full, empty;
    bit rst_n;

    function new(input logic w_en=0,input logic r_en=0, input logic [DATA_WIDTH-1:0] data_in=0, input bit rst_n=0);
        this.w_en=w_en;
        this.rst_n=rst_n;
        this.r_en=r_en;
        this.data_in=data_in;
    endfunction

    function void display();
        $display("w_en = %d, r_en=%d, data_in= %d, full= %d, empty= %d, rst_n= %d", w_en, r_en, data_in, full, empty, rst_n);
    endfunction

    function transaction #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH))  copy();
        copy    = new();
        copy.w_en  = this.w_en;
        copy.r_en  = this.r_en;
        copy.rst_n  = this.rst_n;
        copy.data_in = this.data_in;
        copy.data_out = this.data_out;
        copy.full = this.full;
        copy.empty = this.empty;
    endfunction

    // constraint c1 {w_en!=r_en;}

endclass