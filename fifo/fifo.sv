module synchronous_fifo #(parameter DEPTH=8, DATA_WIDTH=8) (
  fifo_interface fif
);
  
  parameter PTR_WIDTH = $clog2(DEPTH);
  reg [PTR_WIDTH:0] w_ptr, r_ptr; // addition bit to detect full/empty condition
  reg [DATA_WIDTH-1:0] fifo[DEPTH];
  reg wrap_around;
  
  // Set Default values on reset.
  always@(posedge fif.clk, negedge fif.rst_n) begin
    if(!fif.rst_n) begin
      w_ptr <= 0; r_ptr <= 0;
      fif.data_out <= 0;
    end
  end
  
  // To write data to FIFO
  always@(posedge fif.clk) begin
    if(fif.w_en & !fif.full)begin
      fifo[w_ptr[PTR_WIDTH-1:0]] <= fif.data_in;
      w_ptr <= w_ptr + 1;
    end
  end
  
  // To read data from FIFO
  always@(posedge fif.clk) begin
    if(fif.r_en & !fif.empty) begin
      fif.data_out <= fifo[r_ptr[PTR_WIDTH-1:0]];
      r_ptr <= r_ptr + 1;
    end
  end
  
  assign wrap_around = w_ptr[PTR_WIDTH] ^ r_ptr[PTR_WIDTH]; // To check MSB of write and read pointers are different
  
  //Full condition: MSB of write and read pointers are different and remainimg bits are same.
  assign fif.full = wrap_around & (w_ptr[PTR_WIDTH-1:0] == r_ptr[PTR_WIDTH-1:0]);
  
  //Empty condition: All bits of write and read pointers are same.
  //assign empty = !wrap_around & (w_ptr[PTR_WIDTH-1:0] == r_ptr[PTR_WIDTH-1:0]);
  //or
  assign fif.empty = (w_ptr == r_ptr);
endmodule