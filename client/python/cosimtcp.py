# ------------------------------------------------------------------------------
# --          ____  _____________  __                                         --
# --         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
# --        / / / / __/  \__ \  \  /                 / \ / \ / \              --
# --       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
# --      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
# --                                                                          --
# ------------------------------------------------------------------------------
# --! @file    cosimtcp.py
# --! @brief   main cosimtcp python server side class
# --! @author  Lukasz Butkowski  <lukasz.butkowski@desy.de>
# --! @company DESY
# --! @created 2019-04-24
# ------------------------------------------------------------------------------
# -- Copyright (c) 2019 DESY Lukasz Butkowski
# ------------------------------------------------------------------------------

# import sys

import socket
from time import sleep
import numpy as np


class cosimtcp:
    def __init__(self, addr, port):
        self.addr = addr
        self.port = port
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.connect((addr, port))

    def __del__(self):
        self.sock.close()

    def send_str(self, message):
        msgSnd = message + "\n"
        self.sock.sendall(msgSnd.encode())

    def send_recv_str(self, message, timeout=None):
        if timeout is not None:
            self.sock.settimeout(timeout)
        msgSnd = message + "\n"
        self.sock.sendall(msgSnd.encode())
        msgRcvd = self.recvstr()
        return msgRcvd

    def send_data(self, name, data, offset=0):
        data_str = np.array2string(data.astype(int))
        data_str = data_str[1:len(data_str)-1]  # remove brackets
        data_str = data_str.replace("\n", "")   # remove end lines from string
        message = "set " + name + " " + str(offset) + " " + data_str
        msgRcvd = self.send_recv_str(message)
        return msgRcvd

    def recvstr(self):
        msgRcvd = ''
        while True:
            try:
                data = self.sock.recv(4096)
            except socket.timeout as e:
                err = e.args[0]
                if err == "timed out":
                    sleep(1)
                    print("Recv timed out, quitting")
                    break
                else:
                    print(e)
                    break
            except socket.error as e:
                # Something else happened, handle error, exit, etc.
                print(e)
                break
            else:
                if len(data) == 0:
                    print("orderly shutdown on server end")
                    break
                else:
                    data_str = data.decode()
                    msgRcvd += data_str
                    if (data.find(b"\n") >= 0):  # break if end of line detected
                        break
        return msgRcvd

    def get_data(self, name, offset=0):
        msgSnd = "get " + name + " " + str(offset)
        msgRcvd = self.send_recv_str(msgSnd)
        if (len(msgRcvd) - 1) == 0:  # if there is no data just \n
            return np.array([])
        else:
            return np.fromstring(msgRcvd, dtype=int, sep=' ')

    def run_sim(self, steps, timeStep, timeUnit="ns", useData=1, outStyle="clear"):
        # steps = steps - 1
        # print(steps)
        message = \
            "sim run " + str(steps) + " " + str(timeStep) + " " + timeUnit + " " \
            + str(useData) + " " + outStyle
        result = self.send_recv_str(message)
        return result

    def raw_command(self, command):
        msgSnd = "raw " + command
        msgRcvd = self.send_recv_str(msgSnd)
        return msgRcvd

    def current_time(self, unit=False):
        msgSnd = "cmd " + "get_current_time" + " " + str(unit)
        msgRcvd = self.send_recv_str(msgSnd)
        if unit:
            return msgRcvd
        else:
            return float(msgRcvd)

    def restart(self):
        msgSnd = "cmd " + "restart"
        msgRcvd = self.send_recv_str(msgSnd)
        return msgRcvd

    def quit(self):
        self.send_str("quit")
