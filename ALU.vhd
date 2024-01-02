library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is

	generic (WIDTH : positive := 32);
	port (
		A : in std_logic_vector(WIDTH-1 downto 0); 
		B: in std_logic_vector(WIDTH-1 downto 0);
		OP_sel : in std_logic_vector(4 downto 0);
		IR : in std_logic_vector(5 DOWNTO 0); -- shift amount IR (10-6)
		result : out std_logic_vector(WIDTH-1 downto 0);
		result_HI : out std_logic_vector(WIDTH-1 DOWNTO 0);
		branch_taken : out std_logic
	);

end alu;

ARCHITECTURE STR OF alu IS
	signal add, diff : unsigned(WIDTH-1 DOWNTO 0);
	signal mult_unsigned : unsigned((2*WIDTH)-1 DOWNTO 0);
	signal mult_signed : signed((2*WIDTH)-1 DOWNTO 0);
	signal temp_IR : unsigned(5 downto 0);
	
	

BEGIN


	PROCESS (OP_sel, A, B, temp_IR, IR, add, diff, mult_signed, mult_unsigned)	
	BEGIN	
	
		temp_IR <= unsigned(IR);
		
		add <= unsigned(A) + unsigned(B) ;
		mult_unsigned <= unsigned(A) * unsigned(B);
		mult_signed <= signed(unsigned(A) * unsigned(B));
		diff <= unsigned(A) - unsigned(B) ;
		
		--result <= (others => '0');
		--result_HI <= (others => '0');
		branch_taken <= '0';
		
		
		CASE OP_sel is 
			WHEN "00000" => --addition
				result <= STD_LOGIC_VECTOR(add(width-1 downto 0));
			WHEN "00001" => --subtraction
				result <= std_logic_vector(diff(width-1 downto 0));
			WHEN "00010" => -- signed multiplication
				result <= std_logic_vector(mult_signed(WIDTH-1 DOWNTO 0));
				result_HI <= std_logic_vector(mult_signed((WIDTH*2)-1 DOWNTO WIDTH));
			WHEN "00011" => -- unsigned multiplication 
				result <= std_logic_vector(mult_unsigned(WIDTH-1 DOWNTO 0));
				result_HI <= std_logic_vector(mult_unsigned((WIDTH*2)-1 DOWNTO WIDTH));
			WHEN "00100" => -- logical shift Right of A by IR value
				result <= std_logic_vector(shift_right(unsigned(A), to_integer(temp_IR)));
			WHEN "00101" => -- Arithmic shift Right of A by IR value
				result <= std_logic_vector(shift_right(signed(A), to_integer(temp_IR)));
			WHEN "00110" => -- logical shift LEFT of A by IR valuE
				RESULT <= std_logic_vector(shift_LEFT(unsigned(A), to_integer(temp_IR)));
			
			WHEN "00111" => -- AND operation
				result <= (A AND B);	
			WHEN "01000" => -- ANDI operation
				result <= (A AND B);
			WHEN "01001" => -- OR operation
				result <= (A AND B);
			WHEN "01010" => -- ORI operation
				result <= (A AND B);
			WHEN "01011" => -- XOR operation
				result <= (A AND B);
			WHEN "01100" => -- XORI operation
				result <= (A AND B);
			WHEN "11100" => -- ANDIS operation
				result <= (A AND B);				
				
			WHEN "01101" => -- set less than b/w A & B (unsigned)
				IF ( unsigned(A) < unsigned(B) ) THEN
					result <= (0 => '1', others => '0');
				ELSE 
					result <= (others => '0');
				END IF;
			
			WHEN "01110" => -- set less than  than immediate b/w A & B (unsigned)
				IF ( unsigned(A) < unsigned(B) ) THEN
					result <= (0 => '1', others => '0');
				ELSE 
					result <= (others => '0');
				END IF;
			
			WHEN "01111" => -- set less than than immediate  b/w A & B (signed)
				IF ( unsigned(A) < unsigned(B) ) THEN
					result <= (0 => '1', others => '0');
				ELSE 
					result <= (others => '0');
				END IF;	
		
			WHEN "10000" => -- set less than b/w A & B (signed)
				IF ( signed(A) < signed(B) ) THEN
					result <= (0 => '1', others => '0');
				ELSE 
					result <= (others => '0');
				END IF;
				
			WHEN "10001" =>  -- Branch_taken output BRANCH LESS THAN OR EQUAL
				IF ( signed(A) <= signed(B) )  THEN
					Branch_taken <= '1';
				ELSE 
					Branch_taken <= '0';
				END IF;
			WHEN "10010" => -- BRANCH GREATER THAN ZERO
				IF ( signed(A) > SIGNED(B) ) THEN 
					Branch_taken <= '1';
				ELSE
					Branch_taken <= '0';
				END IF;	
			WHEN "10011" => -- BRANCH ON EQUAL
				IF ( signed(A) = SIGNED(B) ) THEN 
					Branch_taken <= '1';
				ELSE
					Branch_taken <= '0';
				END IF;			
			WHEN "10100" => -- BRANCH ON NOT EQUAL
				IF ( signed(A) /= SIGNED(B) ) THEN 
					Branch_taken <= '1';
				ELSE
					Branch_taken <= '0';
				END IF;			
			WHEN "10101" => -- BRANCH LESS THAN ZERO
				IF ( signed(A) < SIGNED(B) ) THEN 
					Branch_taken <= '1';		
				ELSIF ( signed(A) >= SIGNED(B) ) THEN -- BRANCH ON GREATER THAN OR EQUAL TO ZERO
					Branch_taken <= '1';
				
				ELSE
					Branch_taken <= '0';
				END IF;	
				
			WHEN "10111" => -- LW, Load Word effective address calculation
				RESULT <= STD_LOGIC_VECTOR(add); -- Effective address computation is just an addition
			
			WHEN "11000" => -- SW, Store Word effective address calculation
				RESULT <= STD_LOGIC_VECTOR(add(WIDTH-1 DOWNTO 0)); -- Effective address computation is just an addition					
			
			WHEN "11001" => -- JUMP TO ADDRESS
				RESULT <= ("000000" & A(25 DOWNTO 0) ); 
			WHEN "11010" => -- JUMP AND LINK
				RESULT <= STD_LOGIC_VECTOR(unsigned(A) + 4);
			WHEN "11011" => -- JMP REG
				RESULT <= A;

			WHEN OTHERS => 
				result <= (others => '0');
				result_HI <= (others => '0');
		
		
		
		END CASE;
		
	END PROCESS;

	
END STR;