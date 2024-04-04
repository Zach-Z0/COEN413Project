/*

Scoreboard/checker class. Seemed better to wrap the two up into one class, as both processes go hand.
Gameplan: 
    --Deposit incoming transactions into: 
        4 associative arrays (1 per port)[agent items]
        4 queues (1 per port)[monitor items]

    --"Spread out" the agent items in the associative array by tag (there should only ever be one of each tag in the array
    assuming the agent class is handling tags properly) and pair the items arriving from the monitor for checking on a first 
    come, first served basis (queue) (in temporary transaction objects, maybe?)

    --Log the check as right/wrong, bins and functional coverage, blah blah

    --Delete the agent item from the associative array

    --Return tag/key to the agent via dedicated mailbox


zexi si (40175054 )
zachary zazzara (40096894)
*/

`include "tb_env/tb_trans.sv"
//`include "tb_env/defs.sv"

class tb_scb;
    //Max # of transactions set in "test_cfg" class in "env.sv" file, passed here.
    int max_trans_cnt;

    //Flag to trigger end of the test
    event ended, internalEnded;
    bit endBit;

    //Test statistics
    //More than likely needs to be re-enforced with functional coverage bins and other stuff
    //This is just to get started
    int successTests;
    int failedTests;

    //Mailboxes for the incoming transactions, Agent -> Scoreboard/Checker, Monitor ->Scb/Checker, Scb/Ch -> Agent
    mailbox #(tb_trans) agt2scb, mon2scb, scb2agt;

    //Create the queues
    tb_trans monQue1 [$];
    tb_trans monQue2 [$];
    tb_trans monQue3 [$];
    tb_trans monQue4 [$];

    //Create the associatve arrays, index is the TAG as defined in "defs.sv", sorted by PORT (1,2,3,4)
    tb_trans agtArr1 [req_tag_t];
    tb_trans agtArr2 [req_tag_t];
    tb_trans agtArr3 [req_tag_t];
    tb_trans agtArr4 [req_tag_t];

    function new(int max_trans_cnt, mailbox #(tb_trans) agt2scb, mon2scb);
        this.max_trans_cnt = max_trans_cnt;
        this.agt2scb = agt2scb;
        this.mon2scb = mon2scb;
        endBit = 0;
    endfunction

    task main(); //main Scoreboard/checker daemon
        fork
            checkMailAgent();
            checkMailMonitor();
            validatePort1();
            validatePort2();
            validatePort3();
            validatePort4();
        join
        $display($time, ": Scoreboard/Checker daemon stopping."); //Debug
        ->internalEnded;
    endtask: main

    task wrap_up();
        endBit = 1;
        wait(internalEnded.triggered); //Wait for the class itself to finish up before telling env.sv that scb is done.
        -> ended;
    endtask: wrap_up

    task checkMailAgent(); //Continuously watches mailboxes for incoming transactions and sorts them accordingly
        tb_trans agt_tr; //Hold incoming mail somewhere
        forever begin
            agt2scb.get(agt_tr); //Wait for incoming mail
            case(agt_tr.port)
                //Move a copy of the transaction into the apropriate array
                //Note: Items indexed by their TAG
                1: agtArr1[agt_tr.tag] = agt_tr.copy(); 
                2: agtArr2[agt_tr.tag] = agt_tr.copy();
                3: agtArr3[agt_tr.tag] = agt_tr.copy();
                4: agtArr4[agt_tr.tag] = agt_tr.copy();
                default:
                    $display($time, ": Error with the scb/checker checkAgentMail case statement! Bad port data! (?)"); 
            endcase

            if((endBit == 1) && (agt2scb.num() == 0))
                break;
        end
        $display($time, ": Scoreboard/Checker checkMailAgent task stopping."); //Debug
    endtask: checkMailAgent

    task checkMailMonitor(); //same thing as checkMailAgent task
        tb_trans mon_tr;
        forever begin
            mon2scb.get(mon_tr);
            case(mon_tr.port)
                1: monQue1.push_back(mon_tr.copy());
                2: monQue2.push_back(mon_tr.copy());
                3: monQue3.push_back(mon_tr.copy());
                4: monQue4.push_back(mon_tr.copy());       
                default:
                    $display($time, ": Error with the scb/checker checkMonitorMail case statement! Bad port data! (?)");   
            endcase

            if((endBit == 1) && (mon2scb.num() == 0))
                break;            
        end
        $display($time, ": Scoreboard/Checker checkMailMonitor task stopping."); //Debug
    endtask: checkMailMonitor

    task validatePort1();
        tb_trans p1_mon, p1_agt;
        forever begin
            if(monQue1.size() > 0) begin //Wait for monitor transactions to appear in the queue.
                p1_mon = monQue1.pop_front();
                //Check if that tag exists in the agent transaction array, if yes, start comparison logic, if not,
                //wait for it to appear (as it should eventually). The exists check is repeated twice since a do while loop
                //will run at least once BEFORE checking the condition
                do begin
                    if(agtArr1.exists(p1_mon.tag)) begin
                        p1_agt = agtArr1[p1_mon.tag]; //Copy the reference out of array
                        agtArr1.delete(p1_mon.tag); //delete the object from the array
                        
                        //compare the two transactions to see if there's an error or not
                        case(p1_agt.cmd) //First sort by what operation type needs to be checked
                            NOP: $display($time, ": Error with the scb/checker validatePort1 case statement! Recieved a NOP!");
                            ADD: checkAdd(p1_agt, p1_mon);
                            SUB: checkSub(p1_agt, p1_mon);
                            LSH: checkLShift(p1_agt, p1_mon);
                            RSH: checkRShift(p1_agt, p1_mon);
                            default:
                                $display($time, ": Error with the scb/checker validatePort1 case statement! Bad command data!"); 
                        endcase
                         max_trans_cnt--; //Decrement how many transactions are left to test
                        scb2agt.put(p1_agt); //Now that we're done, return the key to the agent for re-use
                    end
                    #10; //For stability in case agent array does not have the needed tag yet
                end while(!agtArr1.exists(p1_mon.tag)); 
            end
            if(checkFinished());
                wrap_up();

            if((endBit == 1) && (monQue1.size() == 0) && (agtArr1.size() == 0)) //Checking if finished at End of Test
                break;

            #10; //For stability in case monitor queue is empty
        end
        $display($time, ": Scoreboard/Checker validatePort1 task stopping."); //Debug
    endtask: validatePort1

    task validatePort2();
        tb_trans p2_mon, p2_agt;
        forever begin
            if(monQue2.size() > 0) begin //Wait for monitor transactions to appear in the queue.
                p2_mon = monQue2.pop_front();
                //Check if that tag exists in the agent transaction array, if yes, start comparison logic, if not,
                //wait for it to appear (as it should eventually). The exists check is repeated twice since a do while loop
                //will run at least once BEFORE checking the condition
                do begin
                    if(agtArr2.exists(p2_mon.tag)) begin
                        p2_agt = agtArr2[p2_mon.tag]; //Copy the reference out of array
                        agtArr2.delete(p2_mon.tag); //delete the object from the array
                        
                        //compare the two transactions to see if there's an error or not
                        case(p2_agt.cmd) //First sort by what operation type needs to be checked
                            NOP: $display($time, ": Error with the scb/checker validatePort2 case statement! Recieved a NOP!");
                            ADD: checkAdd(p2_agt, p2_mon);
                            SUB: checkSub(p2_agt, p2_mon);
                            LSH: checkLShift(p2_agt, p2_mon);
                            RSH: checkRShift(p2_agt, p2_mon);
                            default:
                                $display($time, ": Error with the scb/checker validatePort2 case statement! Bad command data!"); 
                        endcase
                         max_trans_cnt--; //Decrement how many transactions are left to test
                        scb2agt.put(p2_agt); //Now that we're done, return the key to the agent for re-use
                    end
                    #10; //For stability in case agent array does not have the needed tag yet
                end while(!agtArr2.exists(p2_mon.tag)); 
            end
            if(checkFinished());
                wrap_up();

            if((endBit == 1) && (monQue2.size() == 0) && (agtArr2.size() == 0)) //Checking if finished at End of Test
                break;

            #10; //For stability in case monitor queue is empty
        end
        $display($time, ": Scoreboard/Checker validatePort2 task stopping."); //Debug
    endtask: validatePort2

    task validatePort3();
        tb_trans p3_mon, p3_agt;
        forever begin
            if(monQue3.size() > 0) begin //Wait for monitor transactions to appear in the queue.
                p3_mon = monQue3.pop_front();
                //Check if that tag exists in the agent transaction array, if yes, start comparison logic, if not,
                //wait for it to appear (as it should eventually). The exists check is repeated twice since a do while loop
                //will run at least once BEFORE checking the condition
                do begin
                    if(agtArr3.exists(p3_mon.tag)) begin
                        p3_agt = agtArr1[p3_mon.tag]; //Copy the reference out of array
                        agtArr3.delete(p3_mon.tag); //delete the object from the array
                        
                        //compare the two transactions to see if there's an error or not
                        case(p3_agt.cmd) //First sort by what operation type needs to be checked
                            NOP: $display($time, ": Error with the scb/checker validatePort3 case statement! Recieved a NOP!");
                            ADD: checkAdd(p3_agt, p3_mon);
                            SUB: checkSub(p3_agt, p3_mon);
                            LSH: checkLShift(p3_agt, p3_mon);
                            RSH: checkRShift(p3_agt, p3_mon);
                            default:
                                $display($time, ": Error with the scb/checker validatePort3 case statement! Bad command data!"); 
                        endcase
                         max_trans_cnt--; //Decrement how many transactions are left to test
                        scb2agt.put(p3_agt); //Now that we're done, return the key to the agent for re-use
                    end
                    #10; //For stability in case agent array does not have the needed tag yet
                end while(!agtArr3.exists(p3_mon.tag)); 
            end
            if(checkFinished());
                wrap_up();

            if((endBit == 1) && (monQue3.size() == 0) && (agtArr3.size() == 0)) //Checking if finished at End of Test
                break;

            #10; //For stability in case monitor queue is empty
        end
        $display($time, ": Scoreboard/Checker validatePort3 task stopping."); //Debug
    endtask: validatePort3

    task validatePort4();
        tb_trans p4_mon, p4_agt;
        forever begin
            if(monQue4.size() > 0) begin //Wait for monitor transactions to appear in the queue.
                p4_mon = monQue4.pop_front();
                //Check if that tag exists in the agent transaction array, if yes, start comparison logic, if not,
                //wait for it to appear (as it should eventually). The exists check is repeated twice since a do while loop
                //will run at least once BEFORE checking the condition
                do begin
                    if(agtArr4.exists(p4_mon.tag)) begin
                        p4_agt = agtArr4[p4_mon.tag]; //Copy the reference out of array
                        agtArr4.delete(p4_mon.tag); //delete the object from the array
                        
                        //compare the two transactions to see if there's an error or not
                        case(p4_agt.cmd) //First sort by what operation type needs to be checked
                            NOP: $display($time, ": Error with the scb/checker validatePort4 case statement! Recieved a NOP!");
                            ADD: checkAdd(p4_agt, p4_mon);
                            SUB: checkSub(p4_agt, p4_mon);
                            LSH: checkLShift(p4_agt, p4_mon);
                            RSH: checkRShift(p4_agt, p4_mon);
                            default:
                                $display($time, ": Error with the scb/checker validatePort4 case statement! Bad command data!"); 
                        endcase
                         max_trans_cnt--; //Decrement how many transactions are left to test
                        scb2agt.put(p4_agt); //Now that we're done, return the key to the agent for re-use
                    end
                    #10; //For stability in case agent array does not have the needed tag yet
                end while(!agtArr4.exists(p4_mon.tag)); 
            end
            if(checkFinished());
                wrap_up();

            if((endBit == 1) && (monQue4.size() == 0) && (agtArr4.size() == 0)) //Checking if finished at End of Test
                break;

            #10; //For stability in case monitor queue is empty
        end
        $display($time, ": Scoreboard/Checker validatePort4 task stopping."); //Debug
    endtask: validatePort4

    function void checkAdd(tb_trans agt, tb_trans mon);
        req_data_t scbResult, monResult;
        case(mon.cmd)
            GOOD: begin
                scbResult = (agt.op1) + (agt.op2); //Perform the operation
                monResult = mon.op1; //Get the result, which is stored in op1 field by the monitor

                if(monResult == scbResult) begin
                    successTests++;
                    $display($time, ": Successful addition result validation! Results: Agent: %0d and Monitor: %0d match!", scbResult, monResult);
                end
                else begin
                    failedTests++;
                    $display($time, ": Failed addition result verification! Results: Agent: %0d and Monitor: %0d do not match!", scbResult, monResult);
                end
            end
            INVL, ERR, NORE: begin
                failedTests++;
                $display($time, ": Failed addition result verification! Monitor returned responce code: %0b", mon.cmd);
            end
            default:
                $display($time, ": Error with the checkAdd case statement! Bad response code data!");
        endcase
    endfunction: checkAdd

    function void checkSub(tb_trans agt, tb_trans mon);
        req_data_t scbResult, monResult;
        case(mon.cmd)
            GOOD: begin
                scbResult = (agt.op1) - (agt.op2); //Perform the operation
                monResult = mon.op1; //Get the result, which is stored in op1 field by the monitor

                if(monResult == scbResult) begin
                    successTests++;
                    $display($time, ": Successful subtraction result validation! Results: Agent: %0d and Monitor: %0d match!", scbResult, monResult);
                end
                else begin
                    failedTests++;
                    $display($time, ": Failed subtraction result verification! Results: Agent: %0d and Monitor: %0d do not match!", scbResult, monResult);
                end
            end
            INVL, ERR, NORE: begin
                failedTests++;
                $display($time, ": Failed subtraction result verification! Monitor returned responce code: %0b", mon.cmd);
            end
            default:
                $display($time, ": Error with the checkSub case statement! Bad response code data!");
        endcase
    endfunction: checkSub

    function void checkLShift(tb_trans agt, tb_trans mon);
        req_data_t scbResult, monResult;
        case(mon.cmd)
            GOOD: begin
                scbResult = (agt.op1) <<< (agt.op2); //Perform the operation (Arithmetic shift left)
                monResult = mon.op1; //Get the result, which is stored in op1 field by the monitor

                if(monResult == scbResult) begin
                    successTests++;
                    $display($time, ": Successful left shift result validation! Results: Agent: %0d and Monitor: %0d match!", scbResult, monResult);
                end
                else begin
                    failedTests++;
                    $display($time, ": Failed left shift result verification! Results: Agent: %0d and Monitor: %0d do not match!", scbResult, monResult);
                end
            end
            INVL, ERR, NORE: begin
                failedTests++;
                $display($time, ": Failed left shift result verification! Monitor returned responce code: %0b", mon.cmd);
            end
            default:
                $display($time, ": Error with the checkLShift case statement! Bad response code data!");
        endcase
    endfunction: checkLShift

    function void checkRShift(tb_trans agt, tb_trans mon);
        req_data_t scbResult, monResult;
        case(mon.cmd)
            GOOD: begin
                scbResult = (agt.op1) >>> (agt.op2); //Perform the operation (Arithmetic shift right)
                monResult = mon.op1; //Get the result, which is stored in op1 field by the monitor

                if(monResult == scbResult) begin
                    successTests++;
                    $display($time, ": Successful rightshift result validation! Results: Agent: %0d and Monitor: %0d match!", scbResult, monResult);
                end
                else begin
                    failedTests++;
                    $display($time, ": Failed right shift result verification! Results: Agent: %0d and Monitor: %0d do not match!", scbResult, monResult);
                end
            end
            INVL, ERR, NORE: begin
                failedTests++;
                $display($time, ": Failed right shift result verification! Monitor returned responce code: %0b", mon.cmd);
            end
            default:
                $display($time, ": Error with the checkRShift case statement! Bad response code data!");
        endcase
    endfunction: checkRShift
    /*
    //Note: NOP never gets to the scoreboard! This function is useless! Waiting till later to delete it, just in case.

    function void checkNoOp(tb_trans agt, tb_trans mon); //Not sure about this, design spec is ambiguous 
        req_data_t scbResult, monResult;
        case(mon.cmd)
            GOOD: begin
                scbResult = 0; //Perform the operation (NoOp, So data = 0)
                monResult = mon.op1; //Get the result, which is stored in op1 field by the monitor

                if(monResult == scbResult) begin
                    successTests++;
                    $display($time, ": Successful left shift result validation! Results: Agent: %0d and Monitor: %0d match!", scbResult, monResult);
                end
                else begin
                    failedTests++;
                    $display($time, ": Failed left shift result verification! Results: Agent: %0d and Monitor: %0d do not match!", scbResult, monResult);
                end
            end
            INVL, ERR, NORE: begin
                failedTests++;
                $display($time, ": Failed left shift result verification! Monitor returned responce code: %0b", mon.cmd);
            end
            default:
                $display($time, ": Error with the checkLShift case statement! Bad response code data!");
        endcase
    endfunction: checkNoOp
    */
    virtual function bit checkFinished(); //For determining when we've tested all outstanding transactions
        if(max_trans_cnt < 1)
            return 1;
        else 
            return 0;
    endfunction: checkFinished
endclass: tb_scb