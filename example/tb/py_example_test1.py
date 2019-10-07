# -------------------------------------------------------------------------------
# --          ____  _____________  __                                          --
# --         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
# --        / / / / __/  \__ \  \  /                 / \ / \ / \               --
# --       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
# --      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
# --                                                                           --
# -------------------------------------------------------------------------------
# --! @file    tb_example_top.py
# --! @brief   python simulation driver for cosimtcp example 
# --! @author  Lukasz Butkowski  <lukasz.butkowski@desy.de>
# --! @company DESY
# --! @created 2019-03-14
# -------------------------------------------------------------------------------
# -- Copyright (c) 2019 DESY
# -------------------------------------------------------------------------------

# add cosimtcp path
import numpy as np
import sys
sys.path.insert(0, '../../client/python')

from cosimtcp import cosimtcp

# create cosimtcp object, connect to the simulation
cosim = cosimtcp('localhost', 1234)

# ---------------------------------------------------------
# example drive data set 1
dataA = np.arange(1, 100+1, 1)
dataB = np.arange(1, 100+1, 1)*2
valid_in = np.ones(1000)

# ---------------------------------------------------------
# fill the data buffers
cosim.send_data("A", dataA)
cosim.send_data("B", dataB)
cosim.send_data("VALID", valid_in)

cosim.restart()

# fun first 1 simulation step, no data from buffer used,
# half clock period, clk starts low
init_time = cosim.current_time()
if (init_time == 0):
    cosim.run_sim(1, 5, "ns", useData=0)


# ---------------------------------------------------------
# run simulation with the buffered data and record result
# 100 clock cycles of 10ns
cosim.run_sim(100, 10, "ns")


# ---------------------------------------------------------
# get result from the data buffers
dataC = cosim.get_data("C")
valid_out = cosim.get_data("VALID")

# ---------------------------------------------------------
# print results
print("# Model: A*B")
print(dataA*dataB)
print("# HDL result:")
print(dataC)

# ---------------------------------------------------------
# close simulator
cosim.quit()
