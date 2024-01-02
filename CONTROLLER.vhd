library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY CONTROLLER IS 
PORT (
	clk : in std_logic;
	rst  : in std_logic;
	
	MEM_DATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	IR : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
	
	PCWriteCond : out std_logic;
	PCWrite : out std_logic;
	IorD : out std_logic;
	MemRead : out std_logic;
	MemWrite : out std_logic;
	MemToReg : out std_logic;
	IRWrite : out std_logic;
	
	JandL : out std_logic;
	isSigned : out std_logic;
	PCSource : out std_logic_vector(1 downto 0);
	ALUOp  : out std_logic_vector(1 downto 0);
	ALUSrcA : out std_logic;
	ALUSrcB : out std_logic_vector(1 downto 0);	
	RegWrite : out std_logic;
	RegDst : out std_logic
);

END ENTITY;


ARCHITECTURE STR OF CONTROLLER IS 
TYPE state_type IS (INIT_FETCH, DECODE, MEM_ADDR, EXECUTION, BRANCH, JUMP, MEM_COMP);
SIGNAL STATE, NEXTSTATE : state_type;

SIGNAL OPCODE : STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL TEMP_PC : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL PC_4 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL RS : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL RT : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL RD : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL SHAMT : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL FUNCT : STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL ADDR : STD_LOGIC_VECTOR(15 DOWNTO 0); 

BEGIN 
	OPCODE <= IR; -- should these be placed within the initial fetch state
	TEMP_PC <= MEM_DATA;
	
	RS <= MEM_DATA(25 DOWNTO 21);
	RT <= MEM_DATA(20 DOWNTO 16);
	RD <= MEM_DATA(15 DOWNTO 11);
	SHAMT <= MEM_DATA(10 DOWNTO 6);
	FUNCT <= MEM_DATA(5 DOWNTO 0);
	ADDR <= MEM_DATA(15 DOWNTO 0);
	
	process (clk, rst) 
	begin
		IF RST = '0' THEN
            STATE <= INIT_FETCH;
		ELSIF rising_edge(clk) THEN
			STATE <= NEXTSTATE;
		END IF;		
	END PROCESS;
	
	PROCESS (STATE, OPCODE) 
	
	
	BEGIN 
		NEXTSTATE <= STATE;
	
		case state IS
			WHEN INIT_FETCH => 
				ALUSrcA <= '0';
				ALUSrcB <= "01";
				ALUOp <= "00";
				PCSource <= "00";
				IRWrite <= '1';
				MemRead <= '1';
				PCWrite <= '1';
				IorD <= '0';
				PC_4 <= STD_LOGIC_VECTOR(UNSIGNED(TEMP_PC) + 4);
				
				NEXTSTATE <= DECODE;
				
				
			WHEN DECODE => 
            ALUSrcB <= "11";
            
            IF OPCODE = "100011" OR OPCODE = "101011" THEN -- LW OR SW
					ALUOp <= "00";
					NEXTSTATE <= MEM_ADDR;
            
            ELSIF OPCODE = "000000" THEN -- R-Type Instructions
               ALUOp <= "10";
					NEXTSTATE <= EXECUTION;
            
            ELSIF OPCODE = "000100" OR OPCODE = "000101" THEN -- Branch Instructions (BEQ, BNE)
					ALUOp <= "01";
					NEXTSTATE <= BRANCH;
            
            ELSIF OPCODE = "000010" OR OPCODE = "000011" THEN -- Jump Instructions (J, JAL)
					ALUOp <= "01";                
					NEXTSTATE <= JUMP;
					
				END IF;
			
			
			WHEN MEM_ADDR => 
				ALUSrcB <= "10";
				ALUSrcA <= '1';
				
				IF OPCODE = "100011" THEN -- LW 
					MEMREAD <= '1';
					IorD <= '1';
					RegDst <= '1';			--SET HERE ONLY BECAUSE ITS THE ONLY TIME ITS DIRECTLY POINTS TO THE VALUE SHIFTS
					RegWrite <= '1';
					MemtoReg <= '0';
				
				ELSIF OPCODE = "101011" THEN -- SW
					MEMWRITE <= '1';
					IorD <= '1';
				
				END IF;
				NEXTSTATE <= MEM_COMP;
			
			WHEN EXECUTION => 
				ALUSrcB <= "10";
				ALUSrcA <= '1';
				RegDst <= '1';
				regWrite <= '1';
				MemtoReg <= '0';
				--CHECKING THE VALUES OF THE RS RT SHAMT TO THEN RUN THE PROPER ALU FUNCT
				NEXTSTATE <= MEM_COMP;
			
			WHEN BRANCH => 
				ALUSrcB <= "10";
				ALUSrcA <= '1';
				PCWriteCond <= '1';
				PCSource <= "01";
				NEXTSTATE <= MEM_COMP;
			
			WHEN JUMP => 
				PCWrite <= '1';
				PCSource <= "10";
				NEXTSTATE <= MEM_COMP;
		
			WHEN MEM_COMP =>
				NEXTSTATE <= INIT_FETCH;
		
		
		END CASE;
	END PROCESS;

END STR;

