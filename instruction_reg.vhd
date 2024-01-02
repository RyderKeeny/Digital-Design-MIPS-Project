library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity INTRUCTION_REGISTER IS 
    Generic (WIDTH : natural := 32); --MEMORY OUTPUT 31-0
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC; 
			  IRWrite : IN STD_LOGIC; 
           data_in : in STD_LOGIC_VECTOR(WIDTH-1 downto 0); -- FROM THE MEMORY OUTPUT
			
			  data_out1 : out STD_LOGIC_VECTOR(25 downto 0);
			  data_out2 : out STD_LOGIC_VECTOR(5 downto 0);
           data_out3 : out STD_LOGIC_VECTOR(4 downto 0);
           data_out4 : out STD_LOGIC_VECTOR(4 downto 0);
           data_out5 : out STD_LOGIC_VECTOR(4 downto 0);
           data_out6 : out STD_LOGIC_VECTOR(15 downto 0)
);
end INTRUCTION_REGISTER;

architecture Behavioral of INTRUCTION_REGISTER is
    signal tempdata : STD_LOGIC_VECTOR(WIDTH-1 downto 0) := (others => '0');  -- Initialization
begin
    process(clk)
        begin
            if rising_edge(clk) then
                if rst = '1' then
                    tempdata <= (others => '0'); 
               
					elsif IRWrite = '1' then
                    tempdata <= data_in;
						  
                end if;
            end if;
    end process;
		DATA_OUT1 <= tempdata(25 downto 0);
		DATA_OUT2 <= tempdata(31 downto 26);
		DATA_OUT3 <= tempdata(25 downto 21);
		DATA_OUT4 <= tempdata(20 downto 16);
		DATA_OUT5 <= tempdata(15 downto 11);
		DATA_OUT6 <= tempdata(15 downto 0);	 
	 
end Behavioral;
