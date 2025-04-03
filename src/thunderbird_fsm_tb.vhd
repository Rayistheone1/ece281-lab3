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
		i_clk, i_reset  : in    std_logic;
        i_left, i_right : in    std_logic;
        --o_state         : out   std_logic_vector(7 downto 0)--;
        o_lights_L      : out   std_logic_vector(2 downto 0);
        o_lights_R      : out   std_logic_vector(2 downto 0)
	  );
	end component thunderbird_fsm;

	-- test I/O signals
	signal w_clk : std_logic := '0';
	signal w_reset : std_logic := '0';
	signal w_left : std_logic := '0';
	signal w_right : std_logic := '0';
	signal w_lights_L : std_logic_vector(2 downto 0);
	signal w_lights_R : std_logic_vector(2 downto 0);
--	signal w_state : std_logic_vector(7 downto 0) := "00000000";
--	signal w_lights : std_logic_vector(7 downto 0) := "00000000"; -- RYG one-hot
	-- constants
	constant k_clk_period : time := 10 ns;

	
begin
	-- PORT MAPS ----------------------------------------
	uut: thunderbird_fsm port map (
          i_left => w_left,
          i_right => w_right,
          i_reset => w_reset,
          i_clk => w_clk,
          o_lights_L => w_lights_L,
          o_lights_R => w_lights_R
--          o_state => w_state--,
--          o_lights_L(2) => w_lights(2),
--          o_lights_L(1) => w_lights(1),
--          o_lights_L(0) => w_lights(0),
--          o_lights_R(2) => w_lights(5),
--          o_lights_R(1) => w_lights(4),
--          o_lights_R(0) => w_lights(3)
        );
	-----------------------------------------------------
	
	-- PROCESSES ----------------------------------------	
    -- Clock process ------------------------------------
    clk_proc : process
	begin
		w_clk <= '0';
        wait for k_clk_period/2;
		w_clk <= '1';
		wait for k_clk_period/2;
	end process;
	-----------------------------------------------------
	
	-- Test Plan Process --------------------------------
	sim_proc: process
	begin
		-- sequential timing	
		
		--test reset	
		w_reset <= '1';
		wait for k_clk_period*1;
		  assert ((w_lights_L = "000") and (w_lights_R = "000")) report "bad reset" severity failure;
		  
		w_reset <= '0';
		wait for k_clk_period*1;
		
		-- test normal left turn
		w_left <= '1'; wait for k_clk_period;
          assert ((w_lights_L = "001") and (w_lights_R = "000")) report "should be L1" severity failure;
          wait for k_clk_period;
          assert ((w_lights_L = "011") and (w_lights_R = "000")) report "should be L2" severity failure;
          wait for k_clk_period;
          assert ((w_lights_L = "111") and (w_lights_R = "000")) report "should be L3" severity failure;
          wait for k_clk_period;
          assert ((w_lights_L = "000") and (w_lights_R = "000")) report "should be OFF" severity failure;
          w_left <= '0';
          wait for k_clk_period;
          
          -- test normal right turn
		w_right <= '1'; wait for k_clk_period;
          assert ((w_lights_L = "000") and (w_lights_R = "001")) report "should be R1" severity failure;
          wait for k_clk_period;
          assert ((w_lights_L = "000") and (w_lights_R = "011")) report "should be R2" severity failure;
          wait for k_clk_period;
          assert ((w_lights_L = "000") and (w_lights_R = "111")) report "should be R3" severity failure;
          wait for k_clk_period;
          assert ((w_lights_L = "000") and (w_lights_R = "000")) report "should be OFF" severity failure;
          w_right <= '0';
          
          --test normal hazard lights
        w_right <= '1'; w_left <= '1'; wait for k_clk_period;
          assert ((w_lights_L = "111") and (w_lights_R = "111")) report "should be ON" severity failure;
          wait for k_clk_period;
          assert ((w_lights_L = "000") and (w_lights_R = "000")) report "should be OFF" severity failure;
          wait for k_clk_period;
          assert ((w_lights_L = "111") and (w_lights_R = "111")) report "should be ON" severity failure;
          wait for k_clk_period;
          assert ((w_lights_L = "000") and (w_lights_R = "000")) report "should be OFF" severity failure;
          w_right <= '0'; w_left <= '0';
          
          -- test normal left turn, but reset in the middle
		w_left <= '1'; wait for k_clk_period;
          assert ((w_lights_L = "001") and (w_lights_R = "000")) report "should be L1" severity failure;
          wait for k_clk_period;
          assert ((w_lights_L = "011") and (w_lights_R = "000")) report "should be L2" severity failure;
          w_reset <= '1';
          wait for k_clk_period*1;
		  assert ((w_lights_L = "000") and (w_lights_R = "000")) report "bad reset" severity failure;
		  w_reset <= '0';
          w_left <= '0';
          wait for k_clk_period;
          
          --test right input during left turn pattern, followed by turning left input off while keeping right on.
        w_left <= '1'; wait for k_clk_period;
          assert ((w_lights_L = "001") and (w_lights_R = "000")) report "should be L1" severity failure;
          w_right <= '1';
          wait for k_clk_period;
          assert ((w_lights_L = "011") and (w_lights_R = "000")) report "should be L2" severity failure;
          w_left <= '0';
          wait for k_clk_period;
          assert ((w_lights_L = "111") and (w_lights_R = "000")) report "should be L3" severity failure;
          wait for k_clk_period;
          assert ((w_lights_L = "000") and (w_lights_R = "000")) report "should be OFF" severity failure;
          --now it should go into a right turn pattern.
          wait for k_clk_period;
          assert ((w_lights_L = "000") and (w_lights_R = "001")) report "should be R1" severity failure;
          wait for k_clk_period;
          w_left <= '1'; --turn left on. Should finish right pattern, and then go into hazard lights
          assert ((w_lights_L = "000") and (w_lights_R = "011")) report "should be R2" severity failure;
          wait for k_clk_period;
          assert ((w_lights_L = "000") and (w_lights_R = "111")) report "should be R3" severity failure;
          wait for k_clk_period;
          assert ((w_lights_L = "000") and (w_lights_R = "000")) report "should be OFF" severity failure;
          
          --should now go into hazard mode
          wait for k_clk_period;
          assert ((w_lights_L = "111") and (w_lights_R = "111")) report "should be ON" severity failure;
          wait for k_clk_period;
          assert ((w_lights_L = "000") and (w_lights_R = "000")) report "should be OFF" severity failure;
          wait for k_clk_period;
          assert ((w_lights_L = "111") and (w_lights_R = "111")) report "should be ON" severity failure;
          wait for k_clk_period;
          assert ((w_lights_L = "000") and (w_lights_R = "000")) report "should be OFF" severity failure;
          w_right <= '0'; w_left <= '0';

		wait;
	end process;
	-----------------------------------------------------	
	
end test_bench;
