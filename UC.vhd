library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UC is
    Port ( instr : in STD_LOGIC_VECTOR (5 downto 0);
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUsrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           Br_ne : out STD_LOGIC;
           Jump : out STD_LOGIC;
           MemWrite : out STD_LOGIC;
           MemtoReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC;
           ALUop : out STD_LOGIC_VECTOR (1 downto 0));
end UC;

architecture Behavioral of UC is

begin

process(instr)
begin
    RegDst <= '0'; ExtOp <= '0'; ALUsrc <= '0'; Branch <= '0'; Br_ne <= '0';
    Jump <= '0'; MemWrite <= '0'; MemtoReg <= '0'; RegWrite <= '0';
    ALUop <= "00";
    
    case instr is
        when "000000" => -- de tip R
            RegDst <= '1'; RegWrite <= '1';
            ALUop <= "10";
        --de tip I
        when "001000" => -- addi
            ExtOp <= '1'; ALUsrc <= '1'; RegWrite <= '1';
            --ALUop este deja 00
        when "100011" => --lw
            ExtOp <= '1'; ALUsrc <= '1'; MemtoReg <= '1';
            RegWrite <= '1'; -- ALUop este deja 00
        when "101011" => --sw
            ExtOp <= '1'; ALUsrc <= '1';
             MemWrite <= '1'; -- ALUop este deja 00
        when "000100" => --beq
            ExtOp <= '1'; Branch <= '1';
            ALUop <= "01";
        when "001101" => -- ori
            ALUsrc <= '1'; RegWrite <= '1';
            ALUop <= "11";
        when "000101" => --bne
            ExtOp <= '1'; Br_ne <= '1';
            ALUop <= "01";
        when "000010" => --jump
            Jump <= '1';
        when others => 
--            RegDst <= '0'; ExtOp <= '0'; ALUsrc <= '0'; Branch <= '0'; Br_ne <= '0';
--            Jump <= '0'; MemWrite <= '0'; MemtoReg <= '0'; RegWrite <= '0';
            ALUop <= "XX";
    end case;
end process;


end Behavioral;
