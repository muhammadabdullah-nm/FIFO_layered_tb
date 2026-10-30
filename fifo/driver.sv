`timescale 1ns/1ns
class driver #(parameter DEPTH=8, DATA_WIDTH=8);
transaction #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH)) obj;
mailbox #(transaction #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH))) mbxFromGen;

virtual fifo_interface #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH)) mif;
int transRec;

function new(mailbox #(transaction #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH))) mbxFromGen, virtual fifo_interface #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH)) mif);
    this.mbxFromGen=mbxFromGen;
    this.mif=mif;
endfunction

task run();
    forever begin
        mbxFromGen.get(obj);
        //--------------------------------------------
        @(negedge mif.clk);
        mif.w_en<=obj.w_en;
        mif.r_en<=obj.r_en;
        mif.data_in<=obj.data_in;
        mif.rst_n<=obj.rst_n;
        
//         obj.display();
        transRec++;
         $display("Trans at driver %d",transRec);
    end
endtask

// task resetFIFO();
//     //---------------FIFO RESET------------------
//         @(posedge mif.clk);
//         mif.rst_n=0;
//         @(posedge mif.clk);
//         mif.rst_n=1;
// endtask
endclass