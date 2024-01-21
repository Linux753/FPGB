library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registers_bank is
    port(
    in1    : in std_logic_vector(2 downto 0); --Destination register (register to write w_data) 
    in2    : in std_logic_vector(2 downto 0); --Source register 

    out1   : out std_logic_vector(7 downto 0); --Output for destination register
    out2   : out std_logic_vector(7 downto 0); --Output source destination register
    
    --16 bit register direct output
    HL     : out std_logic_vector(15 downto 0);
    BC     : out std_logic_vector(15 downto 0);
    DE     : out std_logic_vector(15 downto 0);
    SP     : out std_logic_vector(15 downto 0);

    w_data : in std_logic_vector(7 downto 0); --Data to write
    w_en   : in std_logic; --Write enable

    clk    : in std_logic);
end registers_bank;

architecture synth of registers_bank is
    type register_array is array (0 to 7) of std_logic_vector(7 downto 0);
    signal regs : register_array;
begin 
    --Combinationnal read 
    out1 <= regs(to_integer(unsigned(in1)));
    out2 <= regs(to_integer(unsigned(in2)));
	
    --Sequential write
    data_write : process(clk)
    begin
	if rising_edge(clk) then
	    if w_en = '1' then
		regs(to_integer(unsigned(in1))) <= w_data;
	    end if;
	end if;
    end process data_write;

    --16 bit registers direct read 
    HL <= regs(4)&regs(5);
    BC <= regs(0)&regs(1);
    DE <= regs(2)&regs(3);
    SP <= regs(6)&regs(7);

end architecture synth;
