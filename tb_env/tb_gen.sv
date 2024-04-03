/*

Generator class that creates transaction objects then sends them to the agent class VIA a mailbox.

Zachary Zazzara (40096894)

Created on: March 28th, 2024

*/

`include "tb_env/tb_trans.sv"

class tb_gen;

//Hold a random tb_trans object
rand tb_trans rand_tr;

//Terminate transaction generation when trans_cnt > max_trans_cnt
//Not 100% sure we need this, but probably do, so i'm putting it here for now.
int max_trans_cnt;

//Number of currently performed transactions
int trans_cnt = 0;

//Event flag that notifies when all transactions have been sent
event ended;

//transaction mailbox for generator -> agent
mailbox #(tb_trans) gen2agt

//Constructor
function new(mailbox #(tb_trans) gen2agt, int max_trans_cnt);
    this.gen2agt = gen2agt;
    this.max_trans_cnt = max_trans_cnt;
    rand_tr = new();
endfunction

task main();
    $display($time, ": Starting tb_gen for %0d transactions", max_trans_cnt);
    //This while loop runs until the randomly generated number of tests completes
    while(!end_of_test())
        begin
            tb_trans temp_tr;

            //wait & get transaction
            temp_tr = get_transaction();

            if(temp_tr.cmd != NOP)
                ++trans_cnt;

            gen2agt.put(temp_tr)
        end //end of while loop
    $display($time, ": Ending tb_gen\n");

    //Set the ended event flag to say the generator is finished
    ->ended; 
endtask

//Function checks to see how many more transaction objects need to be generated before the test is complete
//Same as in lab 4
virtual function int end_of_test();
	if(trans_cnt >= max_trans_cnt)
		return 1;
	else
		return 0;
endfunction

//Returns a transaction object associated with tr member
//Same as in lab 4
virtual function tr_trans get_transaction();
    rand_tr.trans_cnt = trans_cnt;
    if (! this.rand_tr.randomize())
      begin
        $display("tb_gen::randomize failed");
        $finish;
      end
    return rand_tr.copy();
endfunction

endclass: tb_gen
