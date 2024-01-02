LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY TOPLEVEL_TB IS
END TOPLEVEL_TB;

ARCHITECTURE behavior OF TOPLEVEL_TB IS
    -- Component Declaration for the TOPLEVEL
    COMPONENT TOPLEVEL
        PORT(
            CLK : IN std_logic;
            RST : IN std_logic;
            SWITCHES : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            BUTTON : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            MemoryDataToLED1 : OUT std_logic_vector(6 DOWNTO 0);
            MemoryDataToLED2 : OUT std_logic_vector(6 DOWNTO 0);
            MemoryDataToLED3 : OUT std_logic_vector(6 DOWNTO 0);
            MemoryDataToLED4 : OUT std_logic_vector(6 DOWNTO 0)
        );
    END COMPONENT;

    -- Inputs
    SIGNAL CLK : std_logic := '0';
    SIGNAL RST : std_logic := '0';
    SIGNAL SWITCHES : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL BUTTON : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');

    -- Outputs
    SIGNAL MemoryDataToLED1 : std_logic_vector(6 DOWNTO 0);
    SIGNAL MemoryDataToLED2 : std_logic_vector(6 DOWNTO 0);
    SIGNAL MemoryDataToLED3 : std_logic_vector(6 DOWNTO 0);
    SIGNAL MemoryDataToLED4 : std_logic_vector(6 DOWNTO 0);

    -- Clock period definitions
    CONSTANT CLK_period : time := 10 ns;

BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut: COMPONENT TOPLEVEL
        PORT MAP (
            CLK => CLK,
            RST => RST,
            SWITCHES => SWITCHES,
            BUTTON => BUTTON,
            MemoryDataToLED1 => MemoryDataToLED1,
            MemoryDataToLED2 => MemoryDataToLED2,
            MemoryDataToLED3 => MemoryDataToLED3,
            MemoryDataToLED4 => MemoryDataToLED4
        );

    -- Clock process definitions
    CLK_process :process
    BEGIN
	FOR K IN 0 TO 400 LOOP 
        	CLK <= '0';
 	       WAIT FOR CLK_period/2;
 	       CLK <= '1';
 	       WAIT FOR CLK_period/2;
	END LOOP;
    END PROCESS;

    -- Stimulus process
    STIMULUS: process
    BEGIN
        -- Initialize Inputs
        RST <= '1';
        WAIT FOR CLK_period * 2;
        RST <= '0';

        WAIT;
    END PROCESS;
END;
