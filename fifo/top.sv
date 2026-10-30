`include "fifo_interface.sv"
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "env.sv"
// `include "fifo.sv"
module top;
// SYSTEMVERILOG: timeunit and timeprecision specification
timeunit 1ns;
timeprecision 1ns;

// SYSTEMVERILOG: logic and bit data types
bit         clk;
parameter DEPTH=8, DATA_WIDTH=8;
// SYSTEMVERILOG:: implicit .* port connections

fifo_interface #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH)) fifoBus (clk);
synchronous_fifo  #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH)) fifo (.fif(fifoBus) );


covergroup cg1 @(posedge clk);
  c1: coverpoint fifoBus.data_in {
    bins highest = {[0:'hFFFF]};
    bins f = default;
  }
  c2: coverpoint {fifoBus.r_en, fifoBus.w_en} {
    option.at_least=3;
    bins seq[] = {[0:3]};
  }
endgroup
cg1 cover_inst=new();
    int rp_cnt=16;    
    env #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH)) objEnv;
    //--------------------------Test Cases-------------------------
    /*
        0: Reset memory
        1: Empty Test
        2: Full Test
        3: Read And Write Test
        4: Read After Write Test
        5: Read and Write Simultaneous
        6: Random Read and Write
    */
    int testCase=6;

    
    initial begin
        objEnv=new(fifoBus, rp_cnt, testCase);    
        objEnv.run();
    end


always #5 clk = ~clk;
endmodule
