library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity alu_tb is
END alu_tb;



architecture TB of alu_tb is

	component alu
		generic (WIDTH : positive := 32);
		port ( 
				A : in std_logic_vector(WIDTH-1 downto 0); 
				B: in std_logic_vector(WIDTH-1 downto 0);
				OP_sel : in std_logic_vector(4 downto 0);
				IR : in std_logic_vector(4 DOWNTO 0); -- shift amount IR (10-6)
				result : out std_logic_vector(WIDTH-1 downto 0);
				result_HI : out std_logic_vector(WIDTH-1 DOWNTO 0);
				branch_taken : out std_logic 
		);
	end component;

		constant WIDTH : positive := 32;
		signal A : std_logic_vector(WIDTH-1 downto 0); 
		signal B: std_logic_vector(WIDTH-1 downto 0);
		signal OP_sel : std_logic_vector(4 downto 0);
		signal IR : std_logic_vector(4 DOWNTO 0); -- shift amount IR (10-6)
		signal result : std_logic_vector(WIDTH-1 downto 0);
		signal result_HI : std_logic_vector(WIDTH-1 DOWNTO 0);
		signal branch_taken : std_logic;
		
		BEGIN --TB
		
			UUT : alu
				generic map (WIDTH => WIDTH)
				PORT MAP (
					A => A, 
					B => B,
					OP_sel => OP_sel,
					IR => IR, 
					result => result,
					result_HI => result_HI,
					branch_taken => branch_taken );
					
					
		PROCESS 
		BEGIN
			
	        -- Test Case 1: Addition 10 + 15
        A <= conv_std_logic_vector(10, WIDTH);
        B <= conv_std_logic_vector(15, WIDTH);
        OP_sel <= "00000";
        wait for 20 ns;
        assert(result = conv_std_logic_vector(25, WIDTH))
        report "Addition Result: " & integer'image(conv_integer(result));

        -- Test Case 2: Subtraction 25 - 10
        A <= conv_std_logic_vector(25, WIDTH);
        B <= conv_std_logic_vector(10, WIDTH);
        OP_sel <= "00001";
        wait for 20 ns;
        assert(result = conv_std_logic_vector(15, WIDTH))
        report "Subtraction Result: " & integer'image(conv_integer(result));

	       -- Test Case 3: Signed Multiplication 10 * -4
        A <= conv_std_logic_vector(10, WIDTH);
        B <= conv_std_logic_vector(-4, WIDTH);
        OP_sel <= "00010"; -- Operation select for signed multiplication
        wait for 20 ns;
        -- Add assertions and reports here for the results

        -- Test Case 4: Unsigned Multiplication 65536 * 131072
        A <= conv_std_logic_vector(65536, WIDTH);
        B <= conv_std_logic_vector(131072, WIDTH);
        OP_sel <= "00011"; -- Operation select for unsigned multiplication
        wait for 20 ns;
        -- Add assertions and reports here for the results

        -- Test Case 5: Bitwise AND 0x0000FFFF and 0xFFFF1234
        A <= X"0000FFFF";
        B <= X"FFFF1234";
        OP_sel <= "00100"; -- Operation select for AND
        wait for 20 ns;
        -- Add assertion and report here for the result

        -- Test Case 6: Logical Right Shift of 0x0000000F by 4
        A <= X"0000000F";
        IR <= conv_std_logic_vector(4, IR'length); -- 4 in binary
        OP_sel <= "00101"; -- Operation select for logical right shift
        wait for 20 ns;
        -- Add assertion and report here for the result

        -- Test Case 7: Arithmetic Right Shift of 0xF0000008 by 1
        A <= X"F0000008";
        IR <= conv_std_logic_vector(1, IR'length); -- 1 in binary
        OP_sel <= "00110"; -- Operation select for arithmetic right shift
        wait for 20 ns;
        -- Add assertion and report here for the result

        -- Test Case 8: Arithmetic Right Shift of 0x00000008 by 1
        A <= X"00000008";
        IR <= conv_std_logic_vector(1, IR'length); -- 1 in binary
        OP_sel <= "00110"; -- Operation select for arithmetic right shift
        wait for 20 ns;
        -- Add assertion and report here for the result

        -- Test Case 9: Set on less than (10 < 15)
        A <= conv_std_logic_vector(10, WIDTH);
        B <= conv_std_logic_vector(15, WIDTH);
        OP_sel <= "00111"; -- Operation select for set less than
        wait for 20 ns;
        -- Add assertion and report here for the result

        -- Test Case 10: Set on less than (15 > 10)
        A <= conv_std_logic_vector(15, WIDTH);
        B <= conv_std_logic_vector(10, WIDTH);
        OP_sel <= "00111"; -- Operation select for set less than
        wait for 20 ns;
        -- Add assertion and report here for the result

        -- Test Case 11: Branch Taken output for 5 <= 0
        A <= conv_std_logic_vector(5, WIDTH);
        B <= conv_std_logic_vector(0, WIDTH);
        OP_sel <= "01001"; -- Operation select for branch taken (blez)
        wait for 20 ns;
        -- Add assertion and report here for the branch_taken signal

        -- Test Case 12: Branch Taken output for 5 > 0
        A <= conv_std_logic_vector(5, WIDTH);
        B <= conv_std_logic_vector(0, WIDTH);
        OP_sel <= "01001"; -- Operation select for branch taken (bgtz)
        wait for 20 ns;
        -- Add assertion and report here for the branch_taken signal
			
		  A <= conv_std_logic_vector(5, WIDTH);
        B <= conv_std_logic_vector(0, WIDTH);
        OP_sel <= "01010"; -- Operation select for branch taken (bgtz)
        wait for 20 ns;
			-- End of test cases
			report "ALU testbench completed";
			WAIT;
		END PROCESS;


END TB;

