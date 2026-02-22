library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity instrDecode is
    Port ( clk : in STD_LOGIC;
           RegWrite : in STD_LOGIC;
           Instr : in STD_LOGIC_VECTOR (25 downto 0);
           WA : in STD_LOGIC_VECTOR (4 downto 0); -- adaugat in plus si scos RegDst
           en : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           rd1 : out STD_LOGIC_VECTOR (31 downto 0);
           rd2 : out STD_LOGIC_VECTOR (31 downto 0);
           wd : in STD_LOGIC_VECTOR (31 downto 0);
           ext_imm : out STD_LOGIC_VECTOR (31 downto 0);
           func : out STD_LOGIC_VECTOR (5 downto 0);
           sa : out STD_LOGIC_VECTOR (4 downto 0);
           rt: out STD_LOGIC_VECTOR (4 downto 0); -- adaugat
           rd: out STD_LOGIC_VECTOR (4 downto 0) ); --adaugat
end instrDecode;

architecture Behavioral of instrDecode is

--semnale pentru reg file
type t_mem is array (0 downto 31) of std_logic_vector(31 downto 0);
signal reg_file: t_mem := (others => (others => '0'));

begin

--register file
process(clk)
begin
    if falling_edge(clk) then -- schimbat pe falling edge
        if en = '1' and RegWrite = '1' then
            reg_file(conv_integer(WA)) <= wd; 
        end if;
    end if;
end process;

rd1 <= reg_file(conv_integer(Instr(25 downto 21)));
rd2 <= reg_file(conv_integer(Instr(20 downto 16)));

--exitndere
ext_imm(15 downto 0) <= Instr(15 downto 0);
ext_imm(31 downto 16) <= (others => Instr(15)) when ExtOp = '1' else (others => '0');

func <= Instr(5 downto 0);
sa <= Instr(10 downto 6);

--rt si rd (NOU)
rt <= Instr(20 downto 16);
rd <= Instr(15 downto 11);

end Behavioral;
