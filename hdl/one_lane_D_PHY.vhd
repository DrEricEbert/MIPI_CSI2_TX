library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

--serializer for D_PHY protocol
entity one_lane_D_PHY is generic (	
	DATA_WIDTH : integer := 8
	);
     Port(data_clk : in STD_LOGIC;
     rst : in  STD_LOGIC;
     start_transmission : in STD_LOGIC;
     stop_transmission  : in STD_LOGIC;
     ready_to_transmit : out STD_LOGIC; --goes high once ready for transmission
     hs_mode_flag : out STD_LOGIC; --goes high when entering HS mode
     output_valid : out STD_LOGIC;-- indicates that the output is valid
     dphy_clk_in : out STD_LOGIC; --must be  x DATA_WIDTH faster then data_clk
     dphy_clk_out : out STD_LOGIC;
     hs_out : out STD_LOGIC;
     lp_out : out STD_LOGIC_VECTOR(1 downto 0); --bit 1 = Dp line, bit 0 = Dn line
     data_in :  out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
     err_occured : out STD_LOGIC  --active highl 0 = no error, 1 - error acured
     );
end one_lane_D_PHY;

architecture Behavioral of one_lane_D_PHY is

type state_type is (CTRL_Stop,CTRL_Bridge,CTRL_HS_Rqst,CTRL_LP_Rqst,HS_Burst);
signal state_reg, state_next : state_type := CTRL_Stop;
signal lp_reg,lp_next :  STD_LOGIC_VECTOR(1 downto 0) := "11";
signal hs_mode_flag_reg,hs_mode_flag_next : STD_LOGIC := '0'; --default LS mode
begin

lp_out <= lp_reg;
hs_mode_flag <= hs_mode_flag_reg;

--FSMD state & data registers
FSMD_state : process(data_clk,rst)
begin
		if (rst = '1') then 
			state_reg <= CTRL_Stop;
			lp_reg <= "11";
			hs_mode_flag_reg <= '0';
		elsif (data_clk'event and data_clk = '1') then 		
			state_reg <= state_next;
			lp_reg <= lp_next;
			hs_mode_flag_reg <= hs_mode_flag_next;
		end if;
						
end process; --FSMD_state


--video output state machine
D_PHY_FSMD : process(state_reg,lp_reg,hs_mode_flag_reg,
                     start_transmission,stop_transmission)
begin

    state_next <= state_reg;
    lp_next <= lp_reg ;
    hs_mode_flag_next <= hs_mode_flag_reg;

    case state_reg is 
            when CTRL_Stop =>
                 state_next <= CTRL_Bridge;
            when CTRL_Bridge =>  
                 state_next <= CTRL_HS_Rqst;
            when CTRL_HS_Rqst =>
                 state_next <= CTRL_LP_Rqst;            
            when CTRL_LP_Rqst =>                 
                 state_next <= HS_Burst;    
            when HS_Burst =>
                 state_next <= CTRL_Bridge;                 
    end case; --state_reg

end process; --D_PHY_FSMD


end Behavioral;
