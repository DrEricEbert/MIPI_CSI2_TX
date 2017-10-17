library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity simple_serializer is
    Port ( clk : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           data_out : out  STD_LOGIC;
           gate : in  STD_LOGIC);
end simple_serializer;

architecture Behavioral of simple_serializer is


signal old_ready : std_logic := '0';
signal shreg    : std_logic_vector( 7 downto 0);

begin


  process (clk,gate) begin
    if (clk'event and clk = '1') then
      shreg <= '0' & shreg(7 downto 1);     -- shift it left to right
       if (gate'event and gate = '1' and old_ready='0') then -- rising edge = new data
--      if gate='1' and old_ready='0' then -- rising edge = new data
        shreg <= data_in;              -- load it
       end if;
    end if;
  end process;

  data_out <= shreg(0);

end Behavioral;

