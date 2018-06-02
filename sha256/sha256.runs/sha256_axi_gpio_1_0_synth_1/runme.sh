#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/home/brancs/Xilinx/SDK/2017.4/bin:/home/brancs/Xilinx/Vivado/2017.4/ids_lite/ISE/bin/lin64:/home/brancs/Xilinx/Vivado/2017.4/bin
else
  PATH=/home/brancs/Xilinx/SDK/2017.4/bin:/home/brancs/Xilinx/Vivado/2017.4/ids_lite/ISE/bin/lin64:/home/brancs/Xilinx/Vivado/2017.4/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=/home/brancs/Xilinx/Vivado/2017.4/ids_lite/ISE/lib/lin64
else
  LD_LIBRARY_PATH=/home/brancs/Xilinx/Vivado/2017.4/ids_lite/ISE/lib/lin64:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/brancs/MEOCloud/CR/Get-Shaded-256/sha256/sha256.runs/sha256_axi_gpio_1_0_synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log sha256_axi_gpio_1_0.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source sha256_axi_gpio_1_0.tcl