library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SSD is
    Port ( clk : in STD_LOGIC;
           digits: in STD_LOGIC_VECTOR (31 downto 0);
           anod : out STD_LOGIC_VECTOR (7 downto 0);
           cat :out STD_LOGIC_VECTOR (6 downto 0));
end SSD;

architecture Behavioral of SSD is
--declarare de semnale
signal nr: std_logic_vector(16 downto 0) := (others => '0'); -- iesirea din numarator
signal sel: std_logic_vector(2 downto 0) := (others => '0'); -- selectie pentru multimplexoare
signal digit : std_logic_vector (3 downto 0) := (others => '0'); -- iesirea din mux-ul 8 : 1

begin

-- numarator cu iesire pe 17 biti
process(clk)
begin
    if rising_edge(clk) then
        nr <= nr + 1;
    end if;
end process;

sel <= nr(16 downto 14);

-- multiplexor 8 : 1 pentru activarea anozilor
process(digits, sel)
begin
    case sel is
        when "000" => digit <= digits(3 downto 0);
        when "001" => digit <= digits(7 downto 4);
        when "010" => digit <= digits(11 downto 8);
        when "011" => digit <= digits(15 downto 12);
        when "100" => digit <= digits(19 downto 16);
        when "101" => digit <= digits(23 downto 20);
        when "110" => digit <= digits(27 downto 24);
        when others => digit <= digits (31 downto 28);
    end case;
end process;

--multiplexorul 8 : 1 pentru activarea catozilor
process(sel)
begin
    case sel is
        when "000" => anod <= "11111110";
        when "001" => anod <= "11111101";
        when "010" => anod <= "11111011";
        when "011" => anod <= "11110111";
        when "100" => anod <= "11101111";
        when "101" => anod <= "11011111";
        when "110" => anod <= "10111111";
        when others => anod <= "01111111";
    end case;
end process;

--decodificator hexa la 7segments
with digit SELect
cat <= "1111001" when "0001",   --1
       "0100100" when "0010",   --2
       "0110000" when "0011",   --3
       "0011001" when "0100",   --4
       "0010010" when "0101",   --5
       "0000010" when "0110",   --6
       "1111000" when "0111",   --7
       "0000000" when "1000",   --8
       "0010000" when "1001",   --9
       "0001000" when "1010",   --A
       "0000011" when "1011",   --b
       "1000110" when "1100",   --C
       "0100001" when "1101",   --d
       "0000110" when "1110",   --E
       "0001110" when "1111",   --F
       "1000000" when others;   --0



end Behavioral;
