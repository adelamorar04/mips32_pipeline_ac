library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.ALL;

entity EX is
    Port ( rd1 : in STD_LOGIC_VECTOR (31 downto 0);
           ALUsrc : in STD_LOGIC;
           rd2 : in STD_LOGIC_VECTOR (31 downto 0);
           ext_imm : in STD_LOGIC_VECTOR (31 downto 0);
           sa : in STD_LOGIC_VECTOR (4 downto 0);
           func : in STD_LOGIC_VECTOR (5 downto 0);
           ALUop : in STD_LOGIC_VECTOR (1 downto 0);
           PC_4 : in STD_LOGIC_VECTOR (31 downto 0);
           rt: in STD_LOGIC_VECTOR (4 downto 0); -- adaugat
           rd: in STD_LOGIC_VECTOR (4 downto 0); -- adaugat
           RegDst: in STD_LOGIC; -- adaugat
           zero : out STD_LOGIC;
           ALUres : out STD_LOGIC_VECTOR (31 downto 0);
           nequal : out STD_LOGIC;
           BranchAdress : out STD_LOGIC_VECTOR (31 downto 0);
           rWA: out STD_LOGIC_VECTOR (4 downto 0));-- adaugat
end EX;

architecture Behavioral of EX is

signal B: std_logic_vector(31 downto 0) := (others => '0');
signal C: std_logic_vector(31 downto 0) := (others => '0');
signal ALUctrl : std_logic_vector(2 downto 0) := (others => '0');

begin

--multiplexorul
B <= rd2 when ALUsrc = '0' else ext_imm;
BranchAdress <= (ext_imm(29 downto 0) & "00") + PC_4;

ALUControl: process(ALUop, func)
begin
    case ALUop is
        when "10" =>
            case func is
                when "100000" => ALUctrl <= "000";
                when "100010" => ALUctrl <= "100";
                when "000000" => ALUctrl <= "011";
                when "000010" => ALUctrl <= "101";
                when "100100" => ALUctrl <= "001";
                when "100101" => ALUctrl <= "010";
                when "000011" => ALUctrl <= "110";
                when "100110" => ALUctrl <= "111";
                when others => ALUctrl <="XXX";
            end case;
         when "00" => ALUctrl <= "000";
         when "01" => ALUctrl <= "100";
         when "11" => ALUctrl <= "010";
         when others => ALUctrl <= (others => '0');
    end case;
end process;

ALU: process(ALUctrl,rd1, B, sa)
begin
    --semnalele de branch
    zero <= '0';
    nequal <= '0';
    case ALUctrl is
    when "000" => C <= rd1 + B;
    when "100" => 
        C <= rd1 - B;
        if rd1 - B = X"00000000" then
            zero <= '1';
        else nequal <= '1';
        end if;
    when "011" => C <= to_stdlogicvector(to_bitvector(B) sll conv_integer(sa));
    when "101" => C <= to_stdlogicvector(to_bitvector(B) srl conv_integer(sa));
    when "001" => C <= rd1 and B;
    when "010" => C <= rd1 or B;
    when "110" => C <= to_stdlogicvector(to_bitvector(B) sra conv_integer(sa));
    when "111" => C <= rd1 xor B;
    when others => C <= (others => 'X');
    end case;
end process;

ALUres <= C;

--multiplexorul de jos
rWA <= rt when RegDst = '0' else rd;

end Behavioral;
