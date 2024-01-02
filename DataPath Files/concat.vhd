LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all; 

ENTITY CONCAT IS 
	PORT ( 
		FIRST : IN STD_LOGIC_VECTOR(31 DOWNTO 28);
		SECOND : IN STD_LOGIC_VECTOR(27 DOWNTO 0);
		OUTPUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
	
END CONCAT;

ARCHITECTURE STR OF CONCAT IS 
	SIGNAL TEMPOUT : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

	TEMPOUT <= FIRST & SECOND;
		
	OUTPUT <= TEMPOUT;
	
END STR;