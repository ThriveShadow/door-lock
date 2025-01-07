library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.All;

entity seven is
    Port (
        Key1, Key2, Key3, Key4, Key5, Key6, Key7, Key8 : in std_logic_vector(3 downto 0);  -- 4-bit inputs for each key
        Anode  : out std_logic_vector(7 downto 0);                  -- Anode control for 4 seven-segment displays
        Output : out std_logic_vector(6 downto 0);                    -- 7-segment display output for the active display
        clk   : in  STD_LOGIC
    );
end seven;

architecture Behavioral of seven is

    -- 7-segment display encoding for digits 0-9
    function seg_code(input : std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        case input is
            when "0000" => return "0000001"; -- 0
            when "0001" => return "1001111"; -- 1
            when "0010" => return "0010010"; -- 2
            when "0011" => return "0000110"; -- 3
            when "0100" => return "1001100"; -- 4
            when "0101" => return "0100100"; -- 5
            when "0110" => return "0100000"; -- 6
            when "0111" => return "0001111"; -- 7
            when "1000" => return "0000000"; -- 8
            when "1001" => return "0000100"; -- 9
            when others => return "1111111"; -- Default (0)
        end case;
    end function;

    -- Ring counter signal for 4 displays
    signal counter : std_logic_vector(2 downto 0) := "000";  -- 2-bit counter for 4 displays
    signal active_display : integer range 0 to 7 := 0;      -- Index for active display
    signal refresh_counter: STD_LOGIC_VECTOR (19 downto 0);

begin

    -- Ring counter process: cycling through 4 displays
    process(clk)  -- 
    begin 
    if(rising_edge(clk)) then
        refresh_counter <= refresh_counter + 1;
    end if;
end process;
counter <= refresh_counter(19 downto 17);

    -- Anode control: activate one display at a time
    process(counter)
    begin
        case counter is
            when "000" => 
                Anode <= "01111111";  -- Activate first display (Key1)
                Output <= seg_code(Key1);  -- Display Key1
            when "001" => 
                Anode <= "10111111";  -- Activate second display (Key2)
                Output <= seg_code(Key2);  -- Display Key2
            when "010" => 
                Anode <= "11011111";  -- Activate third display (Key3)
                Output <= seg_code(Key3);  -- Display Key3
            when "011" => 
                Anode <= "11101111";  -- Activate fourth display (Key4)
                Output <= seg_code(Key4);  -- Display Key4
            when "100" => 
                Anode <= "11110111";  -- Activate first display (Key1)
                Output <= seg_code(Key5);  -- Display Key1
            when "101" => 
                Anode <= "11111011";  -- Activate second display (Key2)
                Output <= seg_code(Key6);  -- Display Key2
            when "110" => 
                Anode <= "11111101";  -- Activate third display (Key3)
                Output <= seg_code(Key7);  -- Display Key3
            when "111" => 
                Anode <= "11111110";  -- Activate fourth display (Key4)
                Output <= seg_code(Key8);  -- Display Key4
            when others => 
                Anode <= "11111111";  -- Default state: no display
                Output <= "1111111";  -- Default to 0
        end case;
    end process;

end Behavioral;
