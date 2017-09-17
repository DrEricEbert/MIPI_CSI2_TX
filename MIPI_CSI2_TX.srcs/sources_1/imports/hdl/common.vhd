----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/02/2017 10:16:15 PM
-- Design Name: 
-- Module Name: common - Behavioral
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

package Common is   

   type my_enum_type is (r1, r2, r3);
   type shortp_type is (frame_start,frame_end,line_start,line_end); --short packet type

     -- polynomial: x^16 + x^12 + x^5 + 1
 -- data width: 8
 -- convention: the first serial bit is D[7]
 function nextCRC16_D8
   (Data: std_logic_vector(0 to 7);
    crc:  std_logic_vector(0 to 15))
   return std_logic_vector;
   
 function get_ecc
   (data : in std_logic_vector (23 downto 0))
   return std_logic_vector;
  
end Common;

package body Common is
   
   
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

function get_ecc
    (data : in std_logic_vector (23 downto 0))
    return std_logic_vector is

variable ecc_out: std_logic_vector(7 downto 0);

begin
    ecc_out(7) := '0';
    ecc_out(6) := '0';
    ecc_out(5) := data(10) xor data(11) xor data(12) xor data(13) xor data(14) xor data(15) xor data(16) xor data(17) xor data(18) xor data(19) xor data(21) xor data(22) xor data(23);
    ecc_out(4) := data(4) xor data(5) xor data(6) xor data(7) xor data(8) xor data(9) xor data(16) xor data(17) xor data(18) xor data(19) xor data(20) xor data(22) xor data(23);
    ecc_out(3) := data(1) xor data(2) xor data(3) xor data(7) xor data(8) xor data(9) xor data(13) xor data(14) xor data(15) xor data(19) xor data(20) xor data(21) xor data(23);
    ecc_out(2) := data(0) xor data(2) xor data(3) xor data(5) xor data(6) xor data(9) xor data(11) xor data(12) xor data(15) xor data(18) xor data(20) xor data(21) xor data(22);
    ecc_out(1) := data(0) xor data(1) xor data(3) xor data(4) xor data(6) xor data(8) xor data(10) xor data(12) xor data(14) xor data(17) xor data(20) xor data(21) xor data(22) xor data(23);
    ecc_out(0) := data(0) xor data(1) xor data(2) xor data(4) xor data(5) xor data(7) xor data(10) xor data(11) xor data(13) xor data(16) xor data(20) xor data(21) xor data(22) xor data(23);
	
	return ecc_out;
end get_ecc;
   
end Common;
