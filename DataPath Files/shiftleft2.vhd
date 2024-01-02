LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all; 

ENTITY shiftleft2 IS 
	generic ( width : positive := 28 ); 
	PORT (
		clk : in std_logic; 
		rst : in std_logic;
		input : in std_logic_vector(width-3 downto 0); -- 25 downto 0
		output : out std_logic_vector(width-1 downto 0) -- 27 downto 0
	);
	
END shiftleft2;

ARCHITECTURE STR OF shiftleft2 IS 
    signal temp_input : unsigned(width-3 downto 0);
    signal resized_temp_input : unsigned(width-1 downto 0);

BEGIN
    temp_input <= unsigned(input);
    
    PROCESS (rst, clk) 
    BEGIN
        if rst = '1' then 
            output <= (others => '0');
        
        elsif clk'event and clk = '1' then
            resized_temp_input <= resize(temp_input, width); -- Resize temp_input to the size of the output

            output <= std_logic_vector(shift_left(resized_temp_input, 2)); -- Shift left by 2

    
        end if;
        
    END PROCESS;
    
END STR;