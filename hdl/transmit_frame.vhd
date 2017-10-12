library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.Common.all;

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
     lp_data_out : out std_logic_vector(1 downto 0); --bit 1 = Dp line, bit 0 = Dn line
     ready_to_send_data : out std_logic; --goes high once ready to accept the HS data (goes 1, N clock cicles before the actual
                                         --reading, to give a time for producer to prepare)
     hs_data_valid : out std_logic; --1 when hs_data_out is valid
     lp_data_valid : out std_logic; --1 when lp_data_out is valid
     is_hs_mode :  out std_logic --0 when  in LP mode, 1 when in HS mode     
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
     ready_to_transmit : out STD_LOGIC; --goes high once ready for transmission of HS data
     hs_mode_flag : out STD_LOGIC; --signaling to enter/exit the HS mode. 1- enter, 0- exit. Good for flag of turning on the clock or
                                   -- as a trigger for muxer/switcher. This one goes high configurable number of clock cycles before
                                   -- ready_to_transmit goes high.
     lp_out : out STD_LOGIC_VECTOR(1 downto 0) --bit 1 = Dp line, bit 0 = Dn line
     --err_occured : out STD_LOGIC  --active highl 0 = no error, 1 - error acured
     );
END COMPONENT;

--end of components

type state_type is (idle,lp_mode_frame_start,hs_mode_frame_start);
signal state_reg, state_next : state_type := idle;

type frame_header_byte_type is (none,first_byte,second_byte,third_byte,forth_byte);
signal frame_header_byte_reg, frame_header_byte_next : frame_header_byte_type := none;

signal frame_start_packet_header : std_logic_vector(31 downto 0) := (others  => '0'); 
signal frame_number : std_logic_vector(15 downto 0) := "1100110100111011"; --TODO:MAKE INPUT

--related to inst_one_lane_D_PHY
signal start_dphy_transmission_reg,start_dphy_transmission_next : std_logic := '0';
signal stop_dphy_transmission_reg,stop_dphy_transmission_next : std_logic :='0';
signal dphy_ready_to_transmit_reg,dphy_ready_to_transmit_next : std_logic :='0';
signal dphy_hs_mode_flag_reg,dphy_hs_mode_flag_next : std_logic :='0';
signal dphy_lp_out_reg,dphy_lp_out_next :  std_logic_vector(1 downto 0) := "11"; -- =LP_11

--related to send_video_line
signal data_in_vline_reg,data_in_vline_next : std_logic_vector(7 downto 0) := (others => '0'); --one byte of video payload
signal vline_start_transmission_reg,vline_start_transmission_next : std_logic :='0';
signal vline_csi_out_reg,vline_csi_out_next : std_logic_vector(7 downto 0) := (others => '0'); --one byte of CSI stream that goes to serializer
signal vline_transmission_finished_reg,vline_transmission_finished_next :  std_logic :='0';
signal vline_data_out_valid_reg,vline_data_out_valid_next :  std_logic :='0';

begin
--instantinate components
inst_one_lane_D_PHY : one_lane_D_PHY PORT MAP(
     clk => clk_lp,
     rst => rst,
     start_transmission => start_dphy_transmission_reg,
     stop_transmission => stop_dphy_transmission_reg,
     ready_to_transmit => dphy_ready_to_transmit_reg,
     hs_mode_flag  => dphy_hs_mode_flag_reg,
     lp_out => dphy_lp_out_reg
     );
     
inst_send_video_line: send_video_line PORT MAP(
    clk => clk,
    rst => rst,
	 word_cound => bytes_per_line,
	 vc_num => vc_num,
	 data_type => data_type,
	 video_data_in => data_in_vline_reg,
	 start_transmission => vline_start_transmission_reg,
	 csi_data_out => vline_csi_out_reg,
	 transmission_finished => vline_transmission_finished_reg,
	 data_out_valid => vline_data_out_valid_reg);     

