--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:30:31 11/11/2016
-- Design Name:   
-- Module Name:   D:/Documentos/Xilinx/Genius Game/Genius/Genius_TB.vhd
-- Project Name:  Genius
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Genius
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY Genius_TB IS
END Genius_TB;
 
ARCHITECTURE behavior OF Genius_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Genius
    PORT(
         clk : IN  std_logic;
         start : IN  std_logic;
         reset : IN  std_logic;
         diff : IN  std_logic_vector(1 downto 0);
         switches : IN  std_logic_vector(3 downto 0);
         leds : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal start : std_logic := '0';
   signal reset : std_logic := '0';
   signal diff : std_logic_vector(1 downto 0) := (others => '0');
   signal switches : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal leds : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Genius PORT MAP (
          clk => clk,
          start => start,
          reset => reset,
          diff => diff,
          switches => switches,
          leds => leds
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		switches<="0000";
		diff<="10";
		start<='0';
		reset<='1';
      wait for 100 ns;	
		reset<='0';
		start<='1';
		wait for 500 ms;
		switches<="1000";
		wait for 500 ms;
		switches<="0000";
		wait for 1200 ms;
		switches<="1000";
		wait for 500 ms;
		switches<="0000";
		wait for 500 ms;
		switches<="0100";
		wait for 500 ms;
		switches<="0000";
		wait for 1700 ms;
		switches<="1000";
		wait for 500 ms;
		switches<="0000";
		wait for 500 ms;
		switches<="0100";
		wait for 500 ms;
		switches<="0000";
		wait for 500 ms;
		switches<="0001";
		wait for 500 ms;
		switches<="0000";


      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
