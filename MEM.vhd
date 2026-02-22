library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity MEM is
    Port ( MemWrite : in STD_LOGIC;
           ALUresIN : in STD_LOGIC_VECTOR (31 downto 0);
           rd2 : in STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC;
           en : in STD_LOGIC;
           MemData : out STD_LOGIC_VECTOR (31 downto 0);
           ALUresOUT : out STD_LOGIC_VECTOR (31 downto 0));
end MEM;

architecture Behavioral of MEM is

type matrix is array (0 to 63) of std_logic_vector(31 downto 0);
signal MEM : matrix := (
X"00000004", X"00000003",X"00000002", X"00000008",X"00000007",
others => (others => '0'));

begin

process(clk)
begin
    if rising_edge(clk) then
        if en = '1' and MemWrite = '1' then
            MEM(conv_integer(ALUresIN(7 downto 2))) <= rd2;
        end if;
    end if;
end process;

MemData <= MEM(conv_integer(ALUresIN(7 downto 2)));

ALUresOUT <= ALUresIN;


end Behavioral;
