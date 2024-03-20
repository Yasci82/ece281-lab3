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
--| FILENAME      : thunderbird_fsm.vhd
--| AUTHOR(S)     : Capt Phillip Warner, Capt Dan Johnson
--| CREATED       : 03/2017 Last modified 06/25/2020
--| DESCRIPTION   : This file implements the ECE 281 Lab 2 Thunderbird tail lights
--|					FSM using enumerated types.  This was used to create the
--|					erroneous sim for GR1
--|
--|					Inputs:  i_clk 	 --> 100 MHz clock from FPGA
--|                          i_left  --> left turn signal
--|                          i_right --> right turn signal
--|                          i_reset --> FSM reset
--|
--|					Outputs:  o_lights_L (2:0) --> 3-bit left turn signal lights
--|					          o_lights_R (2:0) --> 3-bit right turn signal lights
--|
--|					Upon reset, the FSM by defaults has all lights off.
--|					Left ON - pattern of increasing lights to left
--|						(OFF, LA, LA/LB, LA/LB/LC, repeat)
--|					Right ON - pattern of increasing lights to right
--|						(OFF, RA, RA/RB, RA/RB/RC, repeat)
--|					L and R ON - hazard lights (OFF, ALL ON, repeat)
--|					A is LSB of lights output and C is MSB.
--|					Once a pattern starts, it finishes back at OFF before it 
--|					can be changed by the inputs
--|					
--|
--|                 Binary State Encoding key
--|                 --------------------
--|                  State | Encoding
--|                 --------------------
--|                  OFF   |000 
--|                  ON    |001
--|                  R1    |010
--|                  R2    |011
--|                  R3    |100
--|                  L1    |101
--|                  L2    |110
--|                  L3    |111
--|                 --------------------
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : None
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
 
entity thunderbird_fsm is 
  port(
	   i_clk, i_reset  : in    std_logic;
       i_left, i_right : in    std_logic;
       o_lights_L      : out   std_logic_vector(2 downto 0);
       o_lights_R      : out   std_logic_vector(2 downto 0)
  );
end thunderbird_fsm;

architecture thunderbird_fsm_arch of thunderbird_fsm is 
      signal f_Q_next: std_logic_vector(1 downto 0) := "10";
      signal w_stoplight : std_logic_vector(2 downto 0) := "000"; -- RYG one-hot
      signal f_clk	:	std_logic	:= '0';
      signal w_reset : std_logic := '0';
      signal w_clk : std_logic := '0';

-- CONSTANTS ------------------------------------------------------------------
  signal f_s : STD_LOGIC_vector(2 downto 0):="000";
  signal f_s_next : STD_LOGIC_vector(2 downto 0):="000";
begin

	-- CONCURRENT STATEMENTS --------------------------------------------------------	
	f_s_next(0) <= (not i_right and i_left and not f_s(0) and not f_s(1) and not f_s(2)) or
	               ( i_right and i_left and not f_S(0) and not f_S(1) and not f_S(2)) or
	               (not f_S(0) and f_S(1) and not f_S(2)) or 
	               (not f_S(0) and  f_S(1) and  f_S(2));
    f_s_next(1) <= (i_right and not i_left and not f_S(0) and not f_S(1) and not f_S(2)) or 
                   (not f_S(0) and f_S(1) and not f_S(2)) or 
                   (f_S(0) and not f_S(1) and f_S(2)) or 
                   (not f_S(0) and  f_S(1) and  f_S(2));
    f_s_next(2) <= (not i_right and i_left and not f_S(0) and not f_S(1) and not f_S(2)) or 
                   ( f_S(0) and f_S(1) and not f_S(2)) or 
                   (f_S(0) and not f_S(1) and f_S(2)) or 
                   (not f_S(0) and  f_S(1) and  f_S(2));
                           
    ---------------------------------------------------------------------------------
    o_lights_L(0) <= (not f_S(1) and f_S(0)) or
                     (f_S(2) and f_S(1));
    o_lights_L(1) <= (not f_S(2) and not f_S(1) and f_S(0)) or
                     (f_S(2) and f_S(1));
    o_lights_L(2) <= (f_S(0) and not f_S(1) and not f_S(2)) or 
                     (f_S(0) and f_S(1) and f_S(2));           
    o_lights_R(0) <= (f_S(0) and not f_S(1) and not f_S(2)) or 
                     (f_S(1) and not f_S(2)) or 
                     (not f_S(0) and not f_S(1) and f_S(2));    
    o_lights_R(1) <= (f_S(0) and not f_S(2)) or 
                     (not f_S(0) and not f_S(1) and f_S(2));
	o_lights_R(2) <= (f_S(0) and not f_S(1) and not f_S(2)) or 
	                 (not f_S(0) and not f_S(1) and f_S(2));
    
    
    
    
    
	-- PROCESSES --------------------------------------------------------------------
    ops_process: process(i_clk, i_reset)
            begin
                	--Reset state is yellow
            if i_reset = '1' then
                f_S <= "000";        -- reset state is yellow
            elsif (rising_edge(i_clk)) then   --is the rising_edge() function defined or is it a function in the lib?
                f_S <= f_S_next;    -- next state becomes current state
                end if;
        
            end process ops_process;
	-----------------------------------------------------					   
				  
end thunderbird_fsm_arch;