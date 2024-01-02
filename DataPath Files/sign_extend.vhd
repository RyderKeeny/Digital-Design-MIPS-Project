LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all; 

ENTITY sign_extend IS 
	PORT (
		CLK : IN STD_LOGIC;
		RST : IN STD_LOGIC;
		isSigned : in std_logic;
		input : in std_logic_vector(15 downto 0); -- 16 bit
		output : out std_logic_vector(31 downto 0) -- 32 bit 
	);
	
END sign_extend;

ARCHITECTURE STR OF sign_extend IS 
	signal signed_input : signed(15 downto 0);
	
BEGIN
	signed_input <= signed(input);

	PROCESS (isSigned) 
	BEGIN
			if isSigned = '1' then
				output <= std_logic_vector(resize(signed_input, 32));
			
			else  
				output <= (OTHERS => '0');
		end if;
		
	END PROCESS;
	
END STR;