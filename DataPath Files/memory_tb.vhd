LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY memory_tb IS
END memory_tb;

ARCHITECTURE behavior OF memory_tb IS 

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT memory
    PORT(
         clk : IN  std_logic;
         baddr : IN  std_logic_vector(31 downto 0);
         dataIN : IN  std_logic_vector(31 downto 0);
         memREAD : IN  std_logic;
         memWRITE : IN  std_logic;
         dataOUT : OUT  std_logic_vector(31 downto 0);
         INPORT0 : IN  std_logic_vector(8 downto 0);
         INPORT1 : IN  std_logic_vector(8 downto 0);
         INPORT_SEL : IN  std_logic;
         OUTPORT1 : OUT  std_logic_vector(6 downto 0);
         OUTPORT2 : OUT  std_logic_vector(6 downto 0);
         OUTPORT3 : OUT  std_logic_vector(6 downto 0);
         OUTPORT4 : OUT  std_logic_vector(6 downto 0)
        );
    END COMPONENT;

   --Inputs
   signal clk : std_logic := '0';
   signal baddr : std_logic_vector(31 downto 0) := (others => '0');
   signal dataIN : std_logic_vector(31 downto 0) := (others => '0');
   signal memREAD : std_logic := '0';
   signal memWRITE : std_logic := '0';
   signal INPORT0 : std_logic_vector(8 downto 0) := (others => '0');
   signal INPORT1 : std_logic_vector(8 downto 0) := (others => '0');
   signal INPORT_SEL : std_logic := '0';

   --Outputs
   signal dataOUT : std_logic_vector(31 downto 0);
   signal OUTPORT1 : std_logic_vector(6 downto 0);
   signal OUTPORT2 : std_logic_vector(6 downto 0);
   signal OUTPORT3 : std_logic_vector(6 downto 0);
   signal OUTPORT4 : std_logic_vector(6 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
   uut: memory PORT MAP (
          clk => clk,
          baddr => baddr,
          dataIN => dataIN,
          memREAD => memREAD,
          memWRITE => memWRITE,
          dataOUT => dataOUT,
          INPORT0 => INPORT0,
          INPORT1 => INPORT1,
          INPORT_SEL => INPORT_SEL,
          OUTPORT1 => OUTPORT1,
          OUTPORT2 => OUTPORT2,
          OUTPORT3 => OUTPORT3,
          OUTPORT4 => OUTPORT4
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- Write 0x0A0A0A0A to byte address 0x00000000
      baddr <= x"00000000";
      dataIN <= x"0A0A0A0A";
      memWRITE <= '1';
      wait for clk_period;
      memWRITE <= '0';
      wait for clk_period;

      -- Write 0xF0F0F0F0 to byte address 0x00000004
      baddr <= x"00000004";
      dataIN <= x"F0F0F0F0";
      memWRITE <= '1';
      wait for clk_period;
      memWRITE <= '0';
      wait for clk_period;

      -- Read from byte address 0x00000000
      baddr <= x"00000000";
      memREAD <= '1';
      wait for clk_period;
      memREAD <= '0';
      wait for clk_period;

      -- Read from byte address 0x00000001
      baddr <= x"00000001";
      memREAD <= '1';
      wait for clk_period;
      memREAD <= '0';
      wait for clk_period;

      -- Read from byte address 0x00000004
      baddr <= x"00000004";
      memREAD <= '1';
      wait for clk_period;
      memREAD <= '0';
      wait for clk_period;

      -- Read from byte address 0x00000005
      baddr <= x"00000005";
      memREAD <= '1';
      wait for clk_period;
      memREAD <= '0';
      wait for clk_period;

      -- Write 0x00001111 to the outport
      dataIN <= x"00001111";
      memWRITE <= '1';
      wait for clk_period;
      memWRITE <= '0';
      wait for clk_period;

      -- Load 0x00010000 into inport 0
      INPORT0 <= "000010000";
      wait for clk_period;

      -- Load 0x00000001 into inport 1
      INPORT1 <= "000000001";
      wait for clk_period;

      -- Read from inport 0
      INPORT_SEL <= '0';
      baddr <= x"0000FFF8"; -- Assuming this is the address for inport 0
      memREAD <= '1';
      wait for clk_period;
      memREAD <= '0';
      wait for clk_period;

      -- Read from inport 1
      INPORT_SEL <= '1';
      baddr <= x"0000FFFC"; -- Assuming this is the address for inport 1
      memREAD <= '1';
      wait for clk_period;
      memREAD <= '0';
      wait for clk_period;

      wait;
   end process;

END behavior;
