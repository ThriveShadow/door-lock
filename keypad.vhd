library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity keypad is
    Port ( clk    : in  STD_LOGIC;                     -- Clock signal
           reset  : in  STD_LOGIC;                     -- Reset signal
           row    : in  STD_LOGIC_VECTOR (3 downto 0);  -- Row signals from keypad
           col    : out STD_LOGIC_VECTOR (3 downto 0);  -- Column signals to keypad
           key    : out STD_LOGIC_VECTOR (3 downto 0);   -- Key pressed (4-bit binary)
           set    : inout STD_LOGIC;
           buzzer : out STD_LOGIC
         );
end keypad;

architecture Behavioral of keypad is
    -- Internal signal for storing key press
    signal key_pressed : STD_LOGIC_VECTOR (3 downto 0) := "1111";  -- Initialize to no key pressed
    signal col_sel : integer range 0 to 3 := 0;  -- Column selection signal (which column is driven)
    signal set_key_pressed : STD_LOGIC := '0';
begin
    -- Column driver logic: Only one column is active at a time
    col <= "1110" when col_sel = 0 else  
           "1101" when col_sel = 1 else  
           "1011" when col_sel = 2 else 
           "0111";                     

    -- Keypad scanning process
    process(clk, reset)
    begin
        if reset = '1' then
            key_pressed <= "1111";  -- Reset key press status
            col_sel <= 0;           -- Reset column selection to first column
        elsif rising_edge(clk) then
            -- Check the row lines for a key press
            case col_sel is
                when 0 =>
                    if row(0) = '0' then
                        key_pressed <= "0001";  -- Key 1
                    elsif row(1) = '0' then
                        key_pressed <= "0100";  -- Key 4
                    elsif row(2) = '0' then
                        key_pressed <= "0111";  -- Key 7
                    elsif row(3) = '0' then
                        key_pressed <= "0000";  -- Key 0
                    else
                        key_pressed <= "1111";  -- No key pressed
                    end if;
                when 1 =>
                    if row(0) = '0' then
                        key_pressed <= "0010";  -- Key 2
                    elsif row(1) = '0' then
                        key_pressed <= "0101";  -- Key 5
                    elsif row(2) = '0' then
                        key_pressed <= "1000";  -- Key 8
                    elsif row(3) = '0' then
                        key_pressed <= "1111";  -- Key F
                    else
                        key_pressed <= "1111";  -- No key pressed
                    end if;
                when 2 =>
                    if row(0) = '0' then
                        key_pressed <= "0011";  -- Key 3
                    elsif row(1) = '0' then
                        key_pressed <= "0110";  -- Key 6
                    elsif row(2) = '0' then
                        key_pressed <= "1001";  -- Key 9
                    elsif row(3) = '0' then
                        key_pressed <= "1110";  -- Key E
                    else
                        key_pressed <= "1111";  -- No key pressed
                    end if;
                when 3 =>
                    if row(0) = '0' then
                        set_key_pressed <= '1';  -- Set key pressed, keep the flag high
                        if set = '0' then
                            set <= '1';
                        else
                            set <= '0';
                        end if;              -- Trigger the set signal
                    elsif row(1) = '0' then
                        key_pressed <= "1011";  -- Key B
                    elsif row(2) = '0' then
                        key_pressed <= "1100";  -- Key C
                    elsif row(3) = '0' then
                        key_pressed <= "1101";  -- Key D
                    else
                        key_pressed <= "1111";  -- No key pressed
                    end if;
                when others => 
                    key_pressed <= "1111";  -- Default case (no key pressed)
            end case;
            -- Move to next column
            if col_sel = 3 then
                col_sel <= 0;
            else
                col_sel <= col_sel + 1;
            end if;
            
            if key_pressed /= "1111" then
                buzzer <= '1';
            else 
                buzzer <= '0';
            end if;
        end if;
    end process;

    -- Output the detected key press
    key <= key_pressed;

end Behavioral;
