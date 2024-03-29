/*
Agent class which handles the the generated trnasaction instances, and passes them to both the scoreboard/checker module
and the driver module.

This also needs to handle the logic for not re-using tag bits on each of the 4 input lines untill the previous useage of that 
tag is freed up (4 available tags per input), tags are freed up once the associated output is checked vs the expected output
generated by the scoreboard. 

Also probably need to include some functional coverage in here somewhere, but we'll get to that later, I guess?

Zachary Zazzara (40096894)

Created on: March 28th, 2024
*/

`include "tb_env/tb_gen.sv"
`include "apb_env/apb_trans.sv"
`include "tb_env/defs.sv" //Im not sure if I need this include
//other includes? I'm not sure right now

class agt;
    //Instanticate the mailboxes
    mailbox #(tb_trans) gen2agt, agt2dvr, agt2scb, scb2agt;

    //Instanciate somewhere to hold a transaction object
    tb_trans tr, trRtrn;


    //Semaphores for keeping track of how many pending transactions have been sent to the DUT
    //Needs to be accessible from the scoreboard, i'm pretty sure.
    semaphore in1_sem, in2_sem, in3_sem, in4_sem;

    //Define queues that hold available tags for all 4 ports
    req_tag_t in1_avl_tags[$] = {TAG0, TAG1, TAG2, TAG3};
    req_tag_t in2_avl_tags[$] = {TAG0, TAG1, TAG2, TAG3};
    req_tag_t in3_avl_tags[$] = {TAG0, TAG1, TAG2, TAG3};
    req_tag_t in4_avl_tags[$] = {TAG0, TAG1, TAG2, TAG3};

    function new(mailbox #(tb_trans) gen2agt, agt2dvr, agt2scb, scb2agt);
        this.gen2agt = gen2agt;
        this.agt2dvr = agt2dvr;
        this.agt2scb = agt2scb;
        this.scb2agt = scb2agt; //This is purely for returning semaphores and keys.
        //might need more here later?
    endfunction

    task main();
        in1_sem = new(4);
        in2_sem = new(4);
        in3_sem = new(4);
        in4_sem = new(4);

        forever begin //maybe change the forever to have a termination condition of some sort?
            gen2agt.get(tr); //Get a transaction object

            releaseKey(); //Check to see if any keys are waiting to be returned
            #10 //This is just here cuz it makes me feel better... shouldn't be necessary.

            /*
            Check which port the transaction wants, attempt to get it a key (secures it 1/4 of the tags)
            if able to grab a key, assign first available tag, tag queue SHOULD never be empty.
            If it's empty for some reason... timing issue? Scoreboard should be returning them before releasing the key.
            How to return the key? Another mailbox that just says the keys are free now? Maybe. 
            */
            case(tr.port)
                1: begin
                    in1_sem.get(1); //DONT FORGET TO RETURN THE KEYS IN THE SCOREBOARD/CHECKER!!!!
                    tr.tag = in1_avl_tags.pop_front();
                    $display($time, ": Assigning port %0b current transaction tag: %0b", tr.port, tr.tag); //DEBUG                    
                end
                2: begin
                    in2_sem.get(1);
                    tr.tag = in2_avl_tags.pop_front();
                    $display($time, ": Assigning port %0b current transaction tag: %0b", tr.port, tr.tag); //DEBUG
                end
                3: begin
                    in3_sem.get(1);
                    tr.tag = in3_avl_tags.pop_front();
                    $display($time, ": Assigning port %0b current transaction tag: %0b", tr.port, tr.tag); //DEBUG
                end
                4: begin
                    in4_sem.get(1);
                    tr.tag = in4_avl_tags.pop_front();
                    $display($time, ": Assigning port %0b current transaction tag: %0b", tr.port, tr.tag); //DEBUG
                end
                default:
                    $display($time, ": Error with the agent tag assign case statement! Bad port data!");
            endcase
            agt2dvr.put(tr); //push the transaction to the driver mailbox
            //TODO //push the transaction to the scoreboard mailbox
        end
        $display($time, ": Ending tb_agt");
    endtask: main

    //Checks to see if any keys have been returned by the scoreboard/checker, returns them and releases semaphores
    task releaseKey(); 
        if(scb2agt.num() > 0) begin
            scb2agt.get(trRtrn);

            case(trRtrn.port)
                1: begin
                    in1_avl_tags.push_back(trRtrn.tag); //return the key to the queue BEFORE releasing the semaphore!
                    in1_sem.put(1);
                end
                2: begin
                    in2_avl_tags.push_back(trRtrn.tag);
                    in2_sem.put(1);
                end
                3: begin
                    in3_avl_tags.push_back(trRtrn.tag);
                    in3_sem.put(1);

                end
                4: begin
                    in4_avl_tags.push_back(trRtrn.tag);
                    in4_sem.put(1);
                end
                default:
                    $display($time, ": Error with the agent tag return case statement! Bad port data!");
            endcase
        end
    endtask: releaseKey

    task wrap_up();
        //Put end of test stuff here, if needed.
    endtask: wrap_up
endclass: agt