library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


ENTITY DATAPATH IS -- ALL INPORTS COME FROM THE CONTROLLER, OUTPORTS ARE THE LEDs FROM THE MEMORY AND 31-26 FROM IN_REG
    PORT (
		CLK : IN std_logic;
		RST : IN std_logic;
		
		SWITCHES : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		BUTTON : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		
		PCWriteCond : IN std_logic;
		PCWrite : IN std_logic;
		IorD : IN std_logic;
		MemRead : IN std_logic;
		MemWrite : IN std_logic;
		MemtoReg : IN std_logic;
		IRWrite : IN std_logic;
		PCSource : IN std_logic_vector(1 DOWNTO 0);
		ALUOp : IN std_logic_vector(1 DOWNTO 0);
		ALUSrcB : IN std_logic_vector(1 DOWNTO 0);
		ALUSrcA : IN std_logic;
		RegWrite : IN std_logic;
		RegDst : IN std_logic;
		JandL : IN std_logic;
		isSigned : IN STD_LOGIC;
		
      MemoryDataToLED1 : OUT std_logic_vector(6 DOWNTO 0); -- 4 outputs from the memory directly connected to LEDs
		MemoryDataToLED2 : OUT std_logic_vector(6 DOWNTO 0); 
		MemoryDataToLED3 : OUT std_logic_vector(6 DOWNTO 0); 
		MemoryDataToLED4 : OUT std_logic_vector(6 DOWNTO 0); 
		Instruction_31_26 : OUT std_logic_vector(5 DOWNTO 0) -- Bits 31-26 from IN_REG
	);
	
	
END DATAPATH;

ARCHITECTURE STR OF DATAPATH IS 

signal PC_to_MUX, MUX_TO_MEM, MUX_TO_PC: std_logic_vector(31 DOWNTO 0);

signal MEM_TO_REG : std_logic_vector(31 DOWNTO 0);
	
signal INSTreg1 : STD_LOGIC_VECTOR(25 downto 0);
signal INSTreg2 : STD_LOGIC_VECTOR(5 downto 0);
signal INSTreg3 : STD_LOGIC_VECTOR(4 downto 0);
signal INSTreg4 : STD_LOGIC_VECTOR(4 downto 0);
SIGNAL INSTreg5 : STD_LOGIC_VECTOR(4 downto 0);
SIGNAL INSTreg6 : STD_LOGIC_VECTOR(15 downto 0);  
  
signal MEMreg_TO_MUX : std_logic_vector(31 DOWNTO 0);
signal MUX_TO_MUX_WRDATA : std_logic_vector(31 DOWNTO 0);

SIGNAL MUX_TO_WRreg : std_logic_vector(4 DOWNTO 0);
signal MUX_TO_WRDATA, PC_4: std_logic_vector(31 DOWNTO 0);
SIGNAL regfile_data_out1, regfile_data_out2: std_logic_vector(31 DOWNTO 0);

signal REGA_TO_MUX, alu_in1 : std_logic_vector(31 DOWNTO 0);
	
SIGNAL REGB_TO_MUXandMEM, alu_in2, SIGNex_TO_SHIFT, SHIFT_TO_MUX, FOUR : std_logic_vector(31 DOWNTO 0);
signal RESULT, RESULT_HI : std_logic_vector(31 DOWNTO 0);
signal BRANCH_TAKEN : STD_LOGIC;

signal HI_TO_MUX, LO_TO_MUX, ALU_OUT : std_logic_vector(31 DOWNTO 0);
SIGNAL ALU_LO_HI : STD_LOGIC_VECTOR(1 DOWNTO 0);

SIGNAL HI_EN, LO_EN : STD_LOGIC;
SIGNAL ALUcontrol_TO_ALU : STD_LOGIC_VECTOR(4 downto 0);
SIGNAL IR50 : STD_LOGIC_VECTOR(5 DOWNTO 0); -- INSTRUCT REG(31-26) & REG(5-0)

SIGNAL SHIFT2_CONCAT : STD_LOGIC_VECTOR(27 DOWNTO 0);
SIGNAL CONCAT_MUX : STD_LOGIC_VECTOR(31 DOWNTO 0);
	
SIGNAL PC_EN : STD_LOGIC;
	
