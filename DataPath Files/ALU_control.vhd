library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ALU_CONTROL IS 
    PORT(
        IR1 : in std_logic_vector(5 downto 0); -- OPcode [31-26]
        IR2 : in std_logic_vector(5 downto 0); -- R_TYPE [5-0]
        aluOP : in std_logic_vector(1 DOWNTO 0);
        op_sel : out std_logic_vector(4 downto 0);
        HI_EN : OUT STD_LOGIC;
        LO_EN : OUT STD_LOGIC;
        ALU_LO_HI : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );      
END ALU_CONTROL;

ARCHITECTURE STR OF ALU_CONTROL IS 
BEGIN
    PROCESS(IR1, IR2, aluOP)
    BEGIN
        -- Default values
        op_sel <= "00000"; -- Default operation code
        HI_EN <= '0';
        LO_EN <= '0';
        ALU_LO_HI <= "00";

         IF aluOP = "00" THEN -- LW and SW operations 
				IF IR1 <= "100011" THEN
					op_sel <= "10111"; -- LW
				ELSIF IR1 <= "101011" THEN
					op_sel <= "11000"; -- SW				
				END IF;

			ELSIF aluOP = "10" THEN -- R-type operations
            CASE IR2 IS 
                WHEN "100001" => 
                    op_sel <= "00000"; -- ADD - unsigned
                WHEN "100011" =>
                    op_sel <= "00001"; -- SUB - unsigned
                WHEN "000000" =>
                    op_sel <= "00110"; -- SLL - shift left logical
                WHEN "000010" =>
                    op_sel <= "00100"; -- SRL - shift right logical
                WHEN "000011" =>
                    op_sel <= "00101"; -- SRA - shift right arithmetic
                WHEN "101010" => 
                    op_sel <= "01111"; -- SLT - set on less than signed
                WHEN "101011" => 
                    op_sel <= "01101"; -- SLTU - set on less than unsigned
                WHEN "011000" =>
                    op_sel <= "00010"; -- MULT - signed multiplication
                    HI_EN <= '1';
                    LO_EN <= '1';

				    WHEN "011001" =>
                    op_sel <= "00011"; -- MULTU - unsigned multiplication
                    HI_EN <= '1';
                    LO_EN <= '1';

					 WHEN "010000" =>
                    -- MFHI - move from Hi
                    HI_EN <= '1';
						  
                WHEN "010010" =>
                    -- MFLO - move from LO
                    LO_EN <= '1';
                WHEN OTHERS => 
                    op_sel <= "11111"; -- Invalid R-type operation
            END CASE;
        ELSE 
            CASE IR1 IS -- I-type instructions and others
                WHEN "001001" => 
                    op_sel <= "11100"; -- ADDI - add immediate unsigned
                WHEN "001100" =>
                    op_sel <= "01000"; -- ANDI
                WHEN "001101" =>
                    op_sel <= "01010"; -- ORI
                WHEN "001110" =>
                    op_sel <= "01100"; -- XORI
                WHEN "000100" =>
                    op_sel <= "01110"; -- BEQ - branch on equal
                WHEN "000101" =>
                    op_sel <= "01111"; -- BNE - branch not equal
                WHEN "000110" =>
                    op_sel <= "01111"; -- BNE - Branch on Less Than or Equal to Zero
                WHEN "000111" =>
                    op_sel <= "01111"; -- BNE - branch GREATER THAN ZERO
                WHEN "000001" =>
                    op_sel <= "01111"; -- BNE - branch nLESS THAN OR EQUAL TO 0						  
                WHEN "000010" =>
						OP_SEL <= "10000"; -- JUMP TO ADDRESS
                WHEN "000011" =>
						OP_SEL <= "10001"; -- JUMP AND LINK
					 WHEN "000000" => 
						OP_SEL <= "10010"; -- JUMP REG
						
						  WHEN OTHERS => 
                    op_sel <= "11111"; -- Invalid opcode
            END CASE;
        END IF;
    END PROCESS;
END STR;
