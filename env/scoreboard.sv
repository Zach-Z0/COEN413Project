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
`include "tb_env/defs.sv"

class tb_scb;
    //TODO

    //Max # of transactions set in "test_cfg" class in "env.sv" file, passed here.
    int max_trans_cnt;

    //Flag to trigger end of the test
    event ended;

    //Test statistics
    //More than likely needs to be re-enforced with functional coverage bins and other stuff
    //This is just to get started
    int successTests;
    int failedTests;

    //Mailboxes for the incoming transactions, Agent -> Scoreboard/Checker, Monitor ->Scoreboard/Checker
    mailbox #(tb_trans) agt2scb, mon2scb;

    //Create the queues
    tb_trans monQue1 [$];
    tb_trans monQue2 [$];
    tb_trans monQue3 [$];
    tb_trans monQue4 [$];

    //Create the associatve arrays, index is the TAG as defined in "defs.sv"
    tb_trans agtArr1 [req_tag_t];
    tb_trans agtArr2 [req_tag_t];
    tb_trans agtArr3 [req_tag_t];
    tb_trans agtArr4 [req_tag_t];

    function new(int max_trans_cnt, mailbox #(tb_trans) agt2scb, mon2scb);
        this.max_trans_cnt = max_trans_cnt;
        this.agt2scb = agt2scb;
        this.mon2scb = mon2scb;
    endfunction

    task main();
        //TODO
    endtask: main

    task wrap_up();
        //TODO
    endtask: wrap_up
    //Other tasks here as needed (?)
endclass: tb_scb