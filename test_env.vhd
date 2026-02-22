library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity test_env is
    Port ( sw : in STD_LOGIC_VECTOR (15 downto 0);
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           clk : in STD_LOGIC;
           led : out STD_LOGIC_VECTOR (15 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0));
end test_env;

architecture Behavioral of test_env is

component InstrFetch is
    Port ( jump : in STD_LOGIC;
           jumpAdress : in STD_LOGIC_VECTOR (31 downto 0);
           PCsrc : in STD_LOGIC;
           branchAdress : in STD_LOGIC_VECTOR (31 downto 0);
           en : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           PC_4 : out STD_LOGIC_VECTOR (31 downto 0);
           instruction : out STD_LOGIC_VECTOR (31 downto 0));
end component InstrFetch;

component MPG is
    Port ( enable : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component MPG;

component UC is
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
end component UC;

component instrDecode is
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
end component instrDecode;

component SSD is
    Port ( clk : in STD_LOGIC;
           digits: in STD_LOGIC_VECTOR (31 downto 0);
           anod : out STD_LOGIC_VECTOR (7 downto 0);
           cat :out STD_LOGIC_VECTOR (6 downto 0));
end component SSD;

component EX is
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
end component EX;

component MEM is
    Port ( MemWrite : in STD_LOGIC;
           ALUresIN : in STD_LOGIC_VECTOR (31 downto 0);
           rd2 : in STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC;
           en : in STD_LOGIC;
           MemData : out STD_LOGIC_VECTOR (31 downto 0);
           ALUresOUT : out STD_LOGIC_VECTOR (31 downto 0));
end component MEM;

--semnale

--iesire MPG
signal en : std_logic := '0';

--iesire iFetch
--signal instr : std_logic_vector(31 downto 0) := X"00000000";
--signal pc_4 : std_logic_vector(31 downto 0) := X"00000000";

--intrari de la iFatch
signal jumpAdress: std_logic_vector(31 downto 0) := X"00000000";
signal PCsrc : std_Logic := '0';

--iesire multiplexor
signal digits : std_logic_vector(31 downto 0) := X"00000000";



--iesirea din instr Decoder
--signal rd1 : std_logic_vector(31 downto 0) := X"00000000";
--signal rd2 : std_logic_vector(31 downto 0) := X"00000000";
--signal ext_imm : std_logic_vector(31 downto 0) := X"00000000";
--signal func : std_logic_vector(5 downto 0) := "000000";
--signal sa : std_logic_vector(4 downto 0) := "00000";

--iesiri EX
--signal zero : std_logic := '0';
--signal nequal : std_logic := '0';
--signal branchAdress : std_logic_vector(31 downto 0) := X"00000000";
--signal ALUresIN : std_logic_vector(31 downto 0) := X"00000000";

--iesiri MEM
--signal ALUresOUT : std_logic_vector(31 downto 0) := X"00000000";
--signal MemData : std_logic_vector(31 downto 0) := X"00000000";

--iesirea de la UC
--signal RegDst :  STD_LOGIC := '0';
--signal ExtOp :  STD_LOGIC := '0';
--signal ALUsrc :  STD_LOGIC := '0';
--signal Branch :  STD_LOGIC := '0';
--signal Br_ne :  STD_LOGIC := '0';
--signal Jump :  STD_LOGIC := '0';
--signal MemWrite :  STD_LOGIC := '0';
--signal MemtoReg :  STD_LOGIC := '0';
--signal RegWrite :  STD_LOGIC := '0';
--signal ALUop :  STD_LOGIC_VECTOR (1 downto 0) := "00";

--registre intermediare
signal IF_ID : std_logic_vector(63 downto 0) := (others => '0');
signal ID_EX : std_logic_vector(157 downto 0) := (others => '0');
signal EX_MEM : std_logic_vector(107 downto 0) := (others => '0');
signal MEM_WB : std_logic_vector(70 downto 0) := (others => '0');

--semnale pentru registrii
-- din reg if
signal instr_if : std_logic_vector(31 downto 0) := (others => '0');
signal pc_if : std_logic_vector(31 downto 0) := (others => '0');

--din reg id
--intrari id
signal instr_id : std_logic_vector(31 downto 0) := (others => '0');
signal pc_id : std_logic_vector(31 downto 0) := (others => '0');
--iesiri id
signal rd1_id : std_logic_vector(31 downto 0) := (others => '0');
signal rd2_id : std_logic_vector(31 downto 0) := (others => '0');
signal extimm_id : std_logic_vector(31 downto 0) := (others => '0');
signal func_id : std_logic_vector(5 downto 0) := (others => '0');
signal sa_id : std_logic_vector(4 downto 0) := (others => '0');
signal rd_id : std_logic_vector(4 downto 0) := (others => '0');
signal rt_id : std_logic_vector(4 downto 0) := (others => '0');
--iesiri UC
signal RegDst_id :  STD_LOGIC := '0';
signal ExtOp :  STD_LOGIC := '0'; -- nu intra in registrul intermediar
signal ALUsrc_id :  STD_LOGIC := '0';
signal Branch_id :  STD_LOGIC := '0';
signal Br_ne_id :  STD_LOGIC := '0';
signal Jump :  STD_LOGIC := '0'; -- nu intra in registrul intermediar
signal MemWrite_id :  STD_LOGIC := '0';
signal MemtoReg_id :  STD_LOGIC := '0';
signal RegWrite_id :  STD_LOGIC := '0';
signal ALUop_id :  STD_LOGIC_VECTOR (1 downto 0) := "00";

--din reg ex
--intrari ex
signal pc_ex : std_logic_vector(31 downto 0) := (others => '0');
signal rd1_ex : std_logic_vector(31 downto 0) := (others => '0');
signal rd2_ex : std_logic_vector(31 downto 0) := (others => '0');
signal extimm_ex : std_logic_vector(31 downto 0) := (others => '0');
signal func_ex : std_logic_vector(5 downto 0) := (others => '0');
signal sa_ex : std_logic_vector(4 downto 0) := (others => '0');
signal rd_ex : std_logic_vector(4 downto 0) := (others => '0');
signal rt_ex : std_logic_vector(4 downto 0) := (others => '0');
signal RegDst_ex :  STD_LOGIC := '0';
signal ALUsrc_ex :  STD_LOGIC := '0';
signal Branch_ex :  STD_LOGIC := '0';
signal Br_ne_ex :  STD_LOGIC := '0';
signal MemWrite_ex :  STD_LOGIC := '0';
signal MemtoReg_ex :  STD_LOGIC := '0';
signal RegWrite_ex :  STD_LOGIC := '0';
signal ALUop_ex :  STD_LOGIC_VECTOR (1 downto 0) := "00";

--iesiri ex
signal zero_ex : std_logic := '0';
signal nequal_ex : std_logic := '0';
signal branchAdress_ex : std_logic_vector(31 downto 0) := X"00000000";
signal ALUresIN_ex : std_logic_vector(31 downto 0) := X"00000000";
signal rWA_ex: std_logic_vector(4 downto 0) := (others => '0');

--din reg mem
--intrare mem
signal zero_mem : std_logic := '0';
signal nequal_mem : std_logic := '0';
signal branchAdress_mem : std_logic_vector(31 downto 0) := X"00000000";
signal ALUresIN_mem : std_logic_vector(31 downto 0) := X"00000000";
signal rWA_mem: std_logic_vector(4 downto 0) := (others => '0');
signal rd2_mem : std_logic_vector(31 downto 0) := (others => '0');
signal Branch_mem :  STD_LOGIC := '0';
signal Br_ne_mem :  STD_LOGIC := '0';
signal MemWrite_mem :  STD_LOGIC := '0';
signal MemtoReg_mem :  STD_LOGIC := '0';
signal RegWrite_mem :  STD_LOGIC := '0';
signal wa_mem: std_logic_vector(4 downto 0) := (others => '0');
--iesire mem
signal ALUresOUT_mem : std_logic_vector(31 downto 0) := X"00000000";
signal MemData_mem : std_logic_vector(31 downto 0) := X"00000000";

--din reg wb
signal ALUresOUT_wb : std_logic_vector(31 downto 0) := X"00000000";
signal MemData_wb : std_logic_vector(31 downto 0) := X"00000000";
signal MemtoReg_wb :  STD_LOGIC := '0';
signal RegWrite_wb :  STD_LOGIC := '0';
--iesire multiplexor 
signal wd_wb : std_logic_vector(31 downto 0) := X"00000000";
signal wa_wb: std_logic_vector(4 downto 0) := (others => '0');


begin

C1: MPG port map (en, btn(0), clk);

--jump adress
jumpAdress <= pc_id(31 downto 28) & instr_id(25 downto 0)& "00";
--PCsrc este un sau intre branch si br_ne
PCsrc <= (zero_mem and Branch_mem) or (nequal_mem and Br_ne_mem);  
C2: InstrFetch port map (Jump, jumpAdress, PCsrc, branchAdress_mem , en, btn(1), clk, pc_if, instr_if);

--registrul IF/ID
process(clk)
begin
    if rising_edge(clk) then
        if en = '1' then
            instr_id <= instr_if;
            pc_id <= pc_if;
        end if;
    end if;
end process;

C3: UC port map (instr_id(31 downto 26), RegDst_id, ExtOp, ALUsrc_id, Branch_id, Br_ne_id, Jump,
    MemWrite_id, MemtoReg_id, RegWrite_id, ALUop_id);

--conectam iesirile la leduri
led(10 downto 9)<= ALUop_id;
led(8) <= RegDst_id;
led(7) <= ExtOp;
led(6) <= ALUsrc_id;
led(5) <= Branch_id;
led(4) <= Br_ne_id;
led(3) <= Jump;
led(2) <= MemWrite_id;
led(1) <= MemtoReg_id;
led(0) <= RegWrite_id;

wd_wb <= ALUresOUT_wb when MemtoReg_wb = '0' else MemData_wb;

C4: instrDecode port map (clk, RegWrite_wb, instr_id(25 downto 0), wa_wb, en,
    ExtOp, rd1_id, rd2_id, wd_wb, extimm_id, func_id, sa_id, rt_id, rd_id);
    
--registrul ID/EX
process(clk)
begin
    if rising_edge(clk) then
        if en = '1' then
            RegDst_ex <=RegDst_id;
            ALUsrc_ex <= ALUsrc_id;
            Branch_ex <= Branch_id;
            Br_ne_ex <= Br_ne_id;
            ALUop_ex <= ALUop_id;
            MemWrite_ex <= MemWrite_id;
            MemtoReg_ex <= MemtoReg_id;
            RegWrite_ex <= RegWrite_id;
            rd1_ex <= rd1_id;
            rd2_ex <= rd2_id;
            extimm_ex <= extimm_id;
            func_ex <= func_id;
            sa_ex <= sa_id;
            rd_ex <= rd_id;
            rt_ex <= rt_id;
            pc_ex <= pc_id;
        end if;
    end if;
end process;
    
C5: EX port map (rd1_ex, ALUsrc_ex, rd2_ex, extimm_ex, sa_ex, func_ex, ALUop_ex, pc_ex,
rt_ex, rd_ex, RegDst_ex, zero_ex, ALUresIN_ex, nequal_ex, branchAdress_ex, rWA_ex);

--registrul EX/MEM
process(clk)
begin
    if rising_edge(clk) then
        if en = '1' then
            Branch_mem <= Branch_ex;
            Br_ne_mem <= Br_ne_ex;
            MemWrite_mem <= MemWrite_ex;
            MemtoReg_mem <= MemtoReg_ex;
            RegWrite_mem <= RegWrite_ex;
            zero_mem <= zero_ex;
            nequal_mem <= nequal_ex;
            branchAdress_mem <= branchAdress_ex;
            ALUresIN_mem <= ALUresIN_ex;
            wa_mem <= rWA_ex;
            rd2_mem <= rd2_ex;
        end if;
    end if;
end process;


C6: MEM port map (MemWrite_mem, ALUresIN_mem, rd2_mem, clk, en, MemData_mem, ALUresOUT_mem);

--registrul MEM/WB
process(clk)
begin
    if rising_edge(clk) then
        if en = '1' then
            MemtoReg_wb <= MemtoReg_mem;
            RegWrite_wb <= RegWrite_mem;
            ALUresOUT_wb <= ALUresOUT_mem;
            MemData_wb <= MemData_mem;
            wa_wb <= wa_mem;
        end if;
    end if;
end process;

--multiplexor
process(sw(7 downto 5))
begin
    case sw(7 downto 5) is
        when "000" => digits <= instr_id;
        when "001" => digits <= pc_id;
        when "010" => digits <= rd1_ex;
        when "011" => digits <= rd2_ex;
        when "100" => digits <= extimm_ex;
        when "101" => digits <= ALUresIN_mem;
        when "110" => digits <= MemData_mem; 
        when "111" => digits <= wd_wb;
    end case;
end process;

C7: SSD port map (clk, digits, an, cat);


end Behavioral;
