library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.Common.all;

-- hs_out_next <= "00011101";  --output sync sequence '00011101'

entity transmit_frame is
Port(clk : in std_logic; --data in/out clock HS clock, ~100 MHZ
     clk_lp : in std_logic; --LP clock, ~100 MHZ. not necessarily the same as clk HS
     rst : in  std_logic;
     bytes_per_line : in std_logic_vector(15 downto 0); --bytes per video line (take into account virtual channels data reduction)
     lines_per_frame : in std_logic_vector(15 downto 0); --lines per video frame (take into account virtual channels data reduction? should I?)
     vc_num : in std_logic_vector(1 downto 0); --virtual channel number  
 	  data_type : in packet_type_t; --data type - YUV,RGB,RAW etc    
 	  frame_data_in : in std_logic_vector(7 downto 0); --one byte of video payload   
     start_frame_transmission : in std_logic; --triggers LP dance
     stop_frame_transmission :  in std_logic; --aborts the frame transmission (not sure that this one is neccesary)

     hs_data_out : out  std_logic_vector(7 downto 0); --one byte of CSI stream that goes to serializer
     lp_data_out : out std_logic_vector(1 downto 0) --bit 1 = Dp line, bit 0 = Dn line
     ready_to_send_data : out std_logic; --goes high once ready to accept the HS data (goes 1, X clock cicles before the actual
                                         --reading, to give a time for producer to prepare)
     hs_data_valid : out std_logic; --1 when hs_data_out is valid
     lp_data_valid : out std_logic; --1 when lp_data_out is valid
     is_hs_mode :  out std_logic; --0 when  in LP mode, 1 when in HS mode
     
	 );
end transmit_frame;

architecture Behavioral of transmit_frame is

-- components

COMPONENT send_video_line is
    Port (clk : in std_logic; --data in/out clock HS clock, ~100 MHZ
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
END COMPONENT;

COMPONENT one_lane_D_PHY is generic (	
	DATA_WIDTH_IN : integer := 8;
	DATA_WIDTH_OUT : integer := 8
	);
     Port(clk : in STD_LOGIC; --LP data in/out clock     
     rst : in  STD_LOGIC;
     start_transmission : in STD_LOGIC; --start of transmit trigger - performs the required LP dance
     stop_transmission  : in STD_LOGIC; --end of transmit trigger, enters into LP CTRL_Stop mode
     ready_to_transmit : out STD_LOGIC; --goes high once ready for transmission
     hs_mode_flag : out STD_LOGIC; --signaling to enter/exit the HS mode. 1- enter, 0- exit. Good for flag of turning on the clock or
                                   -- as a trigger for muxer/switcher. This one goes high configurable number of clock cycles before
                                   -- ready_to_transmit goes high.
     lp_out : out STD_LOGIC_VECTOR(1 downto 0) --bit 1 = Dp line, bit 0 = Dn line
     --err_occured : out STD_LOGIC  --active highl 0 = no error, 1 - error acured
     );
END COMPONENT;

--end of components

type state_type is (idle,get_first_byte,get_second_byte,get_third_byte,transmission_loop,first_byte_of_crc,second_byte_of_crc);
signal state_reg, state_next : state_type := idle;

begin

--FSMD state & data registers
FSMD_state : process(clk,rst)
begin
		if (rst = '1') then 
			state_reg <= idle;
		elsif (clk'event and clk = '1') then 		
			state_reg <= state_next;  				
		end if;
						
end process; --FSMD_state


end Behavioral;
