/*

Monitor class for the testbench, watches the DUT outputs and passes the results up into the scoreboard/checker.
Only needs to monitor the actual OUTPUTS of the DUT.

Zachary Zazzara (40096894)

Created on: March 30th, 2024
*/
//import transPKG::*;
package moniPKG;
    import defs::*;
    import transPKG::*;

    class tb_moni;
        //Flag to trigger end of the test
        bit ended;

        //Transaction instance to hold the data just sent out from the DUT, one per port
        tb_trans_out tr1, tr2, tr3, tr4;

        //Virtual interface instance
        virtual tb_if.Monitor tb_monitor_if;

        //Mailbox instance Monitor -> Scoreboard/Checker
        mailbox #(tb_trans_out) mon2scb;

        function new(virtual tb_if.Monitor tb_monitor_if, mailbox #(tb_trans_out) mon2scb);
            this.tb_monitor_if = tb_monitor_if;
            this.mon2scb = mon2scb;
            ended = 0;
        endfunction: new

        task main(); //main daemon, starts 4 threads that monitor ports
            $display("Starting Monitor Daemon");
            //Start 4 tasks that each monitor 1 of the 4 output ports of the DUT for activity
            @(tb_monitor_if.monitor_cb);
            fork
                listenPort1();
                listenPort2();
                listenPort3();
                listenPort4();
            join //Wait for all port mini-monitors to finish
            $display($time, ": Monitor daemon stopping."); //Debug
        endtask: main

        task listenPort1();
            //out_resp_t resp1;
            do begin
               /* 
               resp1 = tb_monitor_if.monitor_cb.ifResp1_out;
                if(resp1 === NORE)
                    @(posedge tb_monitor_if.monitor_cb.ifResp1_out); //Wait for something to happen on the port
                */
                if(tb_monitor_if.monitor_cb.ifResp1_out != NORE) begin //If response is anything but NOP, do the following
                    //Instanciate new transaction object & assign the recieved data to it
                    this.tr1 = new();
                    tr1.out_resp = tb_monitor_if.monitor_cb.ifResp1_out;
                    tr1.out_data = tb_monitor_if.monitor_cb.ifData1_out;
                    tr1.out_tag = tb_monitor_if.monitor_cb.ifTag1_out;
                    tr1.port = 1;
                    
                    //Send transaction object to the scoreboard/checker
                    $display($time, "Data detected on port 1: Responce code %b, data: %h, tag: %b", tr1.out_resp, tr1.out_data, tr1.out_tag);
                    $display($time, "Detected output on port 1.");
                    mon2scb.put(tr1);
                end
                @(this.tb_monitor_if.monitor_cb); //Wait for a clock pulse
            end while(!ended); //Loop forever while end of test isn't flagged.
        endtask: listenPort1

        task listenPort2(); //same as listenPort1
            //out_resp_t resp2;
            do begin
               /*
                resp2 = tb_monitor_if.monitor_cb.ifResp2_out;
                if(resp2 === NORE)
                    @(posedge tb_monitor_if.monitor_cb.ifResp2_out);
                */
                if(tb_monitor_if.monitor_cb.ifResp2_out != NORE) begin 
                    //Instanciate new transaction object & assign the recieved data to it
                    this.tr2 = new();
                    tr2.out_resp = tb_monitor_if.monitor_cb.ifResp2_out;
                    tr2.out_data = tb_monitor_if.monitor_cb.ifData2_out;
                    tr2.out_tag = tb_monitor_if.monitor_cb.ifTag2_out;
                    tr2.port = 2;
                    
                    //Send transaction object to the scoreboard/checker
                    $display($time, "Data detected on port 2: Responce code %b, data: %h, tag: %b", tr2.out_resp, tr2.out_data, tr2.out_tag);
                    $display($time, "Detected output on port 2.");
                    mon2scb.put(tr2);
                end
                @(this.tb_monitor_if.monitor_cb);
            end while(!ended);
        endtask: listenPort2

        task listenPort3(); //same as listenPort1
            //out_resp_t resp3;
            do begin
                /*
                resp3 = tb_monitor_if.monitor_cb.ifResp3_out;
                if(resp3 === NORE)
                    @(posedge tb_monitor_if.monitor_cb.ifResp3_out);
                */
                //Instanciate new transaction object & assign the recieved data to it
                if(tb_monitor_if.monitor_cb.ifResp3_out != NORE) begin 
                    this.tr3 = new();
                    tr3.out_resp = tb_monitor_if.monitor_cb.ifResp3_out;
                    tr3.out_data = tb_monitor_if.monitor_cb.ifData3_out;
                    tr3.out_tag = tb_monitor_if.monitor_cb.ifTag3_out;
                    tr3.port = 3;
                    
                    //Send transaction object to the scoreboard/checker
                    $display($time, "Data detected on port 3: Responce code %b, data: %h, tag: %b", tr3.out_resp, tr3.out_data, tr3.out_tag);
                    $display($time, "Detected output on port 3.");
                    mon2scb.put(tr3);
                end
                @(this.tb_monitor_if.monitor_cb);
            end while(!ended);
        endtask: listenPort3

        task listenPort4(); //same as listenPort1
            //out_resp_t resp4;
            do begin
                /*
                resp4 = tb_monitor_if.monitor_cb.ifResp4_out;
                if(resp4 === NORE)
                    @(posedge tb_monitor_if.monitor_cb.ifResp4_out); 
                */
                    if(tb_monitor_if.monitor_cb.ifResp4_out != NORE) begin 
                    //Instanciate new transaction object & assign the recieved data to it
                    this.tr4 = new();
                    tr4.out_resp = tb_monitor_if.monitor_cb.ifResp4_out;
                    tr4.out_data = tb_monitor_if.monitor_cb.ifData4_out;
                    tr4.out_tag = tb_monitor_if.monitor_cb.ifTag4_out;
                    tr4.port = 4;
                    
                    //Send transaction object to the scoreboard/checker
                    $display($time, "Data detected on port 4: Responce code %b, data: %h, tag: %b", tr4.out_resp, tr4.out_data, tr4.out_tag);
                    $display($time, "Detected output on port 4.");
                    mon2scb.put(tr4);
                end
                @(this.tb_monitor_if.monitor_cb);
            end while(!ended);
        endtask: listenPort4

        task wrap_up();
            ended = 1;
        endtask: wrap_up
    endclass: tb_moni
endpackage