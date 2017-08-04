library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

--serializer for D_PHY protocol
entity one_lane_D_PHY is generic (	
	DATA_WIDTH_IN : integer := 8;
	DATA_WIDTH_OUT : integer := 8
	);
     Port(clk : in STD_LOGIC; --data in/out clock
     clk_100Mhz : in STD_LOGIC; --for delays calculations
     rst : in  STD_LOGIC;
     start_transmission : in STD_LOGIC;
     stop_transmission  : in STD_LOGIC;
     data_in :  in STD_LOGIC_VECTOR (DATA_WIDTH_IN - 1 downto 0);
     
     ready_to_transmit : out STD_LOGIC; --goes high once ready for transmission
     hs_mode_flag : out STD_LOGIC; --goes high when entering HS mode
     output_valid : out STD_LOGIC;-- indicates that the output is valid
     hs_out : out STD_LOGIC_VECTOR (DATA_WIDTH_OUT - 1 downto 0);
     lp_out : out STD_LOGIC_VECTOR(1 downto 0); --bit 1 = Dp line, bit 0 = Dn line
     err_occured : out STD_LOGIC  --active highl 0 = no error, 1 - error acured
     );
end one_lane_D_PHY;

architecture Behavioral of one_lane_D_PHY is

constant LP_00 : std_logic_vector(1 downto 0) := "00"; --Control mode: Bridge
constant LP_01 : std_logic_vector(1 downto 0) := "01"; --Control mode: HS-Rqst
constant LP_10 : std_logic_vector(1 downto 0) := "10"; --Control mode: LP-Rqst
constant LP_11 : std_logic_vector(1 downto 0) := "11"; --Control mode: Stop

type state_type is (CTRL_Stop,CTRL_Bridge,CTRL_HS_Rqst,CTRL_LP_Rqst,HS_Go,HS_Sync,HS_Burst);
signal state_reg, state_next : state_type := CTRL_Stop;
signal lp_reg,lp_next :  STD_LOGIC_VECTOR(1 downto 0) := LP_11;
signal hs_mode_flag_reg,hs_mode_flag_next : STD_LOGIC := '0'; --default LS mode
signal hs_out_reg,hs_out_next : STD_LOGIC_VECTOR (DATA_WIDTH_OUT - 1 downto 0) := (others => '0');
signal ready_to_transmit_reg,ready_to_transmit_next : STD_LOGIC := '0'; 

begin

lp_out <= lp_reg;
hs_mode_flag <= hs_mode_flag_reg; -- to serializer
output_valid <= hs_mode_flag_reg; --for serializer
hs_out <= hs_out_reg;
ready_to_transmit <= ready_to_transmit_reg;
--FSMD state & data registers
FSMD_state : process(clk,rst)
begin
		if (rst = '1') then 
			state_reg <= CTRL_Stop;
			lp_reg <= LP_11;
			hs_mode_flag_reg <= '0';
			hs_out_reg <=  (others => '0');
			ready_to_transmit_reg <= '0';
		elsif (clk'event and clk = '1') then 		
			state_reg <= state_next;
			lp_reg <= lp_next;
			hs_mode_flag_reg <= hs_mode_flag_next;
			hs_out_reg <= hs_out_next;
			ready_to_transmit_reg <= ready_to_transmit_next;
		end if;
						
end process; --FSMD_state


--video output state machine, section 5.4, page 35
D_PHY_FSMD : process(state_reg,lp_reg,hs_mode_flag_reg,hs_out_reg,data_in,
                     start_transmission,stop_transmission,ready_to_transmit_reg)
begin

    state_next <= state_reg;
    lp_next <= lp_reg ;
    hs_mode_flag_next <= hs_mode_flag_reg;
    hs_out_next <= hs_out_reg;
    ready_to_transmit_next <= ready_to_transmit_reg;
    
    case state_reg is 
            when CTRL_Stop =>
                 ready_to_transmit_next <= '0';
                 hs_mode_flag_next <= '0';                 
                 if (start_transmission = '1') then
                 state_next <= CTRL_HS_Rqst;
                 lp_next <= LP_01;                          
                 end if;
            when CTRL_HS_Rqst =>
                 --wait T_LPX = minimum 50 ns.
                 state_next <= CTRL_Bridge;   
                 lp_next <= LP_00;              
                 hs_mode_flag_next <= '0';
            when CTRL_Bridge =>  
                  --wait THS-PREPARE = min 40 ns + 4*UI,max 85 ns + 6*UI, UI (1 HS bit time) < 10 ns
                 hs_mode_flag_next <= '1';
                 hs_out_next <= (others => '0');
                 state_next <= HS_Go;
            when HS_Go =>     
                  --wait THS-ZERO ~80 ns => (THS-PREPARE + THS-ZERO = min 145 ns + 10*UI)
                  state_next <= HS_Sync;
            when HS_Sync =>
                  hs_out_next <= "00011101";  --output sync sequence '00011101'
                  ready_to_transmit_next <= '1';
                  state_next <= HS_Burst;
            when HS_Burst =>                
                 hs_out_next <= data_in;  --output payload data 
                 if ( stop_transmission <= '1') then
                    state_next <= CTRL_Stop;
                    ready_to_transmit_next <= '0';
                    hs_mode_flag_next <= '0';
                  end if;
            when CTRL_LP_Rqst =>                 
                 state_next <= CTRL_Stop;       
                 lp_next <= LP_11;             
                 hs_mode_flag_next <= '0';
    end case; --state_reg

end process; --D_PHY_FSMD


end Behavioral;
