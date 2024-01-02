library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


Entity memory IS 
	GENERIC (WIDTH : POSITIVE := 32;
				SWITCH : POSITIVE := 9);
	PORT (clk : IN STD_LOGIC;
			RST : IN STD_LOGIC;
			baddr : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
			dataIN : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
			memREAD : IN STD_LOGIC;										-- read enable
			memWRITE : IN STD_LOGIC;									--	write enable
			dataOUT : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
			
			INPORT0 : IN STD_LOGIC_VECTOR(SWITCH-1 DOWNTO 0);		-- switches 1-9 to indicate addresses
			INPORT1 : IN STD_LOGIC_VECTOR(SWITCH-1 DOWNTO 0);
			INPORT_SEL : IN STD_LOGIC;								 	-- SELECTING which inport to use 10th switch
			
			OUTPORT1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- LED 0
			OUTPORT2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- LED 1
			OUTPORT3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- LED 2
			OUTPORT4 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)  -- LED 3
			);
	
END memory;

ARCHITECTURE STR OF memory IS

	SIGNAL TEMP_DATAOUT : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); 
	SIGNAL TEMP_INPORT0, TEMP_INPORT1, TEMP_INPORT : STD_LOGIC_VECTOR(SWITCH-1 DOWNTO 0);
	SIGNAL TEMP_SEL, TEMP_SEL0, TEMP_SEL1 : STD_LOGIC;
	SIGNAL TEMP_OUTPUT1, TEMP_OUTPUT2, TEMP_OUTPUT3, TEMP_OUTPUT4 : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

	TEMP_OUTPUT1 <= dataIN(15 downto 12);
	TEMP_OUTPUT2 <= dataIN(11 downto 8);
	TEMP_OUTPUT3 <= dataIN(7 downto 4);
	TEMP_OUTPUT4 <= dataIN(3 downto 0);
		
	PROCESS (INPORT_SEL, CLK, RST ) --USED TO SET UP WHICH INPORT IS TAKEN 
	BEGIN
		
		IF INPORT_SEL = '0' THEN
				TEMP_SEL0 <= '1';
				TEMP_SEL1 <= '0';
		ELSE
				TEMP_SEL0 <= '0';
				TEMP_SEL1 <= '1';	
								
		END IF;
	
	END PROCESS;

	
	PROCESS (baddr, TEMP_INPORT0, TEMP_INPORT1, TEMP_DATAOUT)
	BEGIN
		IF baddr = X"0000FFF8" THEN 
			dataOUT <= "00000000000000000000000" & TEMP_INPORT0; -- INPORT 0 SWITCHES
		
		ELSIF baddr = X"0000FFFC" THEN
			dataOUT <= "00000000000000000000000" & TEMP_INPORT1; -- INPORT 1 SWITCHES

		ELSE 
			dataOUT <= TEMP_DATAOUT; -- RAM OUTPUT
		END IF;
		
		
	END PROCESS;
	

	MEMORY_RAM : ENTITY work.RAM
		PORT MAP (address => baddr(9 DOWNTO 2), -- Adjusted for word-aligned addresses
					 data => dataIN,
					 rden => memREAD,
					 wren => memWRITE,
					 clock => clk,
					 q => TEMP_DATAOUT );	
							

	MEMORY_INPORT_0 : ENTITY work.reg
		PORT MAP (clk => clk,
				    rst  => rst,
				    en => TEMP_SEL0,
				    data_in  => INPORT0,
				    data_out => TEMP_INPORT0 );
	
	
	MEMORY_INPORT_1 : ENTITY work.reg
		PORT MAP (clk => clk,
					 rst  => rst,
					 en => TEMP_SEL1,
					 data_in  => INPORT1,
					 data_out => TEMP_INPORT1 );
	
	
	MEMORY_OUTPORT_1 : entity WORK.decoder7seg
		PORT MAP (input  => TEMP_OUTPUT1,
					 output => OUTPORT1 );

	MEMORY_OUTPORT_2 : entity WORK.decoder7seg
		PORT MAP (input  => TEMP_OUTPUT2,
					 output => OUTPORT2 );
	
	MEMORY_OUTPORT_3 : entity WORK.decoder7seg
		PORT MAP (input  => TEMP_OUTPUT3,
					 output => OUTPORT3);
	
	MEMORY_OUTPORT_4 : entity WORK.decoder7seg
		PORT MAP (input  => TEMP_OUTPUT4,
					 output => OUTPORT4 );

					
END STR; 