--FSMD state & data registers
FSMD_state : process(clk,rst)
begin
		if (rst = '1') then 
			state_reg <= idle;
			start_dphy_transmission_reg <= '0';
		   frame_header_byte_reg <= none;
		elsif (clk'event and clk = '1') then 		
			state_reg <= state_next;  				
			start_dphy_transmission_reg <= start_dphy_transmission_next;
			frame_header_byte_reg <= frame_header_byte_next;
		end if;
						
end process; --FSMD_state


frame_start_packet_header <= get_short_packet(vc_num,Frame_Start,frame_number);
lp_data_out <= dphy_lp_out_reg;
ready_to_send_data <= dphy_hs_mode_flag_reg;

FRAME_FSMD : process(state_reg,start_frame_transmission,stop_frame_transmission,start_dphy_transmission_reg,
                     dphy_ready_to_transmit_reg,dphy_hs_mode_flag_reg,frame_header_byte_reg)
begin

	state_next <= state_reg;
	start_dphy_transmission_next <=  start_dphy_transmission_reg;
	lp_data_valid <= '0';                          
	hs_data_valid <= '0';
	is_hs_mode <= '0'; --0 when  in LP mode, 1 when in HS mode  
	hs_data_out <= (others => '0');   
   frame_header_byte_next <= none;
   
    case state_reg is 
            when idle =>                 
            	if (start_frame_transmission = '1') then
            	   start_dphy_transmission_next <= '1';
            	   state_next <= lp_mode_frame_start;
            	end if;
                 
            when lp_mode_frame_start =>

              	lp_data_valid <= '1';   
            
               if (dphy_hs_mode_flag_reg = '1') then
            	  lp_data_valid <= '0';
   	           is_hs_mode <= '1';	    
   	           hs_data_valid <= '0';        
            	  state_next <= hs_mode_frame_start;
            	end if;
            	          	                           
            when hs_mode_frame_start =>  
  
               is_hs_mode <= '1'; --signaling to start HS clock for caller
            
					if (dphy_ready_to_transmit_reg = '1') then --HS transmission starts;
						is_hs_mode <= '1';	    
						hs_data_valid <= '1';        
						hs_data_out <=  Sync_Sequence;--output sync sequence '00011101'
						frame_header_byte_next <= first_byte; --none,first_byte,second_byte,third_byte,forth_byte						
						--state_next <= hs_mode_frame_start;
            	end if;
            	
            	if (frame_header_byte_reg = first_byte) then
						lp_data_valid <= '0';
						is_hs_mode <= '1';	    
						hs_data_valid <= '1';        
						hs_data_out <=  frame_start_packet_header(7 downto 0); --first byte of packet header;
						frame_header_byte_next <= second_byte; --none,first_byte,second_byte,third_byte,forth_byte
            	end if;
            	
            	if (frame_header_byte_reg = second_byte) then
						lp_data_valid <= '0';
						is_hs_mode <= '1';	    
						hs_data_valid <= '1';        
						hs_data_out <=  frame_start_packet_header(15 downto 8); --second byte of packet header;
						frame_header_byte_next <= third_byte; --none,first_byte,second_byte,third_byte,forth_byte
            	end if;
            	
               if (frame_header_byte_reg = third_byte) then
						lp_data_valid <= '0';
						is_hs_mode <= '1';	    
						hs_data_valid <= '1';        
						hs_data_out <=  frame_start_packet_header(23 downto 16); --third byte of packet header;
						frame_header_byte_next <= forth_byte; --none,first_byte,second_byte,third_byte,forth_byte
            	end if;
            	
               if (frame_header_byte_reg = forth_byte) then
						lp_data_valid <= '0';
						is_hs_mode <= '1';	    
						hs_data_valid <= '1';        
						hs_data_out <=  frame_start_packet_header(31 downto 24); --forth byte of packet header;
						--TODO: consider to add additional state for gratefull HS mode termination on
						-- entering into idle or LP mode before line starts
						frame_header_byte_next <= none; --none,first_byte,second_byte,third_byte,forth_byte
						state_next <= idle;
            	end if;
                 
            
    end case; --state_reg

end process; --FRAME_FSMD

end Behavioral;
