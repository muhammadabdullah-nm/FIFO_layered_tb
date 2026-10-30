`timescale 1ns/1ns

class env  #(parameter DEPTH=8, DATA_WIDTH=8);
    virtual fifo_interface #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH)) mif;
    mailbox #(transaction #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH))) gen2driv;
    mailbox #(transaction #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH))) gen2scb;
    mailbox #(transaction #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH))) mon2scb;
    int rep_cnt;

    generator #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH))  gen;
    driver #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH))  drv;
    monitor #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH))  mon;
    scoreboard #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH))  scr;
    bit gen_ended;

    function new(virtual fifo_interface #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH)) mif, int rep_cont, int testCase);
        gen2driv=new;
        gen2scb=new;
        mon2scb=new;
        this.mif=mif;
        gen=new(gen2driv, gen2scb, rep_cont, testCase);
        drv=new(gen2driv, mif);
        mon=new(mon2scb, mif);
        scr=new(mon2scb, gen2scb);
        gen_ended=0;
        rep_cnt=rep_cont;
    endfunction

    task test();
        fork
            gen.run();
            drv.run();
            mon.run();
            scr.run();
        join_any
    endtask

    task post_test();
        // wait(gen.completed==1)
    //   wait(gen.completed==1 && ((rep_cnt*2==scr.recTrans) || (rep_cnt==scr.recTrans) ))
    wait(gen.completed == 1 && gen.transSent == scr.recTrans)
        begin
            if(scr.errorStatus)
            begin
                $display("Test Failed with %d Errors", scr.errorStatus);
                $display("\n");
                $display("                              _ ._  _ , _ ._");
                $display("                            (_ ' ( `  )_  .__)");
                $display("                          ( (  (    )   `)  ) _)");
                $display("                         (__ (_   (_ . _) _) ,__)");
                $display("                             `~~`\ ' . /`~~`");
                $display("                             ,::: ;   ; :::,");
                $display("                            ':::::::::::::::'");
                $display(" ________________________________/_ __ \________________________________");
                $display("|                                                                       |");
                $display("|                               TEST FAILED                             |");
                $display("|_______________________________________________________________________|");
                $display("\n");
            end
            else
            begin
                $display("\n");
                $display("                                  _\\|/_");
                $display("                                  (o o)");
                $display(" ______________________________oOO-{_}-OOo______________________________");
                $display("|                                                                       |");
                $display("|                               TEST PASSED                             |");
                $display("|_______________________________________________________________________|");
                $display("\n");
            end
        end
    endtask

    task run();
        test();
        post_test();
        $finish;
    endtask
endclass