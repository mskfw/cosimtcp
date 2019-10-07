# -------------------------------------------------------------------------------
# --          ____  _____________  __                                          --
# --         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
# --        / / / / __/  \__ \  \  /                 / \ / \ / \               --
# --       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
# --      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
# --                                                                           --
# -------------------------------------------------------------------------------
# --! @file    vivado_do_example.tcl
# --! @brief   vivado tcl script for example of cosimtcp library
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

set topLevel  example_top_tb

# VIVADO project and start simulation
create_project cosimtcp_example -force

add_files $designLibrary

set_property top $topLevel [get_filesets sim_1]
set_property -name xelab.more_options -value {-debug all} -objects [get_filesets sim_1]
set_property runtime {0} [get_filesets sim_1]
launch_simulation -simset sim_1 -mode behavioral
add_wave /$topLevel/*

## -----------------------------------------------------------------------------
## cosimtcp
## -----------------------------------------------------------------------------
source ../../server/vivadoServer.tcl

global input
global output

global input
global output

set  input(A,path)       uut\/pi_data_a
set  input(B,path)       uut\/pi_data_b
set  input(VALID,path)   uut\/pi_valid

set  output(C,path)      uut\/po_data_c
set  output(VALID,path)  uut\/po_valid

cosimtcpServer 1234
