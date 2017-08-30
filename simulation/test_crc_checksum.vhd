----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/21/2017 09:41:30 PM
-- Design Name: 
-- Module Name: test_crc_checksum - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_crc_checksum is
--  Port ( );
end test_crc_checksum;

architecture Behavioral of test_crc_checksum is

-- Component Declaration for the Unit Under Test (UUT)
  -- polynomial: x^16 + x^12 + x^5 + 1
-- data width: 8
-- convention: the first serial bit is D[7]
function nextCRC16_D8
  (Data: std_logic_vector(0 to 7);
   crc:  std_logic_vector(0 to 15))
  return std_logic_vector;
  
  function nextCRC16_D8
  (Data: std_logic_vector(0 to 7);
   crc:  std_logic_vector(0 to 15))
  return std_logic_vector is

  variable d:      std_logic_vector(0 to 7);
  variable c:      std_logic_vector(0 to 15);
  variable newcrc: std_logic_vector(0 to 15);

begin
  d := Data;
  c := crc;

  newcrc(0) := d(4) xor d(0) xor c(8) xor c(12);
  newcrc(1) := d(5) xor d(1) xor c(9) xor c(13);
  newcrc(2) := d(6) xor d(2) xor c(10) xor c(14);
  newcrc(3) := d(7) xor d(3) xor c(11) xor c(15);
  newcrc(4) := d(4) xor c(12);
  newcrc(5) := d(5) xor d(4) xor d(0) xor c(8) xor c(12) xor c(13);
  newcrc(6) := d(6) xor d(5) xor d(1) xor c(9) xor c(13) xor c(14);
  newcrc(7) := d(7) xor d(6) xor d(2) xor c(10) xor c(14) xor c(15);
  newcrc(8) := d(7) xor d(3) xor c(0) xor c(11) xor c(15);
  newcrc(9) := d(4) xor c(1) xor c(12);
  newcrc(10) := d(5) xor c(2) xor c(13);
  newcrc(11) := d(6) xor c(3) xor c(14);
  newcrc(12) := d(7) xor d(4) xor d(0) xor c(4) xor c(8) xor c(12) xor c(15);
  newcrc(13) := d(5) xor d(1) xor c(5) xor c(9) xor c(13);
  newcrc(14) := d(6) xor d(2) xor c(6) xor c(10) xor c(14);
  newcrc(15) := d(7) xor d(3) xor c(7) xor c(11) xor c(15);
  return newcrc;
end nextCRC16_D8;

constant CRC0 : std_logic_vector(0 to 15) := (others => '1'); --Control mode: Stop

signal clk : std_logic;
signal rst : std_logic;
signal data_in : std_logic_vector(0 to 7);
signal crc_in  : std_logic_vector(0 to 15) := CRC0;
signal crc_out : std_logic_vector(0 to 15);
signal counter : integer := 0;

constant clk_period : time := 10 ns; --LP = 100 Mhz

type arr_of_crc is array (0 to 23) of std_logic_vector(0 to 7);
signal crc_arr1 : arr_of_crc := (x"FF",x"00",x"00",x"02",x"B9",x"DC",x"F3",x"72",
                                 x"BB",x"D4",x"B8",x"5A",x"C8",x"75",x"C2",x"7C",
                                 x"81",x"F8",x"05",x"DF",x"FF",x"00",x"00",x"01");


begin

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
  
   wait for clk_period*2;
   
   --crc_in <=  nextCRC16_D8(data_in,CRC0);
   --crc_out <= crc_in;
     data_in <= crc_arr1(counter);
     crc_in <=  nextCRC16_D8(crc_arr1(counter),crc_in);    
     counter <= counter +1;
 
end process;


end Behavioral;
