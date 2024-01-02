LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all; 

ENTITY MUX3TO1 IS
    GENERIC (WIDTH : positive := 8);  -- Added width as a generic
    PORT (
        en : IN std_logic;
        w0, w1, W2 : IN std_logic_vector(WIDTH-1 downto 0);
        s : IN std_logic_VECTOR(1 DOWNTO 0);
        f : OUT std_logic_vector(WIDTH-1 downto 0)
    );
END MUX3TO1;

ARCHITECTURE behavior OF MUX3TO1 IS
BEGIN
    PROCESS(en, w0, w1, W2, s)
    BEGIN
        if en = '1' then
            if s = "00" then
                f <= w0;
            elsIF S = "01" THEN
                f <= w1;
            ELSIF S = "10" THEN
					 F <= W2;
				
				end if;
        else
            f <= (others => '0');  
        end if;
    END PROCESS;
END behavior;

