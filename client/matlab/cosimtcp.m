% -------------------------------------------------------------------------------
% --          ____  _____________  __                                          --
% --         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
% --        / / / / __/  \__ \  \  /                 / \ / \ / \               --
% --       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
% --      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
% --                                                                           --
% -------------------------------------------------------------------------------
% --! @file    cosimtcp.m
% --! @brief   main cosimtcp matlab client side class
% --! @author  Lukasz Butkowski  <lukasz.butkowski@desy.de>
% --! @company DESY
% --! @created 2019-04-24
% -------------------------------------------------------------------------------
% -- Copyright (c) 2019 DESY Lukasz Butkowski
% -------------------------------------------------------------------------------


classdef cosimtcp
  properties
    addr
    port
    sock
  end

  methods
    %% constructor
    function obj = cosimtcp(addr,port,bufferSize,timeout)
      if nargin == 2
        bufferSize = 2048;
      end
      if nargin == 3
        timeout = 10;
      end
      obj.addr = addr;
      obj.port = port;
      obj.sock = tcpip(addr, port, 'NetworkRole', 'client', 'Timeout',timeout);
      obj.sock.BytesAvailableFcnMode = 'terminator';
      obj.sock.Terminator = 'LF';
      obj.sock.ReadAsyncMode = 'continuous';
      obj.sock.OutputBufferSize = bufferSize;
      obj.sock.InputBufferSize = bufferSize;
      fopen(obj.sock);
    end

    function delete(obj)
      fclose(obj.sock);
      delete(obj.sock);
      clear obj.sock;
    end


    function send_str(obj,message)
      msgSnd = sprintf('%s\n', message);
      fprintf(obj.sock,msgSnd);
    end

    function msgRcvd = send_recv_str(obj,message)
      msgSnd = sprintf('%s\n', message);
      fprintf(obj.sock,msgSnd);
      msgRcvd = fscanf(obj.sock,'%c');
    end

    function msgRcvd = send_data(obj, name, data, offset)
      if nargin == 3
        offset = 0;
      end
      data_str=mat2str(data);
      message = sprintf('set %s %d %s',name,offset,data_str(2:end-1));
      msgRcvd = obj.send_recv_str(message);
    end

    function data = get_data(obj, name, offset)
      if nargin == 2
        offset = 0;
      end
      message = sprintf('get %s %d',name,offset);
      msgRcvd = obj.send_recv_str(message);
      data = str2double(strsplit(msgRcvd));
    end

    function msgRcvd = run_sim(obj, steps, timeStep, timeUnit, useData, outStyle)
      if nargin < 4
        timeUnit = 'ns';
      end
      if nargin < 5
        useData = 1;
      end
      if nargin <6
        outStyle = 'clear';
      end
      message = sprintf('sim run %d %d %s %d %s',steps, timeStep, timeUnit, useData, outStyle);
      msgRcvd = obj.send_recv_str(message);
    end

    function msgRcvd = raw_command(obj,command)
      msgSnd = sprintf('raw %s',command);
      msgRcvd = obj.send_recv_str(msgSnd);
    end

    function msgRcvd = current_time(obj,withoutUnit)
      if nargin == 1
        withoutUnit = 0;
      end
      msgSnd  = sprintf('cmd get_current_time %d',withoutUnit);
      msgRcvd = obj.send_recv_str(msgSnd);
    end

    function msgRcvf = restart(obj)
      msgSnd = 'cmd restart';
      msgRcvd = obj.send_recv_str(msgSnd);
    end

    function quit(obj)
      obj.send_str('quit');
    end

  end
end

