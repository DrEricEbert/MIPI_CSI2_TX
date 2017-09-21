----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/21/2017 11:03:54 AM
-- Design Name: 
-- Module Name: send_video_line - Behavioral
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


--Sends entire video line to the serializer
-- *Assigns entire virtual channel to entire line
-- *Generates packet header
---*generates ECC for packet footer
---buffers first 4 bytes of data

entity send_video_line is
Port(clk : in std_logic; --data in/out clock HS clock, ~100 MHZ
     rst : in  std_logic;
	 word_cound : in std_logic_vector(15 downto 0); --length of the valid payload, bytes
	 vc_num : in std_logic_vector(1 downto 0); --virtual channel number     
	 video_data_in : in std_logic_vector(8 downto 0); --one byte of video payload
	 start_transmission : in std_logic; --trigger to start transmission - word_cound,vc_num,video_data_in should be valid.
	 csi_data_out : out  std_logic_vector(8 downto 0); --one byte of CSI stream that goes to serializer
	 transmission_finished : out std_logic; --rised once the header, payload and footer data is sent.
	 data_out_valid : out std_logic; --goes high when csi_data_out is valid
	 
	 );
end send_video_line;

architecture Behavioral of send_video_line is

begin


end Behavioral;
