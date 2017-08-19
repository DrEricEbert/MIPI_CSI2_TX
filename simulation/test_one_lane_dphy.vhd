----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/19/2017 09:13:30 PM
-- Design Name: 
-- Module Name: test_one_lane_dphy - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_one_lane_dphy is
    Generic (	
	DATA_WIDTH_IN : integer := 8;
    DATA_WIDTH_OUT : integer := 8
    );
--  Port ( );
end test_one_lane_dphy;

architecture Behavioral of test_one_lane_dphy is

-- Component Declaration for the Unit Under Test (UUT)

COMPONENT one_lane_D_PHY is generic (	
	DATA_WIDTH_IN : integer := 8;
	DATA_WIDTH_OUT : integer := 8
	);
     Port(clk : in STD_LOGIC; --LP data in/out clock     
     rst : in  STD_LOGIC;
     start_transmission : in STD_LOGIC;
     stop_transmission  : in STD_LOGIC;
     data_in :  in STD_LOGIC_VECTOR (DATA_WIDTH_IN - 1 downto 0);
     
     ready_to_transmit : out STD_LOGIC; --goes high once ready for transmission
     hs_mode_flag : out STD_LOGIC; --goes high when entering HS mode
     output_valid : out STD_LOGIC;-- indicates that the output is valid
     hs_out : out STD_LOGIC_VECTOR (DATA_WIDTH_OUT - 1 downto 0);
     lp_out : out STD_LOGIC_VECTOR(1 downto 0) --bit 1 = Dp line, bit 0 = Dn line
     --err_occured : out STD_LOGIC  --active highl 0 = no error, 1 - error acured
     );
END COMPONENT;

--Inputs
signal clk : std_logic;
signal rst : std_logic;
signal start_transmission :  STD_LOGIC := '0';
signal stop_transmission  :  STD_LOGIC := '0';
signal data_in :   STD_LOGIC_VECTOR (DATA_WIDTH_IN - 1 downto 0);
--Outputs
signal ready_to_transmit :  STD_LOGIC; --goes high once ready for transmission
signal hs_mode_flag :  STD_LOGIC; --goes high when entering HS mode
signal output_valid :  STD_LOGIC;-- indicates that the output is valid
signal hs_out :  STD_LOGIC_VECTOR (DATA_WIDTH_OUT - 1 downto 0);
signal lp_out :  STD_LOGIC_VECTOR(1 downto 0); --bit 1 = Dp line, bit 0 = Dn line


constant clk_period : time := 1 ns; --LP = 100 Mhz

begin

-- Instantiate the Unit Under Test (UUT)
uut: one_lane_D_PHY PORT MAP(
     clk => clk,
     rst => rst,
     start_transmission => start_transmission,
     stop_transmission => stop_transmission,
     data_in  => data_in,
     ready_to_transmit => ready_to_transmit,
     hs_mode_flag  => hs_mode_flag,
     output_valid  => output_valid,
     hs_out  => hs_out,
     lp_out => lp_out
     );
        
-- LP Clock process definitions
clk_process :process
begin
     clk <= '1';
     wait for clk_period/2;
     clk <= '0';
     wait for clk_period/2;
end process;   
        
        
-- Stimulus process
stim_proc: process
begin        
  
   wait for clk_period*5;
     
   --reset
   rst <= '1';
   wait for clk_period*5;    
   rst <= '0';
 
   --toggle start of transmission
   start_transmission <= '1';
   wait for clk_period;
   start_transmission <= '0';
   
   
   --wait until ready for transmission
   wait until ready_to_transmit = '1';
   wait for clk_period;
   
   --transmit first byte
   data_in <= "11111111";
   wait for clk_period;
   --transmit second byte
   data_in <= "01010101";
   wait for clk_period;
     
   wait for clk_period*10;
end process;


end Behavioral;
