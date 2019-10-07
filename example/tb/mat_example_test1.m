% -------------------------------------------------------------------------------
% --          ____  _____________  __                                          --
% --         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
% --        / / / / __/  \__ \  \  /                 / \ / \ / \               --
% --       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
% --      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
% --                                                                           --
% -------------------------------------------------------------------------------
% --! @file    mat_example_test1.m
% --! @brief   matlab simulation driver for cosimtcp example
% --! @author  Lukasz Butkowski  <lukasz.butkowski@desy.de>
% --! @company DESY
% --! @created 2019-04-29
% -------------------------------------------------------------------------------
% -- Copyright (c) 2019 DESY
% -------------------------------------------------------------------------------

%% ---------------------------------------------------------
%% create cosim object, connect to the simulation
addpath('../../client/matlab')
%import *.*

cosim = cosimtcp('localhost',1234,1000000,60);


%% ---------------------------------------------------------
% create cosimtcp object
cosim.restart();

%% ---------------------------------------------------------
% fun first 1 simulation step, no data from buffer used,
% half clock period, clk starts low
init_time = cosim.current_time();
if init_time == 0
  cosim.run_sim(1, 5, 'ns', 0);
end

%% ---------------------------------------------------------
% input data vectors
dataA = (1:1:300) * (-1);
dataB = (1:1:300) * 2;
valid_in = ones(1,300);

%% ---------------------------------------------------------
% fill the data buffers
cosim.send_data('A', dataA);
cosim.send_data('B', dataB);
cosim.send_data('VALID', valid_in);

%% ---------------------------------------------------------
% run simulation with the buffered data and record result
% 100 clock cycles of 10ns
cosim.run_sim(300, 10, 'ns');

%% ---------------------------------------------------------
% get result from the data buffers
dataC = cosim.get_data('C');
valid_out = cosim.get_data('VALID');

matC=dataA .* dataB;
% disp('# Model: A*B')
% disp(matC)
% disp('# HDL result:')
% disp(dataC)
X(:,1) = matC;
X(:,2) = dataC;
plot(X)

%% ---------------------------------------------------------
% close simulator
cosim.quit()
