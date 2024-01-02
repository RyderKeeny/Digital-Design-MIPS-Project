library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reg is
    Generic (WIDTH : natural := 9); -- 9 SWITCHES
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC; 
           en : in STD_LOGIC;
           data_in : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
           data_out : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
end reg;

architecture Behavioral of reg is
    signal tempdata : STD_LOGIC_VECTOR(WIDTH-1 downto 0) := (others => '0');  -- Initialization
begin
    process(clk)
        begin
            if rising_edge(clk) then
                if rst = '1' then
                    tempdata <= (others => '0'); 
                elsif en = '1' then
                    tempdata <= data_in;
                end if;
            end if;
    end process;
    data_out <= tempdata;
end Behavioral;
