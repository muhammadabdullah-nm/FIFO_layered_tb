interface fifo_interface #(parameter DEPTH=8, DATA_WIDTH=8) (
  input logic clk
);

  timeunit 1ns;
  timeprecision 1ns;

  logic rst_n;
  logic w_en, r_en;
  logic [DATA_WIDTH-1:0] data_in;
  logic [DATA_WIDTH-1:0] data_out;
  logic full, empty;

  modport synchronous_fifo (
    input clk, rst_n, w_en, r_en,
    input data_in,
    output data_out,
    output full, empty
  );

//   modport fifo_test (
//     input clk,
//     output rst_n, 
//     output w_en, r_en,
//     output data_in,
//     input data_out,
//     input full, empty
//   );
endinterface : fifo_interface
