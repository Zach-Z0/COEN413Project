/*

Environment class which instanciates the following:
	-TB Generator
	-More items TBD


Zachary Zazzara (40096894)

Created on: March 28th, 2024
Last edited: March 28th, 2024

*/

`include "tb_env/tb_trans.sv"
`include "tb_env/tb_gen.sv"
//TODO
//Will need more includes here as we write more classes

class test_cfg;

//This was used in labs to generate a random number of test cases, seems useful, may remove later?
rant int trans_cnt;

//For now arbitrarily chosen constraint based off labs 3 & 4.
constraint c_trans_cnt {
	(trans_cnt > 0) && (trans_cnt < 100); 
}

endclass: test_cfg

class env;

//Instanciate test config
test_cfg tcfg;

//Instanciate transactors
tb_gen gen;
//TODO

//Instanciate mailboxes here
//Mailboxes: Generator -> Agent, Agent -> Driver(TODO), Monitor -> Scoreboard/Checker(TODO)
mailbox #(tb_trans)

endclass: env