#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2018.2.2 (64-bit)
#
# Filename    : elaborate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for elaborating the compiled design
#
# Generated by Vivado on Wed Jul 17 21:52:40 EDT 2019
# SW Build 2348494 on Mon Oct  1 18:25:39 MDT 2018
#
# Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
#
# usage: elaborate.sh
#
# ****************************************************************************
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep xelab -wto a63eb796c6064b9097d15172e19a5c15 --incr --debug typical --relax --mt 8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot gf_poly_add_tb_behav xil_defaultlib.gf_poly_add_tb xil_defaultlib.glbl -log elaborate.log
