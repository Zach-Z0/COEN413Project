/*

Environment class which instanciates the following:
	-TB Generator
	-TB Agent
	-More items TBD


Zachary Zazzara (40096894)

Created on: March 28th, 2024

*/

`include "tb_env/tb_trans.sv"
`include "tb_env/tb_gen.sv"
`include "tb_env/tb_agt.sv"
//TODO
//Will need more includes here as we write more classes

class test_cfg; //Configuration class
	//THIS SETS max_trans_cnt for other modules
	rand int trans_cnt;

	//For now arbitrarily chosen constraint based off labs 3 & 4.
	constraint c_trans_cnt {
		(trans_cnt > 0) && (trans_cnt < 100); 
	}
endclass: test_cfg

class env;

//Instanciate test config
test_cfg tcfg;

//Instanciate transactors
//TODO
tb_gen gen;

//driver
//monistor
//scoreboard/checker
//agent


//Instanciate mailboxes here
//Mailboxes: Generator -> Agent, Agent -> Driver(TODO), Monitor -> Scoreboard/Checker(TODO)
mailbox #(tb_trans) gen2agt, agt2dvr, agt2scb, scb2agt, mon2scb ;

//Interface declaration goes here, I think
//Virtual interface???? Probably.

function new(/*Interface here*/);
	//'this.' interface assignment here
	//Mailboxs go here, 16 items max in each due to (4 input lines) * (4 outstanding commands per line)
	//This might be wrong? I don't know, it's my best guess right now.
	//Possible deadlock by doing this???? Probably not.
	//TODO (?)
	gen2agt = new(16);
	agt2dvr = new(16);
	agt2scb = new(16);
	scb2agt = new(16);
	mon2scb = new(); //I don't think this one needs a limit?


	tcfg = new(); //Instanciate test config

	//Copy pasted from lab 4, just seems good to have in case.
	if (!tcfg.randomize()) 
		begin
			$display("test_cfg::randomize failed");
			$finish;
		end
	//call new() function for all modules of the test bench
	gen = new(gen2agt, tcfg.trans_cnt);
	agt = new(gen2agt, agt2dvr, agt2scb, scb2agt); //Might need more stuff in here? Not sure
	//TODO
	//Driver
	//Monitor
	//Scoreboard/checker
endfunction: new

virtual task pre_test();
	//TODO, refer to lab 4 env file
	//Sync scoreboard max_trans_cnt with generator max_trans_cnt
	fork
		//start scoreboard, driver, monitor, agent mains
		agt.main();
	join_none
endtask: pre_test

virtual task test();
	//TODO
	//reset the DUT through the Driver module	
	fork
		gen.main();
		//TODO
	join_none
endtask: test	

//Clean up function post running tests, waiting for everything to finish
virtual task post_test();
	//TODO
	fork
    	wait(gen.ended.triggered);
		//Scoreboard ended trigger here, see wait statement above
		agt.wrap_up();
		//put other wrap up tasks here as needed
		//driver
		//monitor/checker
	join
endtask: post_test

task run();
	pre_test();
    test();
    post_test();
endtask: run

endclass: env