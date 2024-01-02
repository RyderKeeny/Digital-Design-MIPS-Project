library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY CONTROLLER IS 
PORT (
	clk : in std_logic;
	rst  : in std_logic;
	IR : IN STD_LOGIC_VECTOR(5 DOWNTO 0); --ALUop
	
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
TYPE state_type IS (START, INIT_FETCH, DELAY, DECODE, MEM_ADDR, MEM_READ, EXECUTION, EXE_DELAY, BRANCH, BRANCH_DELAY, JUMP, MEM_COMP); --  ,
SIGNAL STATE, NEXTSTATE : state_type;

SIGNAL OPCODE : STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL RS : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL RT : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL RD : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL SHAMT : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL FUNCT : STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL ADDR : STD_LOGIC_VECTOR(15 DOWNTO 0); 

BEGIN 
	process (clk, rst) 
	begin
		IF RST = '1' THEN
            STATE <= INIT_FETCH;
		ELSIF rising_edge(clk) THEN
			STATE <= NEXTSTATE;
		END IF;		
	END PROCESS;
	
	
	
	PROCESS (STATE, OPCODE, IR) 	
	BEGIN 
		OPCODE <= IR; 

		ALUSrcA <= '0';
		ALUSrcB <= "01";
		ALUOp <= "00";
		PCSource <= "00";
		IRWrite <= '0';
		MemRead <= '0';
		MEMwRITE <= '0';
		MemToReg <= '0';
		PCWrite <= '0';
		PCWRITECOND <= '0';
		IorD <= '0';
		REGWRITE <= '0';
		REGdST <= '0';
		JANDL <= '0';
		ISsiGNED <= '0';	

		NEXTSTATE <= STATE;
	
		case state IS
			WHEN START => 

				ALUSrcA <= '0';
				ALUSrcB <= "01";
				ALUOp <= "00";
				PCSource <= "00";
				IRWrite <= '1';
				MemRead <= '1';
				MEMwRITE <= '0';
				MemToReg <= '1';
	
	
				NEXTSTATE <= INIT_FETCH;
		
			WHEN INIT_FETCH => 
				ALUSrcA <= '0';
				ALUSrcB <= "01";
				ALUOp <= "00";
				PCSource <= "00";
				IRWrite <= '0';
				MemRead <= '1';
				MEMwRITE <= '0';
				MemToReg <= '1';
				PCWrite <= '1';
				PCWRITECOND <= '0';
				IorD <= '0';
				REGWRITE <= '1';
				REGdST <= '0';
				JANDL <= '0';
				ISsiGNED <= '0';
				
				NEXTSTATE <= DECODE;

			WHEN DECODE => 
            ALUSrcB <= "11";
				IRWrite <= '1';
				ALUOp <= "00";
				
				NEXTSTATE <= DELAY;
			
			WHEN DELAY => 
				IRWrite <= '0';
				MemRead <= '1';
				REGWRITE <= '1';
				ALUSrcB <= "01";
				
            IF OPCODE = "100011" OR OPCODE = "101011" THEN -- LW OR SW
		 			ALUOp <= "00";
					NEXTSTATE <= MEM_ADDR;
            
            ELSIF OPCODE = "000000" THEN -- R-Type Instructions
               ALUOp <= "10";
					NEXTSTATE <= EXECUTION;
            
            ELSIF OPCODE = "000100" OR OPCODE = "000101" OR OPCODE = "000110" OR OPCODE = "000111" THEN -- Branch Instructions (BEQ, BNE)
					ALUOp <= "01";
					NEXTSTATE <= BRANCH;
            
            ELSIF OPCODE = "000010" OR OPCODE = "000011" THEN -- Jump Instructions (J, JAL)
					ALUOp <= "01";                
					NEXTSTATE <= JUMP;
				ELSE 
					NEXTSTATE <= INIT_FETCH;
				END IF;
			
			
			WHEN MEM_ADDR => 
				ALUSrcB <= "10";
				ALUSrcA <= '1';
				IRWrite <= '0';	
				
				IF OPCODE = "100011" THEN -- LW 
					MEMREAD <= '1';
					MEMWRITE <= '0';
					IorD <= '1';
					RegDst <= '1';	
					RegWrite <= '1';
					MemtoReg <= '0';
				
				ELSIF OPCODE = "101011" THEN -- SW
					MEMWRITE <= '1';
					MEMREAD <= '0';
					IorD <= '1';
				
				END IF;			

				NEXTSTATE <= MEM_READ;
				
			
			WHEN MEM_READ =>
				RegDst <= '1';
				regWrite <= '1';
				MemtoReg <= '0';			
				NEXTSTATE <= MEM_COMP;
			
			WHEN EXECUTION => 
				IRWrite <= '0';
				PCWriteCond <= '1';
				ALUSrcB <= "00";
				ALUSrcA <= '1';

				IF IR <= "011000" THEN --MULT SIGNED
					ISsiGNED <= '1';

				ELSIF IR <= "101010" THEN -- SLT SIGNED
					ISsiGNED <= '1';
				END IF;
				--CHECKING THE VALUES OF THE RS RT SHAMT TO THEN RUN THE PROPER ALU FUNCT
				NEXTSTATE <= EXE_DELAY;
			
			WHEN EXE_DELAY => 
				RegDst <= '1';
				regWrite <= '1';
				MemtoReg <= '0';
				NEXTSTATE <= MEM_COMP;
			
			WHEN BRANCH => 
				IRWrite <= '0';
				ALUSrcB <= "00";
				ALUSrcA <= '1';
				PCWriteCond <= '1';
				PCSource <= "01";
				NEXTSTATE <= BRANCH_DELAY;
				
			WHEN BRANCH_DELAY => 
				PCWriteCond <= '1';
				IRWrite <= '0';
				NEXTSTATE <= MEM_COMP;
			
			WHEN JUMP => 
				IRWrite <= '0';			
				PCWrite <= '1';
				PCSource <= "10";
				IF IR <= "000011" THEN --JANDL OPsel
					JANDL <= '1';
				END IF;
				
				NEXTSTATE <= MEM_COMP;
				
			WHEN MEM_COMP =>
				NEXTSTATE <= INIT_FETCH;
		
		
		END CASE;
	END PROCESS;

END STR;

