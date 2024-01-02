LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all; 

ENTITY MUX IS
    GENERIC (WIDTH : positive := 8);  -- Added width as a generic
    PORT (
        en : IN std_logic;
        w0, w1 : IN std_logic_vector(WIDTH-1 downto 0);
        s : IN std_logic;
        f : OUT std_logic_vector(WIDTH-1 downto 0)
    );
END MUX;

ARCHITECTURE behavior OF MUX IS
BEGIN
    PROCESS(en, w0, w1, s)
    BEGIN
        if en = '1' then
            if s = '0' then
                f <= w0;
            else
                f <= w1;
            end if;
        else
            f <= (others => '0');  
        end if;
    END PROCESS;
END behavior;

