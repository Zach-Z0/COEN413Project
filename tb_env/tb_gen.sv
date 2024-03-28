/*

Generator class that creates transaction objects then sends them to the agent class VIA a mailbox.

Zachary Zazzara (40096894)

Created on: March 28th, 2024
Last edited: March 28th, 2024


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


endclass
