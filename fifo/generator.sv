`timescale 1ns/1ns
class generator #(parameter DEPTH=8, DATA_WIDTH=8);
    transaction #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH)) obj;
    mailbox #(transaction #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH))) mbxToDriver;
    mailbox #(transaction #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH))) mbxToScoreboard;
    int rept,i;
    bit completed;
    int testCase;
    int transSent=0;

    function new(mailbox #(transaction #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH))) mbxToDriver, mailbox #(transaction #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH)))  mbxToScoreboard, int rept=0, int testCase=0);
        this.mbxToDriver=mbxToDriver;
        this.mbxToScoreboard=mbxToScoreboard;
        this.rept=rept;
        obj = new();
        this.testCase=testCase;
    endfunction

    task run();
        case(testCase)
            0:
            begin 
                transSent=0;
                repeat(rept)
                begin
                resetEn();
                mbxToDriver.put(obj.copy());
                mbxToScoreboard.put(obj.copy());
                transSent++;
                end
                resetDis();
                mbxToDriver.put(obj.copy());
                mbxToScoreboard.put(obj.copy());
            end
            1: 
            begin
                transSent=0;
                resetEn();
                emptyFIFO();
                $display("\n");
                $display("-----------Empty Test------------");
            end
            2:
            begin
                transSent=0;
                fullFIFO();
                $display("\n");
                $display("-----------Full Test------------");
            end
            3:
            begin
                transSent=0;
                for(i=0; i<rept; i++)
                begin
                    writeFIFO();
                end
                for(i=0; i<rept; i++)
                begin
                    readFIFO();
                end
                $display("\n");
                $display("-----------Read And Write Test------------");
            end
            4:
            begin
                transSent=0;
                for(i=0; i<rept; i++)
                begin
                    writeFIFO();
                    readFIFO();
                end
                $display("\n");
                $display("-----------Read After Write Test------------");
            end
            5:
            begin
                transSent=0;
                for(i=0; i<rept; i++)
                begin
                    rdWrite(i);
                end
                $display("\n");
                $display("-----------Read And Write Simultaneous Test------------");
            end
            6:
            begin
                transSent=0;
                for(i=0; i<rept; i++)
                begin
                    writeFIFORandom();
                end
                $display("\n");
                $display("-----------Read And Write Simultaneous Test------------");
            end
        endcase
        // writeFIFO();
        //clearFIFOWr();
        completed=1;
        $display("Randmization completed");
    endtask

    task writeFIFORandom();
        assert(obj.randomize()) else $display("Randomization failed");
        mbxToDriver.put(obj.copy());
        mbxToScoreboard.put(obj.copy());
        // obj.display();
        resetDis();
        transSent++;
    endtask

    task fullFIFO();
        for(i=0; i<rept; i++)
        begin
            obj.r_en=0;
            obj.w_en=1;
            obj.data_in=i;
            mbxToDriver.put(obj.copy());
            mbxToScoreboard.put(obj.copy());
            // obj.display();
            resetDis();
            transSent++;
        end
    endtask

    task emptyFIFO();
        repeat(rept)
        begin
            obj.r_en=1;
            obj.w_en=0;
            obj.data_in=10;
            mbxToDriver.put(obj.copy());
            mbxToScoreboard.put(obj.copy());
            // obj.display();
            resetDis();
            transSent++;
        end
    endtask

    task writeFIFO();
        obj.r_en=0;
        obj.w_en=1;
        obj.data_in=$urandom;
        mbxToDriver.put(obj.copy());
        mbxToScoreboard.put(obj.copy());
        // obj.display();
        resetDis(); 
        transSent++;
    endtask

    task readFIFO();
        obj.r_en=1;
        obj.w_en=0;
        obj.data_in=0;
        mbxToDriver.put(obj.copy());
        mbxToScoreboard.put(obj.copy());
//         obj.display();
        resetDis();
        transSent++;
    endtask

    task rdWrite(int i);
        obj.r_en=1;
        obj.w_en=1;
        obj.data_in=i;
        mbxToDriver.put(obj.copy());
        mbxToScoreboard.put(obj.copy());
        // obj.display();
        resetDis();
        transSent++;
    endtask

    task resetEn();
        obj.rst_n=0;
    endtask

    task resetDis();
        obj.rst_n=1;
    endtask

endclass