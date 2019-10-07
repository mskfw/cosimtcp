-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( m | s | k )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
--! @file  example_top_tb.vhd
--! @brief testbench of example entity for cosimtcp
--! @author	Lukasz Butkowski	<lukasz.butkowski@desy.de>
--! @company DESY
--! @created 2019-04-24
-------------------------------------------------------------------------------
-- Copyright (c) 2019 DESY Lukasz Butkowski
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity example_top_tb is

end entity example_top_tb;

-------------------------------------------------------------------------------

architecture sim of example_top_tb is

  constant CON_CLK_PERIOD : time := 10 ns;

  -- component generics
  constant g_data_width : natural := 18;
  constant g_data_base  : natural := 0;

  -- component ports
  signal pi_clk		 : std_logic:='0';
	signal pi_valid	 : std_logic:='0';
	signal pi_data_a : std_logic_vector(g_data_width-1 downto 0):=(others => '0');
	signal pi_data_b : std_logic_vector(g_data_width-1 downto 0):=(others => '0');
	signal po_valid	 : std_logic:='0';
	signal po_data_c : std_logic_vector(g_data_width-1 downto 0):=(others => '0');

begin  -- architecture sim

  -- component instantiation
  uut: entity work.example_top
    generic map (
      g_data_width => g_data_width,
      g_data_base  => g_data_base
    )
    port map (
      pi_clk		=> pi_clk,
			pi_valid	=> pi_valid,
			pi_data_a => pi_data_a,
			pi_data_b => pi_data_b,
			po_valid	=> po_valid,
			po_data_c => po_data_c
    );

  pi_clk <= not pi_clk after CON_CLK_PERIOD/2;

  -- prc_clk: process is
  -- begin
  --   p_i_clk <= '1';
  --   wait for CON_CLK_PERIOD/2;
  --   p_i_clk <= '0' ;
  --   wait for CON_CLK_PERIOD/2;
  -- end process prc_clk;


end architecture sim;
-------------------------------------------------------------------------------
