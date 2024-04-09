/*

Environment class which instanciates the following:
	-TB Generator
	-TB Agent
	-TB Scoreboard
	-TB Monitor
	-TB Driver

Starts tests, pre-tests, and post-tests.

Zachary Zazzara (40096894)
ze xi si (40175054)
reated on: March 28th, 2024

*/
// we are importing all as package...


//====================================
import transPKG::*;
import defs::*;
import agentPKG::*;
import genPKG::*;
import dvrPKG::*;
import moniPKG::*;
import scbPKG::*;

//=========================================

//`include "tb_env/tb_if.sv"
//`include "tb_env/tb_agt.sv"
//`include "tb_env/tb_dvr.sv"
//`include "tb_env/tb_moni.sv"
//`include "tb_env/tb_gen.sv"
//`include "env/scoreboard.sv"

//test constraint here ==========================
//randomized
class test_cfg; 
	
	rand int trans_cnt = 0;

	constraint c_trans_cnt {
		(trans_cnt > 0) && (trans_cnt < 100); 
	}

endclass: test_cfg

//============================================== 

class env;

	//Instanciate test config
	test_cfg tcfg;

	//============================================
	//Instanciate transactors
    tb_gen gen;
	tb_agt agt;
	tb_moni mon;
	tb_dvr dvr;
	tb_scb scb;

	//initialization
	//============================================ 

	//Instanciate mailboxes here

	//Mailboxes: Generator -> Agent, Agent -> Driver, Monitor -> Scoreboard/Checker (and back)

	mailbox #(tb_trans) gen2agt, agt2dvr, agt2scb, scb2agt;

	mailbox #(tb_trans_out) mon2scb;

	//========================================
	
	//Interface declaration
	virtual tb_if interf;

	function new(virtual tb_if interf);
		$display("Got into the new function of env");
		this.interf = interf;

		//Mailboxs go here, 16 items max in each due to (4 input lines) * (4 outstanding commands per line)
		//Removed item limit for testing 
		gen2agt = new();
		agt2dvr = new();
		agt2scb = new();
		scb2agt = new(); //Key return

		mon2scb = new();


		tcfg = new(); //Instanciate test config

		if (!tcfg.randomize()) begin
				$display("test_cfg::randomize failed");
				$finish;
			end
		//call new() function for all modules of the test bench

		gen = new(gen2agt, tcfg.trans_cnt);
		agt = new(gen2agt, agt2dvr, agt2scb, scb2agt);
		dvr = new(this.interf, agt2dvr);
		mon = new(this.interf, mon2scb);
		scb = new(tcfg.trans_cnt, agt2scb, scb2agt, mon2scb);

	endfunction: new

	virtual task pre_test();
		//Sync scoreboard max_trans_cnt with generator max_trans_cnt
		$display("Got to pre_test pre-fork");
		fork
			//start scoreboard, driver, monitor, agent mains
			agt.main();
			dvr.main();
			mon.main();
			scb.main();
		join_none
		$display("Got to pre_test post-fork");
	endtask: pre_test

	virtual task test();
		begin
		$display("Got to test task");
		dvr.reset(); 
		#500;
		$display("Got to tesk task pre-fork");
		end

		fork
			gen.main();
		join_none
		$display("Got to tesk task post-fork");
	endtask: test	

	//Clean up function post running tests, waiting for everything to finish
	virtual task post_test();
		
		bit gen_completed = 0;
		bit scb_completed =0; 
		$display($time, ": Reached before fork post test.");
		#10;
		fork begin
			$display($time, ": Waiting for gen and scb to end trigger.");
			wait(gen.ended.triggered());
			gen_completed =1;
			$display ("gen end triggered");
			agt.wrap_up();
			end
			
			begin
			wait(scb.ended.triggered());
			$display ("scb end triggered");
			scb_completed = 1;
			dvr.wrap_up();
			mon.wrap_up();
			
			end
			
		join
		
		$display($time, ": Reached post_test post-join.");
		
		
	endtask: post_test

	task run();
		$display("Got to the main Env's run function");
		pre_test();
		$display("Run pre-test completed");
		#100;
		test();
		$display("Run test completed");
		#100000;
		post_test();
		$display("Run post test completed");
	endtask: run
endclass: env