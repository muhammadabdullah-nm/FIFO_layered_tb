// Code your testbench here
// or browse Examples
module fifo_test #(parameter DEPTH=8, DATA_WIDTH=8) (
    fifo_interface fif_test
);
// SYSTEMVERILOG: timeunit and timeprecision specification
timeunit 1ns;
timeprecision 1ns;

// Monitor Results
  initial begin
      $timeformat ( -9, 0, " ns", 9 );
// SYSTEMVERILOG: Time Literals
      #40000ns $display ( "FIFO TEST TIMEOUT" );
      $finish;
    end

int debug=1;
logic [DATA_WIDTH-1:0] rdata;
logic [DATA_WIDTH-1:0] wdata;
int error_status=0;
bit emFlagCheck, fullFlagCheck;
bit randStm;
logic  [DATA_WIDTH-1:0] fifoTestArr[DEPTH];

initial
  begin: fifoTest

    //-----------------RESET TEST-------------------------
    // reset_fifo(0);
    
    // for (int i = 0; i<DEPTH; i++)
    //     begin 
    //         read_fifo (rdata, 1);
    //         check (rdata, i);
    //     end
    
    // reset_fifo(1);
    
    // for (int i = 0; i<DEPTH; i++)
    //     begin 
    //         read_fifo (rdata, 1);
    //         check (rdata, i);
    //     end
    
    // reset_fifo(0);
    // reset_fifo(1);

    // for (int i = 0; i<DEPTH; i++)
    //     begin
    //         write_fifo (i, 1);
    //     end
    
    // reset_fifo(0);
    // reset_fifo(1);
    
    // for (int i = 0; i<DEPTH; i++)
    //     begin 
    //         read_fifo (rdata, 1);
    //         check (rdata, i);
    //     end

    //-----------------EMPTY TEST-------------------------
    error_status=0;
    reset_fifo(0);
    reset_fifo(1);
    $display("EMPTY Test");

    empty_fifo(emFlagCheck);
    for (int i = 0; i<DEPTH; i++)
        begin 
            read_fifo (rdata, 1);
            empty_fifo(emFlagCheck);
            check (rdata, i);
        end
    
    for (int i = 0; i<DEPTH; i++)
        begin
            write_fifo (i, 1);
        end

    // reset_fifo(1);
    
    for (int i = 0; i<DEPTH+5; i++)
        begin 
            read_fifo (rdata, 1);
            empty_fifo(emFlagCheck);
            check (rdata, i);
        end
    printstatus (error_status, "Empty test");    
    
    //-----------------CLEAR FIFO TEST-------------------------
    // error_status=0;
    // reset_fifo(0);
    // reset_fifo(1);
    // $display("Clear FIFO Test");
    // for (int i = 0; i<DEPTH; i++)
    //     begin
    //         write_fifo (0, 1);
    //     end

    // for (int i = 0; i<DEPTH; i++)
    //     begin 
    //         read_fifo (rdata, 1);
    //         check (rdata, 0);
    //     end
    // printstatus (error_status, "Clear FIFO test");

    //-----------------DATA = DEPTH TEST-------------------------
    // error_status=0;
    // reset_fifo(0);
    // reset_fifo(1);

    // $display("DATA = DEPTH Test");
    // for (int i = 0; i<DEPTH; i++)
    //     begin
    //         write_fifo (i, 1);
    //     end

    // for (int i = 0; i<DEPTH; i++)
    //     begin 
    //         read_fifo (rdata, 1);
    //         check (rdata, i);
    //     end
    // printstatus (error_status, "DATA=DEPTH test");
    
    //-----------------DATA Reading and Writing More than Depth Times-------------------------
    // error_status=0;
    // reset_fifo(0);
    // reset_fifo(1);

    // $display("DATA Writing & Reading More than Depth Times");
    // for (int i = 0; i<DEPTH+10; i++)
    //     begin
    //         write_fifo (i, 1);
    //     end

    // for (int i = 0; i<DEPTH+10; i++)
    //     begin 
    //         read_fifo (rdata, 1);
    //         check (rdata, i);
    //     end
    // printstatus (error_status, "DATA Writing After Full TEST");

    
    //-----------------FULL TEST-------------------------
  //   error_status=0;
  //   reset_fifo(0);
  //   reset_fifo(1);
  //   $display("FULL Test");
  //   for (int i = 0; i<DEPTH+5; i++)
  //       begin
  //           write_fifo (i, 1);
  //           full_fifo(fullFlagCheck);
  //       end

  //   for (int i = 0; i<DEPTH; i++)
  //       begin 
  //           read_fifo (rdata, 1);
  //           check (rdata, i);
  //       end
  //  printstatus (error_status, "FULL test");

    //-----------------Read After Write TEST-------------------------
    // error_status=0;
    // reset_fifo(0);
    // reset_fifo(1);
    // $display("Read After Write Test");
    // for (int i = 0; i<DEPTH; i++)
    //     begin
    //         write_fifo (i, 1);
    //         read_fifo (rdata, 1);
    //         check (rdata, i);
    //     end

    // printstatus (error_status, "Read After Write test");

    //-----------------Read & Write Random TEST-------------------------
    error_status=0;
    reset_fifo(0);
    reset_fifo(1);
    $display("Read & Write Random TEST");
    for (int i = 0; i<DEPTH; i++)
        begin
            fifoTestArr[i]=0;
        end

    for (int i = 0; i<DEPTH; i++)
        begin
            randStm=$urandom%2;
            if(randStm)
            begin
                read_fifo (rdata, 1);
                check (rdata, fifoTestArr[i]);
            end
            else
            begin
                write_fifo ($urandom, 1);
                fifoTestArr[i]=$urandom;
            end
        end

    printstatus (error_status, "Read After Write test");
    
    //-----------------READ & WRITE SIMULTANEOULSY TEST-------------------------
  //   $display("READ & WRITE SIMULTANEOULSY TEST");
  //   // keep reading for half of the FIFO 
  //   error_status=0;
  //   reset_fifo(0);
  //   reset_fifo(1);
  //   for (int i = 0; i<DEPTH; i++)
  //   begin 
  //       read_write_fifo (i,rdata, 1);
  //   end

  //  // print results of test
  //   printstatus (error_status, "READ & WRITE SIMULTANEOULSY test");

    $finish;
  end

