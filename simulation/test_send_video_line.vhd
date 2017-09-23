
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.Common.all;

entity test_send_video_line is
--  Port ( );
end test_send_video_line;

architecture Behavioral of test_send_video_line is

-- Component Declaration for the Unit Under Test (UUT)

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

COMPONENT csi_rx_packet_handler is
    Port ( clock : in STD_LOGIC; --word clock in
           reset : in STD_LOGIC; --asynchronous active high reset
           enable : in STD_LOGIC; --active high enable
           data : in STD_LOGIC_VECTOR (31 downto 0); --data in from word aligner
           data_valid : in STD_LOGIC; --data valid in from word aligner
           sync_wait : out STD_LOGIC; --drives byte and word aligner wait_for_sync
           packet_done : out STD_LOGIC; --drives word aligner packet_done
           payload_out : out STD_LOGIC_VECTOR(31 downto 0); --payload out from long video packets
           payload_valid : out STD_LOGIC; --whether or not payload output is valid (i.e. currently receiving a long packet)
           vsync_out : out STD_LOGIC; --vsync output to timing controller
           in_frame : out STD_LOGIC; --whether or not currently in video frame (i.e. got FS but not FE)
		   in_line : out STD_LOGIC); --whether or not receiving video line
END COMPONENT;

--send_video_line
--Inputs
signal clk : std_logic; --word clock in
signal rst : std_logic; --asynchronous active high reset
signal word_cound : in std_logic_vector(15 downto 0); --length of the valid payload, bytes
signal vc_num : in std_logic_vector(1 downto 0); --virtual channel number  
signal data_type : in packet_type_t; --data type - YUV,RGB,RAW etc
signal video_data_in : in std_logic_vector(7 downto 0); --one byte of video payload
signal start_transmission : in std_logic; --trigger to start transmission,one clock cycle enough- word_cound,vc_num,video_data_in 
                                          --should be valid.
--Outputs
signal csi_data_out :   std_logic_vector(7 downto 0); --one byte of CSI stream that goes to serializer
signal transmission_finished :  std_logic; --rised once the header, payload and footer data is sent.
signal data_out_valid :  std_logic --goes high when csi_data_out is valid	 

--csi_rx_packet_handler
--Inputs
signal enable :  std_logic := '0';  --active high enable
signal data :  std_logic_vector (31 downto 0); --data in from word aligner
signal data_valid : std_logic := '0'; --data valid in from word aligner
--Outputs
signal sync_wait :  std_logic; --drives byte and word aligner wait_for_sync
signal packet_done :  std_logic; --drives word aligner packet_done
signal payload_out :  std_logic_vector(31 downto 0); --payload out from long video packets
signal payload_valid :  std_logic; --whether or not payload output is valid (i.e. currently receiving a long packet)
signal vsync_out :  std_logic; --vsync output to timing controller
signal in_frame :  std_logic; --whether or not currently in video frame (i.e. got FS but not FE)
signal in_line :  std_logic; --whether or not receiving video line

constant clk_period : time := 10 ns; --LP = 100 Mhz

type arr_of_crc is array (0 to 23) of std_logic_vector(0 to 7);
signal crc_arr1 : arr_of_crc := (x"FF",x"00",x"00",x"02",x"B9",x"DC",x"F3",x"72",
                                 x"BB",x"D4",x"B8",x"5A",x"C8",x"75",x"C2",x"7C",
                                 x"81",x"F8",x"05",x"DF",x"FF",x"00",x"00",x"01");

begin

-- Instantiate the Unit Under Test (UUT)
uut: send_video_line PORT MAP(clk => clk,
	 word_cound => word_cound,
	 vc_num => vc_num,
	 data_type => data_type,
	 video_data_in => video_data_in,
	 start_transmission => start_transmission,
	 csi_data_out => csi_data_out,
	 transmission_finished => transmission_finished,
	 data_out_valid => data_out_valid);


inst_packet_handler: csi_rx_packet_handler PORT MAP(
           clock => clk,
           reset => rst,
           enable =>  enable,
           data => data,
           data_valid => data_valid,
           sync_wait => sync_wait,
           packet_done => packet_done,
           payload_out => payload_out,
           payload_valid => payload_valid,
           vsync_out => vsync_out,
           in_frame => in_frame,
		   in_line =>  in_line);

-- Clock process definitions
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
   
   wait for clk_period*5;
   
   --assign data for test - frame_start
   data <= get_short_packet("00",frame_start,x"0000");
   
    wait for clk_period*5;
   
   --enable 
   enable <= '1';
   
   wait for clk_period*5;
   
   --data valid
   
   data_valid <= '1';
   
   wait for clk_period*20;
   
   --assign data for test - line_start
   data <= get_short_packet("00",line_start,x"FFFF");
   
   wait for clk_period*5;
   
   
end process;


end Behavioral;
