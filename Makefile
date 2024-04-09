#########################################################################
## Purpose: Makefile for Chap_1_Verification_Guidelines/homework_solution
## Author: Chris Spear
##
## REVISION HISTORY:
## $Log: Makefile,v $
## Revision 1.1  2011/05/28 14:57:35  tumbush.tumbush
## Check into cloud repository
##
## Revision 1.2  2011/05/03 22:06:50  Greg
## Updated to common Makefile and to use Makefile_non_DPI
##
#########################################################################

FILES = tb_env/defs.sv tb_env/tb_trans.sv tb_env/tb_agt.sv tb_env/tb_gen.sv tb_env/tb_dvr.sv tb_env/tb_moni.sv env/scoreboard.sv env/top.sv hdl/calc2_top.v tests/test.sv tb_env/tb_if.sv env/wrapper.sv env/env.sv
TOPLEVEL = top

include ../Makefiles/non_DPI/Makefile_non_DPI
