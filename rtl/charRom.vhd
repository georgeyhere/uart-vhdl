library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity charRom is 
generic(
    ROM_ADDR_WIDTH : integer := 5
);
port(
    i_clk  : in  std_logic;
    --
    i_addr : in  integer range 0 to 2**ROM_ADDR_WIDTH-1; -- 5 bit address
    o_dout : out std_logic_vector (7 downto 0)
);
end charRom;

architecture Behavioral of charRom is 
    
    function charToSlv 
        (charIn : in character) 
        return std_logic_vector is
    begin
        return std_logic_vector(to_unsigned(character'pos(charIn), 8));
    end function charToSlv;


begin
    DOUT: process(i_clk) 
    begin
        if rising_edge(i_clk) then
            case i_addr is
                when 0 =>
                    o_dout <= charToSlv('H');
                when 1 =>
                    o_dout <= charToSlv('e');
                when 2 =>
                    o_dout <= charToSlv('l');
                when 3 =>
                    o_dout <= charToSlv('l');
                when 4 =>
                    o_dout <= charToSlv('o');
                when 5 => 
                    o_dout <= charToSlv(' ');
                when 6 =>
                    o_dout <= charToSlv('F');
                when 7 =>
                    o_dout <= charToSlv('P');
                when 8 =>
                    o_dout <= charToSlv('G');
                when 9 =>
                    o_dout <= charToSlv('A');
                when 10 =>
                    o_dout <= charToSlv(' ');
                when 11 =>
                    o_dout <= charToSlv('W');
                when 12 =>
                    o_dout <= charToSlv('o');
                when 13 =>
                    o_dout <= charToSlv('r');
                when 14 =>
                    o_dout <= charToSlv('l');
                when 15 =>
                    o_dout <= charToSlv('d');
                when 16 =>
                    o_dout <= charToSlv('!');
                when 30 =>
                    o_dout <= "00001010";
                when 31 =>
                    o_dout <= "00001101";
                when others =>
                    o_dout <= charToSlv(' ');
            end case;
        end if;
    end process;

end Behavioral;