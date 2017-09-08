----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/08/2017 09:57:14 AM
-- Design Name: 
-- Module Name: fmc_mipi_top - Behavioral
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

entity fmc_mipi_top is
   Port ( 
   sys_clk_p : in std_logic;
   sys_clk_n : in std_logic;
   rst : in std_logic;
      
   FMC_Switch1_SEL1 : out std_logic;
   FMC_Switch1_SEL2 : out std_logic;
   FMC_Switch2_SEL1 : out std_logic;
   FMC_Switch2_SEL2 : out std_logic;
   
   FMC_I2C_CAM_CLK : inout std_logic;
   FMC_I2C_CAM_DAT : inout std_logic;
   
   FMC_I2C_GP0_CLK_1V8 : inout std_logic;
   FMC_I2C_GP0_DAT_1V8 : inout std_logic;
     
   FMC_TR_1DIR : out std_logic;
   
   FMC_CAM_VSYNC  : in std_logic;
   FMC_CAM_FLASH_EN  : in std_logic;   

   FMC_CAM0_MCLK : in std_logic;
   FMC_CAM0_PWR  : in std_logic;
   FMC_CAM0_RST  : in std_logic;

   FMC_CAM2_MCLK  : in std_logic;
   FMC_CAM2_RST  : in std_logic;
   FMC_CAM2_PWRD  : in std_logic;
   
   --******MIPI CSI LVDS based implemntation*******
   --Low Power lines - LP
   LP_D3_P  : out std_logic := '0'; -- LA27_N
   LP_D3_N  : out std_logic := '0'; -- LA27_P 
   LP_D2_P  : out std_logic := '0'; -- FMC_LP_D2_P
   LP_D2_N  : out std_logic := '0'; -- FMC_LP_D2_N
   LP_D1_P  : out std_logic := '0'; -- LA23_P
   LP_D1_N  : out std_logic := '0'; -- LA23_N
   LP_D0_P  : out std_logic := '0'; -- LA14_P
   LP_D0_N  : out std_logic := '0'; -- LA14_N
   LP_CLK_P : out std_logic := '0'; -- FMC_LP_CLK_P may be need to change to input to enble HS free-run clock hack!!!
   LP_CLK_N : out std_logic := '0'; -- FMC_LP_CLK_N may be need to change to input to enble HS free-run clock hack!!!
   
   --High Speed lines - HS
    HS_CLK_P : out std_logic := '0'; --LA00_CC_P
    HS_CLK_N : out std_logic := '0'; --LA00_CC_N
    HS_D0_P  : out std_logic := '0'; --FMC_LA02_P
    HS_D0_N  : out std_logic := '0'; --FMC_LA02_N
    HS_D1_P  : out std_logic := '0'; --FMC_LA03_P
    HS_D1_N  : out std_logic := '0'; --FMC_LA03_N
    HS_D2_P  : out std_logic := '0'; --FMC_LA04_P
    HS_D2_N  : out std_logic := '0'; --FMC_LA04_N
    HS_D3_P  : out std_logic := '0'; --FMC_LA08_P
    HS_D3_N  : out std_logic := '0'; --FMC_LA08_N

   --******MIPI CSI MGT based implemntation*******   
    --Low Power lines - LP
   LP2_CLK_P : out std_logic := '0'; --FMC_LP2_CLK_P
   LP2_CLK_N : out std_logic := '0'; --FMC_LP2_CLK_N
   LP2_D0_P  : out std_logic := '0'; --FMC_LP2_D0_P
   LP2_D0_N  : out std_logic := '0'; --FMC_LP2_D0_N
   LP2_D1_P  : out std_logic := '0'; --FMC_LP2_D1_P
   LP2_D1_N  : out std_logic := '0'; --FMC_LP2_D1_N
   LP2_D2_P  : out std_logic := '0'; --FMC_LP2_D2_P
   LP2_D2_N  : out std_logic := '0'; --FMC_LP2_D2_N
   
   
   
   
      
   leds_debug : out std_logic_vector(7 downto 0) := (others => '0');
   dummy : in std_logic

   );
end fmc_mipi_top;

architecture Behavioral of fmc_mipi_top is

begin

FMC_I2C_CAM_CLK <= 'Z';
FMC_I2C_CAM_DAT <= 'Z';
   
FMC_I2C_GP0_CLK_1V8 <= 'Z';
FMC_I2C_GP0_DAT_1V8 <= 'Z';

end Behavioral;
