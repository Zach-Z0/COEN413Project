/*
Driver class which handles taking the transactions recieved from the agent class through the "agt2dvr" mailbox and translating
them into low level commands for the input lines of the DUT. 

Also handles reset commands and passing through the clock.
Needs to work closely with the interface.

Possibly could have used threads here to split the driver up into 4 "lanes" so it can handle multiple transactions at once?
Oh well...

Zachary Zazzara (40096894)
zexi si (40175054)

Created on: March 29th, 2024
*/

`include "tb_env/tb_trans.sv"
`include "tb_env/defs.sv"

class tb_dvr
    //Interface object declaration
    virtual tb_if.Master tb_master_if;

    //Flag to trigger end of the test
    bit ended;

    //Mailbox
    mailbox #(tb_trans) agt2dvr;

    function new(virtual tb_if.Master tb_master_if, mailbox #(tb_trans) agt2dvr); 
        this.tb_master_if = tb_master_if;
        this.agt2dvr = agt2dvr;
        ended = 0;
    endfunction: new

    task main();
        //Hold incoming transaction objects that are to be sent to the DUT.
        tb_trans tr;

        forever begin //Driver Daemon 
            //Wait for a transaction to be deposited in the mailbox
            agt2dvr.get(tr); 

            /*
            First, sort the incoming transaction based on the port it's going to (1,2,3, or 4).
            Second, figure out what calculator function is being requested (Add, Sub, Shift Left, Shift Right, NOP).
            Last, perform that calculator task on the apropriate input lines.

            Nested case statements here, ugly, but relatively simple?
            NOTE: The "NOP" case could be changed to just be the default case... but I want the error message for debugging.
            Note 2: Not sure if NOP statements are supposed to be fed in with tags and subsequently need to be
            verified against DUT output, waiting for responce from TA. THIS WILL HAVE REPERCUSSIONS ON THE AGENT CLASS 
            IF CHANGED, AND THE SCOREBOARD TOO. Will need to exclude NOP commands from being sent to the scoreboard/checker.
            */
            case(tr.port)
                1: begin
                    case(tr.cmd)
                        NOP: begin
                            tb_master_if.req1_cmd_in <= tr.cmd;
                            tb_master_if.req1_data_in <= 0;
                            tb_master_if.req1_tag_in <= tr.tag; //May need to change this depending on answer from TA.
                        end
                        ADD, SUB, LSH, RSH: begin
                            tb_master_if.req1_cmd_in <= tr.cmd;
                            tb_master_if.req1_data_in <= tr.op1; //Send in operand 1
                            tb_master_if.req1_tag_in <= tr.tag;
                            @(this.tb_master_if); //Wait for a clock pulse
                            tb_master_if.req1_cmd_in <= 0;
                            tb_master_if.req1_data_in <= tr.op2; //Send in operand 2
                            tb_master_if.req1_tag_in <= 0;
                        end
                        default:
                            $display($time, ": Error with the driver command (operation) case statement! Bad cmd data! (?)");
                    endcase
                end
                2: begin
                    case(tr.cmd)
                        NOP: begin
                           tb_master_if.req2_cmd_in <= tr.cmd;
                           tb_master_if.req2_data_in <= 0;
                           tb_master_if.req2_tag_in <= tr.tag; //May need to change this depending on answer from TA.
                        end
                        ADD, SUB, LSH, RSH: begin
                            tb_master_if.req2_cmd_in <= tr.cmd;
                            tb_master_if.req2_data_in <= tr.op1; //Send in operand 1
                            tb_master_if.req2_tag_in <= tr.tag;
                            @(this.tb_master_if); //Wait for a clock pulse
                            tb_master_if.req2_cmd_in <= 0;
                            tb_master_if.req2_data_in <= tr.op2; //Send in operand 2
                            tb_master_if.req2_tag_in <= 0;
                        end
                        default:
                            $display($time, ": Error with the driver command (operation) case statement! Bad cmd data! (?)");
                    endcase
                end
                3: begin
                    case(tr.cmd)
                        NOP: begin
                           tb_master_if.req3_cmd_in <= tr.cmd;
                           tb_master_if.req3_data_in <= 0;
                           tb_master_if.req3_tag_in <= tr.tag; //May need to change this depending on answer from TA.
                        end 
                        ADD, SUB, LSH, RSH: begin
                            tb_master_if.req3_cmd_in <= tr.cmd;
                            tb_master_if.req3_data_in <= tr.op1; //Send in operand 1
                            tb_master_if.req3_tag_in <= tr.tag;
                            @(this.tb_master_if); //Wait for a clock pulse
                            tb_master_if.req3_cmd_in <= 0;
                            tb_master_if.req3_data_in <= tr.op2; //Send in operand 2
                            tb_master_if.req3_tag_in <= 0;
                        end
                        default:
                            $display($time, ": Error with the driver command (operation) case statement! Bad cmd data! (?)");
                    endcase
                end
                4: begin
                    case(tr.cmd)
                        NOP: begin
                           tb_master_if.req4_cmd_in <= tr.cmd;
                           tb_master_if.req4_data_in <= 0;
                           tb_master_if.req4_tag_in <= tr.tag; //May need to change this depending on answer from TA.
                        end
                        ADD, SUB, LSH, RSH: begin
                            tb_master_if.req4_cmd_in <= tr.cmd;
                            tb_master_if.req4_data_in <= tr.op1; //Send in operand 1
                            tb_master_if.req4_tag_in <= tr.tag;
                            @(this.tb_master_if); //Wait for a clock pulse
                            tb_master_if.req4_cmd_in <= 0;
                            tb_master_if.req4_data_in <= tr.op2; //Send in operand 2
                            tb_master_if.req4_tag_in <= 0;
                        end
                        default:
                            $display($time, ": Error with the driver command (operation) case statement! Bad cmd data! (?)");
                    endcase
                end
                default:
                    $display($time, ": Error with the driver port allocation case statement! Bad port data! (?)");
            endcase
            //Wait for clock edge to ensure the set data lines pass into the DUT before main tries to drive another.
            //This MAY be necessary if 2 commands try to go to the same port back to back.
            //Honestly I'm not sure if this is needed or not. Either it is, or it will cause timing issues.
            //Won't know until testing phase.
            @(this.tb_master_if);

            if((ended == 1) && (agt2dvr.num() == 0)) begin
                break; //If end of test flag as been set and the mailbox is empty, break from the forever loop
                $display($time, ": Ending Driver Daemon.")
            end
        end
    endtask: main

    task reset();
        @(this.tb_master_if); //Waits for negative edge of the clock, this might not be necessary.

        //Hold reset HI for 3 clock cycles
        tb_master_if.ifRst <= 1; 

        //Hold all inputs LO for 3 clock cycles
        tb_master_if.ifReq1_cmd_in <= 0;
        tb_master_if.ifReq2_cmd_in <= 0;
        tb_master_if.ifReq3_cmd_in <= 0;
        tb_master_if.ifReq4_cmd_in <= 0;
        tb_master_if.ifReq1_data_in <= 0;
        tb_master_if.ifReq2_data_in <= 0;
        tb_master_if.ifReq3_data_in <= 0;
        tb_master_if.ifReq4_data_in <= 0;
        tb_master_if.ifReq1_tag_in <= 0;
        tb_master_if.ifReq2_tag_in <= 0;
        tb_master_if.ifReq3_tag_in <= 0;
        tb_master_if.ifReq4_tag_in <= 0;

        //Wait the 3 clock cycles, did 4 for good measure.
        repeat(4) @(this.tb_master_if);

        //Set reset back to LO, reset finished.
        tb_master_if.ifRst <= 0;

        //Do I need some sort of logic to tell the monitor to ignore outputs during this period? Maybe, but it 
        //most likely isn't declared here.
    endtask: reset

    task wrap_up();
        ended = 1;
    endtask: wrap_up
endclass: tb_dvr