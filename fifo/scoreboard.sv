`timescale 1ns/1ns
class scoreboard #(parameter DEPTH=8, DATA_WIDTH=8);
    mailbox #(transaction #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH))) mbxFromMon;
    mailbox #(transaction #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH))) mbxFromGen;
    transaction #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH))  obj1;
    transaction #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH))  obj2;

    int recTrans;
    logic [DATA_WIDTH-1:0] fifo[$];
    int errorStatus=0;
    int wr_ptr=0, rd_ptr=0;
    bit testCompleted=0;
    int count=0;
    bit fullFlag=0, emptyFlag=0;

    function new(mailbox #(transaction #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH)))  mbxFromMon, mailbox #(transaction #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH)))  mbxFromGen);
        this.mbxFromGen=mbxFromGen;
        this.mbxFromMon=mbxFromMon;
    endfunction

    task run();
        forever begin
            mbxFromGen.get(obj1);
            // $display("Data from generator:");
            // obj1.display();
            mbxFromMon.get(obj2);
            // $display("Data from monitor:");
            // obj2.display();
            
            emptyFlag = (wr_ptr == rd_ptr) ? 1:0;
            fullFlag = (count == DEPTH)? 1:0;
//           fullFlag = (wr_ptr+1) % DEPTH == rd_ptr;
                
            if(!obj2.rst_n)
            begin
                assert(obj2.empty) else
                  begin
                    $display("Empty failed");
                    errorStatus++;
                  end
                $display("Empty Flag %d",obj2.empty);
            end
            
            if(fullFlag && obj1.w_en)
            begin
                assert(obj2.full) else
                  begin
                    $display("Full Failed");
                    errorStatus++;
                  end
                $display("Can't write Full flag %d", obj2.full);
                // $display("Local Full flag %d, empty flag %d", fullFlag, emptyFlag);
            end
            else if(obj1.w_en)
                begin   
                    fifo[wr_ptr]=obj1.data_in;
                    $display("FIFOWrite: %d, DUTWrite %d, rptr= %d, wr_ptr: %d, full: %d, empty: %d",fifo[wr_ptr], obj1.data_in, rd_ptr, wr_ptr, fullFlag, emptyFlag);
                    wr_ptr++;
                    // rd_ptr--;
                    count++;
                end

            if(emptyFlag && obj2.r_en)
            begin
                assert(obj2.empty) 
                else
                  begin
                    $display("Empty failed");
            	  end
                $display("Can't read Empty Flag %d",obj2.empty);
            end
            else if(obj2.r_en)
                begin
                    $display("FIFORead: %d, DUTRead %d, rptr= %d, wr_ptr: %d, full: %d, empty: %d",fifo[rd_ptr], obj2.data_out, rd_ptr, wr_ptr, fullFlag, emptyFlag);
                    if(fifo[rd_ptr]!==obj2.data_out && rd_ptr<DEPTH) 
                    begin
                        $display("Error");
                        $display("Expected: %d, Actual %d",fifo[rd_ptr], obj2.data_out);
                        errorStatus++;
                    end
                    else    
                    begin
                        rd_ptr++;
                        // wr_ptr--;
                        count--;
                    end
                end
            
            // $display("addr %d, data_in: %d, data_out: %d",obj1.addr, obj1.data_in, obj2.data_out);
            // $display("addr %d, MEMdata_in: %d, MEMdata_out: %d",obj1.addr, memoryTest[obj1.addr], memoryTest[obj2.addr]);
            recTrans++;
            // $display("Trans at score %d",recTrans);

        end
    endtask
endclass