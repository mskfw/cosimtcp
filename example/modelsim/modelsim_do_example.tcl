# -------------------------------------------------------------------------------
# --          ____  _____________  __                                          --
# --         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
# --        / / / / __/  \__ \  \  /                 / \ / \ / \               --
# --       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
# --      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
# --                                                                           --
# -------------------------------------------------------------------------------
# --! @file    modelsim_do_example.tcl
# --! @brief   modelsim tcl script for example of cosimtcp library
# --! @author  Lukasz Butkowski  <lukasz.butkowski@desy.de>
# --! @company DESY
# --! @created 2019-03-13
# -------------------------------------------------------------------------------
# -- Copyright (c) 2019 DESY
# -------------------------------------------------------------------------------

## ------------------------------------------------------------------------------
## compile
## ------------------------------------------------------------------------------

# create empty list
set designLibrary {}

# fill lists
lappend designLibrary ../src/example_top.vhd
lappend designLibrary ../tb/example_top_tb.vhd

set topLevel  work.example_top_tb


vlib designLibrary
vmap work designLibrary

foreach file $designLibrary {
    vcom -2008 $file
}

eval vsim $topLevel
noview wavel

add wave /*

## -----------------------------------------------------------------------------
## cosimtcp
## -----------------------------------------------------------------------------
source ../../server/modelsimServer.tcl

global input
global output

set  input(A,path)       uut\/pi_data_a
set  input(B,path)       uut\/pi_data_b
set  input(VALID,path)   uut\/pi_valid

set  output(C,path)      uut\/po_data_c
set  output(VALID,path)  uut\/po_valid

cosimtcpServer 1234
