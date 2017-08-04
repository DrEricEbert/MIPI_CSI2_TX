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
     output_valid : out STD_LOGIC;-- indicates that the output is valid
     dphy_clk_in : out STD_LOGIC; --must be  xDATA_WIDTH faster then data_clk
     dphy_clk_out : out STD_LOGIC;
     hs_out : out STD_LOGIC;
     lp_p_out : out STD_LOGIC;
     lp_n_out : out STD_LOGIC;
     data_in :  out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
     );
end one_lane_D_PHY;

architecture Behavioral of one_lane_D_PHY is

begin


end Behavioral;
