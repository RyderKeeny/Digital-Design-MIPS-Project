LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all; 

ENTITY shiftleft IS 
	generic ( width : positive := 32 ); 
	PORT (
		clk : in std_logic; 
		rst : in std_logic;
		input : in std_logic_vector(width-1 downto 0);
		output : out std_logic_vector(width-1 downto 0)
	);
	
END shiftleft;

ARCHITECTURE STR OF shiftleft IS 
	signal temp_input : unsigned(width-1 downto 0);

BEGIN
	temp_input <= unsigned(input);
	
	PROCESS (rst, clk) 
	BEGIN
		if rst = '1' then 
			output <= (others => '0');
		
		elsif clk 'event and clk = '1' then
			output <= std_logic_vector(shift_left(temp_input, 2));
	
		end if;
		
	END PROCESS;
	
END STR;