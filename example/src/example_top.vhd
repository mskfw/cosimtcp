-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( m | s | k )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
--! @file    example_top.vhd
--! @brief   example top entity for cosimtcp
--! @author  lukasz butkowski  <lukasz.butkowski@desy.de>
--! @company DESY
--! @created 2019-03-12
--! simple functionality of multiplication of fixed numbers
-------------------------------------------------------------------------------
-- Copyright (c) 2019 DESY
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! local libraries
library work;

entity example_top is
  generic (
    g_data_width : natural := 18;                               -- data width
    g_data_base  : natural := 16                                -- data fractional bits
    );
  port (
    pi_clk    : in  std_logic;                                 -- clock input
    pi_valid  : in  std_logic;                                 -- input data valid signal
    pi_data_a : in  std_logic_vector(g_data_width-1 downto 0); -- data a input
    pi_data_b : in  std_logic_vector(g_data_width-1 downto 0); -- data b input
    po_valid  : out std_logic;                                 -- data out valid signal
    po_data_c : out std_logic_vector(g_data_width-1 downto 0)  -- data b out
  );
end entity example_top;


architecture beh of example_top is

begin

  -- multiply 2 fractional numbers
  prs_main: process (pi_clk) is
  begin
    if rising_edge(pi_clk) then       -- rising clock edge
      po_valid   <= pi_valid;         -- data out valid after 1 clock cycle
      po_data_c  <= std_logic_vector(resize(shift_right(signed(pi_data_a) * signed(pi_data_b),g_data_base),g_data_width));
    end if;
  end process prs_main;

end architecture beh;
