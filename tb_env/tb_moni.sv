/*

Monitor class for the testbench, watches the DUT outputs and passes the results up into the scoreboard/checker.
Only needs to monitor the actual OUTPUTS of the DUT.

Zachary Zazzara (40096894)
zexi si (40175054)

Created on: March 30th, 2024
*/

`include "tb_env/tb_trans.sv"
`include "tb_env/devs.sv"
//Other includes here as necessary

class tb_moni;
    //Flag to trigger end of the test
    bit ended;

    //Transaction instance to hold the data just sent out from the DUT, one per port
    tb_trans tr1, tr2, tr3, tr4;

    //Virtual interface instance
    virtual tb_if.Monitor tb_monitor_if;

    //Mailbox instance Monitor -> Scoreboard/Checker
    mailbox #(tb_trans) mon2scb;

    function new(virtual tb_if.Monitor tb_monitor_if, mailbox #(tb_trans) mon2scb);
        this.tb_monitor_if = tb_monitor_if;
        this.mon2scb = mon2scb;
        ended = 0;
    endfunction: new

    task main(); //main daemon, starts 4 threads that monitor ports
        //Start 4 tasks that each monitor 1 of the 4 output ports of the DUT for activity
        fork
            listenPort1();
            listenPort2();
            listenPort3();
            listenPort4();
        join //Wait for all port mini-monitors to finish
        $display($time, ": Monitor daemon stopping."); //Debug
    endtask: main

    task listenPort1();
        out_resp_t resp1;
        do begin
            resp1 = tb_monitor_if.ifResp1_out;
            if(resp1 === NORE)
                @(posedge tb_monitor_if.ifResp1_out); //Wait for something to happen on the port

            //Instanciate new transaction object & assign the recieved data to it
            this.tr1 = new();
            tr1.cmd = tb_monitor_if.ifResp1_out;
            tr1.op1 = tb_monitor_if.ifData1_out;
            tr1.tag = tb_monitor_if.ifTag1_out;
            tr1.port = 1;
            tr1.count = tr1.count--; //stops the monitor transactions from messing up the total # of generated transactions
                                    //This is a very dirty fix, but whatever.
            
            //Send transaction object to the scoreboard/checker
            mon2scb.put(tr1);
        end while(!ended); //Loop forever while end of test isn't flagged.
    endtask: listenPort1

    task listenPort2(); //same as listenPort1
        out_resp_t resp2;
        do begin
            resp2 = tb_monitor_if.ifResp2_out;
            if(resp2 === NORE)
                @(posedge tb_monitor_if.ifResp2_out);

            //Instanciate new transaction object & assign the recieved data to it
            this.tr2 = new();
            tr2.cmd = tb_monitor_if.ifResp2_out;
            tr2.op1 = tb_monitor_if.ifData2_out;
            tr2.tag = tb_monitor_if.ifTag2_out;
            tr2.port = 2;
            tr2.count = tr2.count--;
            
            //Send transaction object to the scoreboard/checker
            mon2scb.put(tr2);
        end while(!ended);
    endtask: listenPort2

    task listenPort3(); //same as listenPort1
        out_resp_t resp3;
        do begin
            resp3 = tb_monitor_if.ifResp3_out;
            if(resp3 === NORE)
                @(posedge tb_monitor_if.ifResp3_out);

            //Instanciate new transaction object & assign the recieved data to it
            this.tr3 = new();
            tr3.cmd = tb_monitor_if.ifResp3_out;
            tr3.op1 = tb_monitor_if.ifData3_out;
            tr3.tag = tb_monitor_if.ifTag3_out;
            tr3.port = 3;
            tr3.count = tr3.count--;
            
            //Send transaction object to the scoreboard/checker
            mon2scb.put(tr3);
        end while(!ended);
    endtask: listenPort3

    task linstePort4(); //same as listenPort1
        out_resp_t resp4;
        do begin
            resp4 = tb_monitor_if.ifResp4_out;
            if(resp4 === NORE)
                @(posedge tb_monitor_if.ifResp4_out); 

            //Instanciate new transaction object & assign the recieved data to it
            this.tr4 = new();
            tr4.cmd = tb_monitor_if.ifResp4_out;
            tr4.op1 = tb_monitor_if.ifData4_out;
            tr4.tag = tb_monitor_if.ifTag4_out;
            tr4.port = 4;
            tr4.count = tr4.count--;
            
            //Send transaction object to the scoreboard/checker
            mon2scb.put(tr4);
        end while(!ended);
    endtask: listenPort4

    task wrap_up();
        ended = 1;
    endtask: wrap_up
endclass: tb_moni