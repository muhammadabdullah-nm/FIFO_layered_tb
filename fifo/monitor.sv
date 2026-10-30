`timescale 1ns/1ns
class monitor #(parameter DEPTH=8, DATA_WIDTH=8); 

mailbox #(transaction #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH)) ) mbxToScoreboard;
transaction #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH)) obj;
virtual fifo_interface #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH)) mif;

function new(mailbox #(transaction #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH)))  mbxToScoreboard, virtual fifo_interface #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH)) mif);
    this.mbxToScoreboard=mbxToScoreboard;
    this.mif=mif;
    obj=new();
endfunction

task run();
    forever begin
        @(posedge mif.clk);
        obj.w_en=mif.w_en;
        obj.r_en=mif.r_en;
        obj.data_in=mif.data_in;
        obj.rst_n=mif.rst_n;
        obj.full=mif.full;
        obj.empty=mif.empty;
        @(negedge mif.clk);
        obj.data_out=mif.data_out;
        // $display("Interface has written: %d",mif.data_out);
        // $display("Monitor has written: %d",obj.data_out);
        mbxToScoreboard.put(obj.copy());
    end
endtask
    
endclass