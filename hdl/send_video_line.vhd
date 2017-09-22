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

use work.Common.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

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
	 data_type : in packet_type_t; --data type - YUV,RGB,RAW etc
	 video_data_in : in std_logic_vector(7 downto 0); --one byte of video payload
	 start_transmission : in std_logic; --trigger to start transmission,one clock cycle enough- word_cound,vc_num,video_data_in should be valid.
	 csi_data_out : out  std_logic_vector(7 downto 0); --one byte of CSI stream that goes to serializer
	 transmission_finished : out std_logic; --rised once the header, payload and footer data is sent.
	 data_out_valid : out std_logic --goes high when csi_data_out is valid	 
	 );
end send_video_line;

architecture Behavioral of send_video_line is


type state_type is (idle,get_first_byte,get_second_byte,get_third_byte,transmission_loop,second_byte_of_crc);
signal state_reg, state_next : state_type := idle;
signal data_out_valid_reg,data_out_valid_next : STD_LOGIC := '0';
signal data_in_reg,data_in_next : std_logic_vector(7 downto 0) := (others  => '0');
signal data_out_reg,data_out_next : std_logic_vector(7 downto 0) := (others  => '0');
signal long_packet_header : std_logic_vector(31 downto 0) := (others  => '0'); --long packet header
signal word_count_reg,word_count_next : std_logic_vector(15 downto 0); --data counters
signal crc_reg,crc_next:  std_logic_vector(0 to 15) := x"FFFF";

begin

--FSMD state & data registers
FSMD_state : process(clk,rst)
begin
		if (rst = '1') then 
		    state_reg <= idle;
		    data_out_valid_reg <= '0';
		    data_in_reg <= (others => '0');
		    data_out_reg <= (others => '0');
		    word_count_reg <= (others => '0');
		    crc_reg  <= x"FFFF";
		    
		elsif (clk'event and clk = '1') then 		
		    data_out_valid_reg <= data_out_valid_next;
		    data_in_reg <= data_in_next;
		    state_reg <= state_next;  		
		    data_out_reg <= data_out_next;
		    word_count_reg <= word_count_next;
		    crc_reg <= crc_next;
			
		end if;
						
end process; --FSMD_state


data_out_valid <= data_out_valid_reg;
csi_data_out       <= data_out_reg;
long_packet_header <= get_short_packet(vc_num,data_type,word_cound);

--line output state machine
LINE_OUT_FSMD : process(state_reg,data_in_reg,data_out_valid_reg,start_transmission,video_data_in,
								data_out_reg,long_packet_header,word_count_reg,crc_reg,word_cound)
begin

	state_next   <= state_reg;
	data_in_next <= data_in_reg;
	data_out_valid_next <= data_out_valid_reg;
	data_out_next <= 	data_out_reg;
	word_count_next <=  word_count_reg;
	crc_next <= crc_reg;
			    
    --idle,get_first_byte,get_second_byte,get_third_byte,get_forth_byte,transmission_loop,prepare_checksum);
    case state_reg is 
	
		when idle =>
		   data_out_valid_next <= '0'; --no valid by default
		   word_count_next <= (others => '0');
		   crc_next  <= x"FFFF";
		   
			if (start_transmission = '1') then
			
				data_out_valid_next <= '1';
				data_out_next <= long_packet_header(7 downto 0); --first byte of packet header
				state_next <= get_first_byte;
			end if;
               
		when get_first_byte =>

			data_out_next <= long_packet_header(15 downto 8);			
			state_next <= get_second_byte;
                
		when get_second_byte =>

			data_out_next <= long_packet_header(23 downto 16);			
			state_next <= get_third_byte;		

		when get_third_byte =>
		
			data_out_next <= long_packet_header(31 downto 24);			
			data_in_next <= video_data_in;
			crc_next <= nextCRC16_D8(video_data_in,crc_reg);
			word_count_next <= x"0001"; --reduces 100 MHz speed on Artix 7
			state_next <= transmission_loop;		     
                
		when transmission_loop =>
		   data_in_next <= video_data_in;
			data_out_next <= data_in_reg;
			crc_next <= nextCRC16_D8(video_data_in,crc_reg);
			word_count_next <= std_logic_vector( unsigned(word_count_reg) + 1 ); --reduces 100 MHz speed on Artix 7
			
			if (word_count_reg = word_cound) then --finish of transmission
			   data_out_next <= crc_reg(8 to 15);  --send out first byte of CRC
				state_next <= second_byte_of_crc;   
			end if;					
			
		when second_byte_of_crc =>	
			   data_out_next <= crc_reg(0 to 7);  --send out second byte of CRC
				state_next <= idle;   
		
               
    end case; --state_reg

end process; --LINE_OUT_FSMD



end Behavioral;