BEGIN

	PC_EN <= (PCWrite or (PCWriteCond AND BRANCH_TAKEN));
	FOUR <= std_logic_vector(to_unsigned(4, 32));
	IR50 <= INSTREG6(5 DOWNTO 0);
	PC_4 <= STD_LOGIC_VECTOR(UNSIGNED(PC_TO_MUX) + 4);
	
	PC : ENTITY WORK.REG
		GENERIC MAP (WIDTH => 32)
		PORT MAP (
			CLK => CLK, 
         rst => rst,  
         en => PC_EN, 
         data_in => MUX_TO_PC, 
         data_out => PC_TO_MUX
		);
	
	MUX_MEM : ENTITY WORK.MUX
		GENERIC MAP (WIDTH => 32)
		PORT MAP (
			en => '1',
			w0 => PC_TO_MUX,
			w1 => ALU_OUT, 
			s => IorD,
			f => MUX_TO_MEM		
		);
		
	MEM : ENTITY WORK.MEMORY
		PORT MAP (
			CLK => CLK, 
			RST => RST,
			baddr => REGB_TO_MUXandMEM,
			dataIN => MUX_TO_MEM, 
			memREAD => MemRead, 
			memWRITE => Memwrite, 
			dataOUT => MEM_TO_REG,
			INPORT0 => SWITCHES(8 downto 0), 		
			INPORT1 => SWITCHES(8 downto 0),
			INPORT_SEL => BUTTON(0),
			OUTPORT1 => MemoryDataToLED1, 
			OUTPORT2 => MemoryDataToLED2, 
			OUTPORT3 => MemoryDataToLED3, 
			OUTPORT4 => MemoryDataToLED4
		);
	
	INST_REG : ENTITY work.INTRUCTION_REGISTER
		PORT MAP(
			CLK => CLK, 
			rst => rst,
			IRWrite => IRWrite, 
			data_in => MEM_TO_REG, 			-- (WIDTH-1 downto 0) FROM THE MEMORY OUTPUT
			data_out1 => INSTreg1,
			data_out2 => INSTreg2,
			data_out3 => INSTreg3,
			data_out4 => INSTreg4,
			data_out5 => INSTreg5,
			data_out6 => INSTreg6		
		);
		
	Instruction_31_26 <= INSTreg2;


	MEM_REG : ENTITY work.REG
	GENERIC MAP (WIDTH => 32)
		PORT MAP (
			CLK => CLK, 
         rst => rst,  
         en => '1', 
         data_in => MEM_TO_REG, 
         data_out => MEMreg_TO_MUX		
		);
	
	MUX2_WR_DATA : ENTITY work.MUX
		GENERIC MAP (WIDTH => 32)
		PORT MAP (
			en => '1',
			w0 => MUX_TO_MUX_WRDATA,
			w1 => MEMreg_TO_MUX, 
			s => MemtoReg,
			f => MUX_TO_WRDATA	
		);

	MUX2_WR_REG : ENTITY work.MUX
		GENERIC MAP (WIDTH => 5)
		PORT MAP (
			en => '1',
			w0 => INSTreg4,
			w1 => INSTreg5, 
			s => RegDst,
			f => MUX_TO_WRreg
		);	
		
	REG_FILE : ENTITY work.registerfile
		PORT MAP (
			clk  => CLK, 
			rst  => RST, 	
			rd_addr0  => INSTreg3, 					-- (4 downto 0)
			rd_addr1  => INSTreg4, 					-- (4 downto 0)
			wr_addr  => MUX_TO_WRreg, 				-- (4 downto 0)
			wr_en  => RegWrite, 						-- std_logic;
			wr_data  => MUX_TO_WRDATA, 			-- (31 downto 0)
			rd_data0  => regfile_data_out1, 		-- (31 downto 0)
			rd_data1  => regfile_data_out2, 		-- (31 downto 0)
			PC_4  => PC_4, 							-- (31 downto 0)
			JumpAndLink => JandL 					-- std_logic
		);
		
	REG_A : ENTITY work.REG
	GENERIC MAP (WIDTH => 32)
		PORT MAP (
			CLK => CLK, 
         rst => RST,  
         en => '1', 
         data_in => regfile_data_out1, 
         data_out => REGA_TO_MUX		
		);
		
	REG_B : ENTITY work.REG
	GENERIC MAP (WIDTH => 32)
		PORT MAP (
			CLK => CLK, 
         rst => RST,  
         en => '1', 
         data_in => regfile_data_out2, 
         data_out => REGB_TO_MUXandMEM
		);
		
	MUX_ALU_A : ENTITY work.MUX
		GENERIC MAP (WIDTH => 32)
		PORT MAP (
			en => '1', 
			w0 => PC_to_MUX,
			w1 => REGA_TO_MUX, 
			s => ALUSrcA,
			f => alu_in1 
		);
		
	MUX_ALU_B : ENTITY work.MUX4TO1
		GENERIC MAP (WIDTH => 32)
		PORT MAP (
			en => '1',
			w0 => REGB_TO_MUXandMEM,
			w1 => FOUR, 
			W2 => SIGNex_TO_SHIFT,
			W3 => SHIFT_TO_MUX,
			s => ALUSrcB,
			f =>  alu_in2
		);
		
	SGN_EXT : ENTITY work.SIGN_EXTEND
		PORT MAP (
			CLK => CLK,
			rst => rst,
			isSigned => isSigned,
			input => INSTreg6,
			output => SIGNex_TO_SHIFT
		);
	
	
	SHIFT_28bit : ENTITY work.SHIFTLEFT2
		GENERIC MAP (WIDTH => 28)
		PORT MAP (
			CLK => CLK,
			rst => rst,
			input => INSTreg1,
			output => SHIFT2_CONCAT
		);
	
	SHIFT_32bit : ENTITY work.SHIFTLEFT
		GENERIC MAP (WIDTH => 32)
		PORT MAP (
			CLK => CLK,
			rst => rst,
			input => SIGNex_TO_SHIFT,
			output => SHIFT_TO_MUX	
		
		);	
	
	concat : ENTITY work.concat
		PORT MAP (
			FIRST => PC_to_MUX(31 DOWNTO 28),
			SECOND => SHIFT2_CONCAT,
			OUTPUT => CONCAT_MUX	
		);	
	
	ALU_CTRL : ENTITY work.ALU_CONTROL
		PORT MAP(
				IR1 => INSTreg2,								-- (31 downto 26) FOR OPcode
				IR2 => IR50,									-- (5 DOWNTO 0) FOR R-TYPE
				aluOP =>  aluOP,							-- (1 DOWNTO 0)
				op_sel => ALUcontrol_TO_ALU, 			-- (4 downto 0)
				HI_EN => HI_EN, 							-- STD_LOGIC
				LO_EN => LO_EN, 							-- STD_LOGIC
				ALU_LO_HI => ALU_LO_HI	 				-- STD_LOGIC(1 DOWNTO 0)
		);
	
	ALU : ENTITY work.ALU
		PORT MAP (
				A  => alu_in1, 					-- (WIDTH-1 downto 0) 
				B  => alu_in2, 					-- (WIDTH-1 downto 0)
				OP_sel  => ALUcontrol_TO_ALU, -- (4 downto 0)
				IR  => IR50, 							-- (5 DOWNTO 0)
				result  => RESULT, 				-- (WIDTH-1 downto 0)
				result_HI  => RESULT_HI, 		-- (WIDTH-1 DOWNTO 0)
				branch_taken  => BRANCH_TAKEN	-- std_logic
		);	
	
	LO : ENTITY work.REG
	GENERIC MAP (WIDTH => 32)
		PORT MAP (
			CLK => CLK, 
         rst => rst,  
         en => LO_EN, 
         data_in => RESULT, 
         data_out => LO_TO_MUX		
		);
	
	HI : ENTITY work.REG
	GENERIC MAP (WIDTH => 32)
		PORT MAP (
			CLK => CLK, 
         rst => rst,  
         en => HI_EN, 
         data_in => RESULT_HI, 
         data_out => HI_TO_MUX		
		);
		
	ALUOUT : ENTITY WORK.REG
		GENERIC MAP (WIDTH => 32)
			PORT MAP (
				CLK => CLK, 
				rst => rst,  
				en => '1', 
				data_in => RESULT, 
				data_out => ALU_OUT
			
			);
	
	MUX_PC : ENTITY work.MUX3TO1
		GENERIC MAP (WIDTH => 32)
		PORT MAP (
			en => '1',
			w0 => RESULT,
			w1 => ALU_OUT, 
			W2 => CONCAT_MUX,
			s => PCSource,
			f => MUX_TO_PC
		);
	
	MUX_WRDATA_MUX : ENTITY work.MUX3TO1
		GENERIC MAP (WIDTH => 32)
		PORT MAP (
			en => '1',
			w0 => ALU_OUT,
			w1 => LO_TO_MUX, 
			W2 => HI_TO_MUX,
			s => ALU_LO_HI ,
			f => MUX_TO_MUX_WRDATA 		
		);
	
		
END STR;