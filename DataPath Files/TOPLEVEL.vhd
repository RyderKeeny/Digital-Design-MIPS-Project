library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY TOPLEVEL IS
    PORT (
        CLK : IN std_logic;
        RST : IN std_logic;
        SWITCHES : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        BUTTON : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        MemoryDataToLED1 : OUT std_logic_vector(6 DOWNTO 0); 
        MemoryDataToLED2 : OUT std_logic_vector(6 DOWNTO 0); 
        MemoryDataToLED3 : OUT std_logic_vector(6 DOWNTO 0); 
        MemoryDataToLED4 : OUT std_logic_vector(6 DOWNTO 0)
    );
END TOPLEVEL;

ARCHITECTURE behavior OF TOPLEVEL IS
    SIGNAL PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemToReg, IRWrite : std_logic;
    SIGNAL JandL, isSigned, ALUSrcA : std_logic;
    SIGNAL PCSource, ALUOp : std_logic_vector(1 downto 0);
    SIGNAL ALUSrcB : std_logic_vector(1 downto 0);    
    SIGNAL RegWrite, RegDst : std_logic;
	 SIGNAL Instruction_31_26 : std_logic_vector(5 DOWNTO 0);

    
BEGIN
    ctrl: ENTITY work.CONTROLLER
        PORT MAP (
            clk => CLK,
            rst => RST,
            IR => Instruction_31_26,
            PCWriteCond => PCWriteCond,
            PCWrite => PCWrite,
            IorD => IorD,
            MemRead => MemRead,
            MemWrite => MemWrite,
            MemToReg => MemToReg,
            IRWrite => IRWrite,
            JandL => JandL,
            isSigned => isSigned,
            PCSource => PCSource,
            ALUOp => ALUOp,
            ALUSrcA => ALUSrcA,
            ALUSrcB => ALUSrcB,
            RegWrite => RegWrite,
            RegDst => RegDst
        );

    -- Instantiate the DATAPATH
    datapth: ENTITY work.DATAPATH
        PORT MAP (
            CLK => CLK,
            RST => RST,
            SWITCHES => SWITCHES,
            BUTTON => BUTTON,
            PCWriteCond => PCWriteCond,
            PCWrite => PCWrite,
            IorD => IorD,
            MemRead => MemRead,
            MemWrite => MemWrite,
            MemtoReg => MemToReg,
            IRWrite => IRWrite,
            PCSource => PCSource,
            ALUOp => ALUOp,
            ALUSrcB => ALUSrcB,
            ALUSrcA => ALUSrcA, -- Assuming ALUSrcA is only one bit based on DATAPATH entity
            RegWrite => RegWrite,
            RegDst => RegDst,
            JandL => JandL,
            isSigned => isSigned,
            MemoryDataToLED1 => MemoryDataToLED1,
            MemoryDataToLED2 => MemoryDataToLED2,
            MemoryDataToLED3 => MemoryDataToLED3,
            MemoryDataToLED4 => MemoryDataToLED4,
            Instruction_31_26 => Instruction_31_26
        );

END behavior;