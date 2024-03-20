--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner
--| CREATED       : 03/2017
--| DESCRIPTION   : This file tests the thunderbird_fsm modules.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm_enumerated.vhd, thunderbird_fsm_binary.vhd, 
--|				   or thunderbird_fsm_onehot.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;

architecture test_bench of thunderbird_fsm_tb is 
	
	component thunderbird_fsm is 
	  port(
		  i_reset, i_clk : in std_logic;
          i_left, i_right : in std_logic;
          o_lights_L : out std_logic_vector(2 downto 0);
          o_lights_R : out std_logic_vector(2 downto 0)
	  );
	end component thunderbird_fsm;

	-- test I/O signals
	signal w_reset : std_logic := '0';
    signal w_clk : std_logic := '0';
    signal w_Left : std_logic := '0';
    signal w_Right : std_logic := '0';
    
	-- constants
	constant k_clk_period : time := 10 ns;
	
	--do i need to add these outputs just like we did in lab2 and also as it is stated in ice4 that they should be 2-bit signals?
	signal w_lights_L : std_logic_vector(2 downto 0) := "000";
	signal w_lights_R : std_logic_vector(2 downto 0) := "000";
	
begin
	-- PORT MAPS ----------------------------------------
	uut: thunderbird_fsm port map(
           i_reset => w_reset,
           i_clk => w_clk,
           i_left => w_Left,
           i_right => w_Right,
           o_lights_R => w_lights_R,
                         o_lights_L => w_lights_L
        );
	-----------------------------------------------------
	
	-- PROCESSES ----------------------------------------	
    -- Clock process ------------------------------------
    clk_process: process
    begin 
        w_clk <= '0';
        wait for k_clk_period/4;
        w_clk <= '1';
        wait for k_clk_period/4;
   end process;
	-----------------------------------------------------
	
	-- Test Plan Process --------------------------------
	TEST_plan: process
	begin
	
        --off state	
	   w_Left <= '0'; w_Right <= '0'; wait for k_clk_period/2;
            assert w_lights_L = "000" report "left blinker should be off" severity error;
            assert w_lights_R = "000" report "right blinker should be off" severity error;
         
         --left blinker state   
       w_Left <= '1'; w_Right <= '0'; wait for k_clk_period/2;
            assert w_lights_L = "001" report "left blinker 1 should be on" severity error;
            assert w_lights_R = "000" report "right blinkers should be off" severity error;
          wait for k_clk_period;
            assert w_Lights_L = "011" report "left blinker 2 should be on" severity error;
            assert w_Lights_R = "000" report "right blinkers should be off" severity error;
          wait for k_clk_period;
            assert w_Lights_L = "111" report "left blinker 3 should be on" severity error;
            assert w_lights_R = "000" report "right blinkers should be off" severity error;
          wait for k_clk_period;
            assert w_lights_L = "000" report "left blinker should be off" severity error;
            assert w_lights_R = "000" report "right blinker should be off" severity error;
       
       --right blinker states
       w_Left <= '0'; w_Right <= '1'; wait for k_clk_period/2;
            assert w_lights_L = "000" report "left blinkers should be off" severity error;
            assert w_lights_R = "001" report "right blinker 1 should be on" severity error;
         wait for k_clk_period;
            assert w_Lights_L = "000" report "left blinkers should be off" severity error;
            assert w_Lights_R = "011" report "right blinker 2 should be on" severity error;
         wait for k_clk_period;
            assert w_Lights_L = "000" report "left blinkers should be off" severity error;
            assert w_lights_R = "111" report "right blinker 3 should be on" severity error;
         wait for k_clk_period;
            assert w_lights_L = "000" report "left blinker should be off" severity error;
            assert w_lights_R = "000" report "right blinker should be off" severity error;
            
         --on then off states
         w_Left <= '1'; w_Right <= '1'; wait for k_clk_period/2;
              assert w_lights_L = "111" report "left blinkers should be on" severity error;
              assert w_lights_R = "111" report "right blinkers should be on" severity error;
           wait for k_clk_period;
         w_Left <= '0'; w_Right <= '0'; wait for k_clk_period;
              assert w_lights_L = "000" report "left blinkers should be off" severity error;
              assert w_lights_R = "00" report "right blinkers should be off" severity error;
           wait for k_clk_period;
	   
	-----------------------------------------------------	
	wait;
	end process;
end test_bench;