//reset test
task reset_fifo(input reset);
    @(negedge fif_test.clk)
    fif_test.rst_n=reset;
endtask

// empty tasks
task empty_fifo (output emFlag) ;
    @(negedge fif_test.clk)
    emFlag=fif_test.empty;
    $display ( "Empty flag: %d", emFlag);
  endtask

// full tasks
task full_fifo (output flFlag) ;
    @(negedge fif_test.clk)
    flFlag=fif_test.full;
    $display ( "Full flag: %d", flFlag);
  endtask

// write_read_fifo tasks
task read_write_fifo (input [DATA_WIDTH-1:0] data_to_write, output [DATA_WIDTH-1:0] data_to_read, input debug) ;
    @(negedge fif_test.clk)
    fif_test.data_in=data_to_write;
    fif_test.w_en=1;
    fif_test.r_en=1;
    data_to_read=fif_test.data_out;
    @(negedge fif_test.clk)
    // fif_test.r_en=0;
    fif_test.w_en=0;
    $display ( "Data written: %d", data_to_write);
    $display ( "Data read: %d", data_to_read);
    if ( debug == 0 )
      begin
        $display ( "FIFO WRITE TEST FAILED" );
        $finish;
      end
  endtask

// write_fifo tasks
task write_fifo (input [DATA_WIDTH-1:0] data_to_write, input debug) ;
    @(negedge fif_test.clk)
    fif_test.data_in=data_to_write;
    fif_test.w_en=1;
    fif_test.r_en=0;
    @(negedge fif_test.clk)
    fif_test.w_en=0;
    $display ( "Data written: %d", data_to_write);
    if ( debug == 0 )
      begin
        $display ( "FIFO WRITE TEST FAILED" );
        $finish;
      end
  endtask

    
task read_fifo (output [DATA_WIDTH-1:0] data_to_read, input debug) ;
    @(negedge fif_test.clk)
    fif_test.w_en=0;
    fif_test.r_en=1;
    @(negedge fif_test.clk)
    data_to_read=fif_test.data_out;
    fif_test.r_en=0;
    $display ( "Data read: %d", data_to_read);
    if ( debug == 0 )
      begin
        // $display ( "Read address=%b data value %b", addr, data_in );
        $display ( "FIFO READ TEST FAILED" );
        $finish;
      end
  endtask

task check (input [DATA_WIDTH-1:0] expected, observed) ;
    if ( expected !== observed )
      begin
        error_status=error_status+1;
      end
  endtask

function void printstatus (int error_status, input string testname);
    if(error_status > 0)
        $display("Error in TestName = %s",testname);
    else 
        $display("Passed = %s",testname);
endfunction

// add result print function
 initial begin
   $dumpfile("fifo.vcd");
   $dumpvars();
   #4000 $finish;
  end

endmodule