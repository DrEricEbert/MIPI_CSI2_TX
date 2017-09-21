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
	 data_out_valid : out std_logic --goes high when csi_data_out is valid	 
	 );
end send_video_line;

architecture Behavioral of send_video_line is


type state_type is (idle,get_first_byte,get_second_byte,get_third_byte,get_forth_byte,transmission_loop,prepare_checksum);
signal state_reg, state_next : state_type := idle;
signal data_out_valid_reg,data_out_valid_next : STD_LOGIC := '0';
signal data_in_reg,data_in_next : std_logic_vector(8 downto 0) := (others  => '0');
signal first_byte,second_byte,third_byte,forth_byte : std_logic_vector(8 downto 0) := (others  => '0');

begin

--FSMD state & data registers
FSMD_state : process(clk,rst)
begin
		if (rst = '1') then 
		    state_reg <= idle;
			data_out_valid_reg <= '0';
			data_in_reg <= (others => '0');
			
		elsif (clk'event and clk = '1') then 		
			data_out_valid_reg <= data_out_valid_next;
			data_in_reg <= data_in_next;
			
		end if;
						
end process; --FSMD_state


data_out_valid <= data_out_valid_reg;

--line output state machine
LINE_OUT_FSMD : process(state_reg,data_in_reg,start_transmission)
begin

    state_next   <= state_reg;
	data_in_next <= data_in_reg;
    
    --idle,get_first_byte,get_second_byte,get_third_byte,get_forth_byte,transmission_loop,prepare_checksum);
    case state_reg is 
	
            when idle =>
			    if (start_transmission = '1') then
				
				end if;
               
            when get_first_byte =>
                
            when get_second_byte =>  

            when get_third_byte =>     
                
            when get_forth_byte =>   
                
            when transmission_loop =>                 
			
			when prepare_checksum =>          
               
    end case; --state_reg

end process; --LINE_OUT_FSMD



end Behavioral;
