library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registers is
	port(
	in1        : in std_logic_vector(2 downto 0);
	in2        : in std_logic_vector(2 downto 0);

	out1       : out std_logic_vector(15 downto 0);
	out2       : out std_logic_vector(15 downto 0);

	write_data : in std_logic_vector(15 downto 0);

	clk        : in std_logic;
	write      : in std_logic;
	is_r16     : in std_logic);
end registers;

architecture synth of registers is
	type register_file is array (0 to 7) of std_logic_vector(7 downto 0);
	signal regs : register_file;
begin 
	--Combinationnal read 
	read : process(all)
	begin
		if is_r16 = '1' then
			out1 <= regs(to_integer(unsigned(in1(2 downto 1)&'1')))&regs(to_integer(unsigned(in1(2 downto 1)&'0')));
			out2 <= regs(to_integer(unsigned(in2(2 downto 1)&'1')))&regs(to_integer(unsigned(in2(2 downto 1)&'0')));
		else
			out1 <= (7 downto 0 => regs(to_integer(unsigned(in1))) , others => '0');
			out2 <= (7 downto 0 => regs(to_integer(unsigned(in2))) , others => '0');
		end if;
	end process read;

	--Sequential write
	data_write : process(clk)
	begin
		if rising_edge(clk) then
			if is_r16 = '1' then
				regs(to_integer(unsigned(in1(2 downto 1)&'1'))) <= write_data(15 downto 8);
				regs(to_integer(unsigned(in1(2 downto 1)&'0'))) <= write_data(7 downto 0);
			else 
				regs(to_integer(unsigned(in1))) <= write_data(7 downto 0);
			end if;
		end if;
	end process data_write;

end architecture synth;
