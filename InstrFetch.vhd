library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity InstrFetch is
    Port ( jump : in STD_LOGIC;
           jumpAdress : in STD_LOGIC_VECTOR (31 downto 0);
           PCsrc : in STD_LOGIC;
           branchAdress : in STD_LOGIC_VECTOR (31 downto 0);
           en : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           PC_4 : out STD_LOGIC_VECTOR (31 downto 0);
           instruction : out STD_LOGIC_VECTOR (31 downto 0));
end InstrFetch;

architecture Behavioral of InstrFetch is
--semnale pt PC
signal d : std_logic_vector(31 downto 0) := (others => '0');
signal q : std_logic_vector(31 downto 0) := (others => '0');

--semnale pentru memoria ROM
type t_mem is array (0 to 31) of std_logic_vector(31 downto 0);
signal mem: t_mem := (

-- 0: lw   $16, 0($0) 
--0x8C100000
-- se incarca in registru 16 valoarea din memorie de la adresa 0, aceasta valoare este numarul de elemente din sirul din memorie
B"100011_00000_10000_0000000000000000",

--1: no op
--0x00000000
B"000000_00000_00000_00000_00000_000000",

--2: no op
--0x00000000
B"000000_00000_00000_00000_00000_000000",

-- 3: beq  $16, $0, end_loop (offset = 52)
--0x12000034
--daca numarul de elemente este egal cu 0 atunci sarim direct la finalul programului
B"000100_10000_00000_0000000000110100",

--4: no op
--0x00000000
B"000000_00000_00000_00000_00000_000000",

--5: no op
--0x00000000
B"000000_00000_00000_00000_00000_000000",

--6: no op
--0x00000000
B"000000_00000_00000_00000_00000_000000",

-- 7: addi $10, $0, 0
--0x200A0000
--altfel, in registrul $10 vom contoriza cate elemente am parcurs, initial 0
B"001000_00000_01010_0000000000000000",

-- 8: addi $18, $0, 0
--0x20120000
--in  registrul $18 vom memora maximul din sir, initial va fi 0
B"001000_00000_10010_0000000000000000",

--9: no op
--0x00000000
B"000000_00000_00000_00000_00000_000000",

-- 10: sub  $11, $16, $10
--0x020A5822
-- in $11 facem scaterea dintre cate elemente sunt in sir si peste cate am trecut deja, pentru a stii daca continuam parcurgerea
B"000000_10000_01010_01011_00000_100010",

--11: no op
--0x00000000
B"000000_00000_00000_00000_00000_000000",

--12: no op
--0x00000000
B"000000_00000_00000_00000_00000_000000",

--(loop)
-- 13: beq  $11, $0, end_loop (offset = 42)
--0x1160002A
--daca $11 este 0, inseamna ca nu mai avem elemente de parcurs in sir, deci ne oprim, sarim la end_loop
B"000100_01011_00000_0000000000101010",

--14: no op
--0x00000000
B"000000_00000_00000_00000_00000_000000",

--15: no op
--0x00000000
B"000000_00000_00000_00000_00000_000000",

--16: no op
--0x00000000
B"000000_00000_00000_00000_00000_000000",

-- 17: sll  $11, $10, 2
--0x000A5880
--altfel, inumltim registrul 10 cu 4 pentru a putea gasi pozitia urmatorului element din sir 
B"000000_00000_01010_01011_00010_000000",

--18: no op
--0x00000000
B"000000_00000_00000_00000_00000_000000",

--19: no op
--0x00000000
B"000000_00000_00000_00000_00000_000000",

-- 20: lw   $12, 4($11)
--0x8D6C0004
-- $12 va fi registrul pentru elmentul curent din sir
--pentru ca sirul incepe in memorie la adresa 4 vom folosi offsetul 4 si $11 care ne spune peste cate elemete din sir sarim
B"100011_01011_01100_0000000000000100",

-- 21: addi $25, $0, 1
--0x20190001
--in registrul $25 punem 1, pentru a verifica paritatea elementului curent
B"001000_00000_11001_0000000000000001",

--22: no op
--0x00000000
B"000000_00000_00000_00000_00000_000000",

--23: no op
--0x00000000
B"000000_00000_00000_00000_00000_000000",

-- 24: and  $13, $12, $25
--0x01996824
--facem un and intre elem curent si 1 pentru a vedea daca numarul este par sau impar, se memoreaza in registrul $13
B"000000_01100_11001_01101_00000_100100",

--25: no op
--0x00000000
B"000000_00000_00000_00000_00000_000000",

--26: no op
--0x00000000
B"000000_00000_00000_00000_00000_000000",

-- 27: bne  $13, $0, next (offset = 25)
--0x15A00019
--in cazul in care elementul curent este impar (adica in $13 avem 1 ca ultim bit) atunci putem sari la elementul urmator
B"000101_01101_00000_0000000000011001",

--28: no op
--0x00000000
B"000000_00000_00000_00000_00000_000000",

--29: no op
--0x00000000
B"000000_00000_00000_00000_00000_000000",

--30: no op
--0x00000000
B"000000_00000_00000_00000_00000_000000",

-- 31: addi $14, $0, 0
--0x2000E0000
--altfel, daca am ajuns aici inseamna ca elementul este par, deci in $14 punem valoarea 0, pentru a vedea daca pana acum am setat un numar par
B"001000_00000_01110_0000000000000000",

--de aici nu mai am spatiu in ROM
----32: no op
----0x00000000
--B"000000_00000_00000_00000_00000_000000",

----33: no op
----0x00000000
--B"000000_00000_00000_00000_00000_000000",

---- 34: beq  $18, $14, set_max (offset = 17)
----0x124E0011
----daca in $18 se afla 0, atunci putem seta maximul ca fiind elementul curent
--B"000100_10010_01110_0000000000010001",

----35: no op
----0x00000000
--B"000000_00000_00000_00000_00000_000000",

----36: no op
----0x00000000
--B"000000_00000_00000_00000_00000_000000",

----37: no op
----0x00000000
--B"000000_00000_00000_00000_00000_000000",

---- 38: sub  $15, $12, $18
----0x01927822
----altfel, in registul $15 punem diferenta dintre registul curent si maxim
--B"000000_01100_10010_01111_00000_100010",

----39: no op
----0x00000000
--B"000000_00000_00000_00000_00000_000000",

----40: no op
----0x00000000
--B"000000_00000_00000_00000_00000_000000",

---- 41: beq  $15, $0, next (offset = 11)
----0x11E0000B
----daca aceasta diferenta este 0, atunci inseamna ca am ajuns la un element egal cu maximul curent deci trecem la urmatorul element
--B"000100_01111_00000_0000000000001011",

----42: no op
----0x00000000
--B"000000_00000_00000_00000_00000_000000",

----43: no op
----0x00000000
--B"000000_00000_00000_00000_00000_000000",

----44: no op
----0x00000000
--B"000000_00000_00000_00000_00000_000000",

---- 45: srl  $24, $15, 31
----0x000FC7C2
----altfel, verificam bitul de semn al scaderii si il punem in registul $24
--B"000000_00000_01111_11000_11111_000010",

----46: no op
----0x00000000
--B"000000_00000_00000_00000_00000_000000",

----47: no op
----0x00000000
--B"000000_00000_00000_00000_00000_000000",

---- 48: bne  $24, $0, next (offset = 4)
----0x17000004
----daca bitul de semn nu este 1 (nu este 0), inseamna ca numarul curent par este mai mic decat maximul, deci putem trece la urmatorul element
--B"000101_11000_00000_0000000000000100",

----49: no op
----0x00000000
--B"000000_00000_00000_00000_00000_000000",

----50: no op
----0x00000000
--B"000000_00000_00000_00000_00000_000000",

----51: no op
----0x00000000
--B"000000_00000_00000_00000_00000_000000",

----(set_max)
---- 52: add  $18, $0, $12
----0x000C9020
----daca am ajuns inseamna ca valoarea este maximul curent, deci actualizam maximul
--B"000000_00000_01100_10010_00000_100000",

----(next)
---- 53: addi $10, $10, 1
----0x214A0001
----trecem la urmatorul element, incrementand contorul (adica incrementam registrul $10)
--B"001000_01010_01010_0000000000000001",

---- 54: j loop (offset = 10)
----0x0800000A
----dupa incrementare sarim din nou in bucla pentru a continua parcurgerea sirului
--B"000010_00000000000000000000001010",

----55: no op
----0x00000000
--B"000000_00000_00000_00000_00000_000000",

----(end_loop)
---- 56: sw   $18, 20($0) 
----0xAC120014
----daca am ajuns aici, am terminat parcurgerea, asa ca vom salva maximul in memorie la adresa 20
--B"101011_00000_10010_0000000000010100",

others => X"00000"
);

-- semnal iesire sumator
signal sum : std_logic_vector(31 downto 0 ) := (others => '0');

--semnal mux 1
signal m : std_logic_vector(31 downto 0 ) := (others => '0');

begin


-- PC
process(clk, rst)
begin
    if rst = '1' then
        q <= (others => '0');
    elsif rising_edge(clk) then
        if en = '1' then
            q <= d;
        end if;
    end if;
end process;

-- memoria ROM
instruction <= mem(to_integer(unsigned(q(6 downto 2))));

--sumator
sum <= q + 4;
PC_4 <= sum;

--multiplexor 1
m <= sum when PCsrc = '0' else branchAdress;

--multiplexor 2
d <= m when jump = '0' else jumpAdress;


end Behavioral;
