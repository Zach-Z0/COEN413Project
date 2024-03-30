//zexi si 40175054

class moni;
   
    //TODO, monitor all activity
    mailbox #(tb_trans) dvr2scb;
    mailbox #(tb_trans) agt2scb;

    //=============


    //=============

    function new(virtual tb_if.Master tb_master_if, mailbox #(tb_trans) dvr2scb, mailbox #(tb_trans) agt2scb);
        this.tb_master_if = tb_master_if;
        this.dvr2scb = dvr2scb;
        this.agt2scb = agt2scb;

    endfunction






endmodule