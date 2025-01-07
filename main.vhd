library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main is
Port (
    clk    : in STD_LOGIC;                        -- Input clock signal
    row    : in  STD_LOGIC_VECTOR (3 downto 0);    -- Row signals from keypad
    col    : out STD_LOGIC_VECTOR (3 downto 0);    -- Column signals to keypad
    reset  : in STD_LOGIC;                         -- Reset signal
    Anode  : out STD_LOGIC_VECTOR (7 downto 0);
    Output : out STD_LOGIC_VECTOR (6 downto 0);
    LED : out STD_LOGIC;
    LED_SET: out STD_LOGIC;
    Buzzer: out STD_LOGIC
);
end main;

architecture Behavioral of main is

-- Declare components
component clock is
    Port(
       clk_out : out STD_LOGIC;    -- Output clock signal (slower clock)
       clk_in  : in  STD_LOGIC     -- Input clock signal (fast clock)
    );
end component;

component keypad is
    Port(
        clk    : in  STD_LOGIC;                     -- Clock signal
        reset  : in  STD_LOGIC;                     -- Reset signal
        row    : in  STD_LOGIC_VECTOR (3 downto 0);  -- Row signals from keypad
        col    : out STD_LOGIC_VECTOR (3 downto 0);  -- Column signals to keypad
        key    : out STD_LOGIC_VECTOR (3 downto 0);   -- Key pressed (4-bit binary)
        set    : inout STD_LOGIC;
        buzzer : out std_logic
    );
end component;

component seven is
    Port (
        Key1, Key2, Key3, Key4, Key5, Key6, Key7, Key8 : in std_logic_vector(3 downto 0);  -- 4-bit inputs for each key
        Anode  : out std_logic_vector(7 downto 0);                  -- Anode control for 4 seven-segment displays
        Output : out std_logic_vector(6 downto 0);                    -- 7-segment display output for the active display
        clk   : in  STD_LOGIC
    );
end component;

-- Signals
signal clk_out   : STD_LOGIC;   
signal buzz: STD_LOGIC; 
signal stored_key : STD_LOGIC_VECTOR(3 downto 0) := "1111";  -- Register to store the key value
signal key_storage : STD_LOGIC_VECTOR(3 downto 0) := "1111";  -- Temporary storage for each key

signal key1, key2, key3, key4, key5, key6, key7, key8: STD_LOGIC_VECTOR(3 downto 0);

signal set: std_logic:= '0';
signal isOpen: std_logic;

-- Set PIN Here!!
signal pin1: STD_LOGIC_VECTOR(3 downto 0):= "0001";
signal pin2: STD_LOGIC_VECTOR(3 downto 0):= "0010";
signal pin3: STD_LOGIC_VECTOR(3 downto 0):= "0011";
signal pin4: STD_LOGIC_VECTOR(3 downto 0):= "0100";
signal pin5: STD_LOGIC_VECTOR(3 downto 0):= "0001";
signal pin6: STD_LOGIC_VECTOR(3 downto 0):= "0010";
signal pin7: STD_LOGIC_VECTOR(3 downto 0):= "0011";
signal pin8: STD_LOGIC_VECTOR(3 downto 0):= "0100";

-- Counter to store keys in sequence (key1, key2, key3, key4)
signal key_count : integer range 0 to 7 := 0;

begin

-- Instantiate the clock divider
w0: clock
    Port Map(
        clk_in  => clk,           -- Input fast clock
        clk_out => clk_out        -- Output slower clock
    );

-- Instantiate the keypad scanner
w1: keypad
    Port Map(
        clk    => clk_out,         -- Slower clock from the clock divider
        reset  => reset,           -- Reset signal
        row    => row,             -- Row input from keypad
        col    => col,             -- Column output to keypad
        key    => stored_key,       -- Output key pressed (4-bit value)
        set    => set,
        Buzzer => buzzer
    );

-- Process to store the key values (key1, key2, key3, key4)
process(clk_out, reset)
begin
    if reset = '1' then
        -- Reset all stored key values to "1111"
        key1 <= "1111";
        key2 <= "1111";
        key3 <= "1111";
        key4 <= "1111";
        key5 <= "1111";
        key6 <= "1111";
        key7 <= "1111";
        key8 <= "1111";
        key_count <= 0;  -- Reset the counter
    elsif rising_edge(clk_out) then
        -- If a key is pressed and it's not the default "1111" value, store it
        if stored_key /= "1111" then
            case key_count is
                when 0 =>
                    key1 <= stored_key;   -- Store the first key pressed
                when 1 =>
                    key2 <= stored_key;   -- Store the second key pressed
                when 2 =>
                    key3 <= stored_key;   -- Store the third key pressed
                when 3 =>
                    key4 <= stored_key;   -- Store the fourth key pressed
                when 4 =>
                    key5 <= stored_key;   -- Store the first key pressed
                when 5 =>
                    key6 <= stored_key;   -- Store the second key pressed
                when 6 =>
                    key7 <= stored_key;   -- Store the third key pressed
                when 7 =>
                    key8 <= stored_key;  
            end case;

            -- Increment the key counter
            if key_count < 7 then
                key_count <= key_count + 1;
            elsif key_count = 7 then
                key_count <= 0;
            end if;
        end if;
    end if;
end process;

w2: seven
    Port Map(
        key1 => key1,
        key2 => key2,
        key3 => key3,
        key4 => key4,
        key5 => key5,
        key6 => key6,
        key7 => key7,
        key8 => key8,
        Anode => Anode,
        Output => Output,
        clk => clk
    );
    
-- If key1=pin1 and key2=pin2 and key3=pin3 key4=pin4, set isOpen to 1
process (key1, key2, key3, key4, key5, key6, key7, key8, pin1, pin2, pin3, pin4, pin5, pin6, pin7, pin8, isOpen, set, reset)
    begin
    
        if (key1 = pin1) and (key2 = pin2) and (key3 = pin3) and (key4 = pin4) and (key5 = pin5) and (key6 = pin6) and (key7 = pin7) and (key8 = pin8) then
            isOpen <= '1';
        end if;
        
        if (reset = '1') then
            isOpen <= '0';
        end if;
        
        if (isOpen = '1') and (set = '1') then
            pin1 <= key1;
            pin2 <= key2;
            pin3 <= key3;
            pin4 <= key4;
            pin5 <= key5;
            pin6 <= key6;
            pin7 <= key7;
            pin8 <= key8;
        end if;
        
        LED_SET <= set;
        LED <= isOpen;
        
end process;

end Behavioral;
