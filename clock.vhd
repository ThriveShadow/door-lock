library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clock is
 Port ( clk_out : out STD_LOGIC;
        clk_in  : in  STD_LOGIC
      );
end clock;

architecture Behavioral of clock is
    signal count : integer :=0;
    signal b : std_logic :='0'; 
begin
process (clk_in)
    begin
        if(rising_edge(clk_in)) then
            count <=count+1;
            if(count = 3000000) then
                b <= not b;
                count <=0;
            end if;
        end if;
        clk_out<=b;
    end process;
end Behavioral;
