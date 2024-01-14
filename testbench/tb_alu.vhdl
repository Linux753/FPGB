library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.control_signal.all;

entity tb_alu is
end tb_alu;

architecture test of tb_alu is 
	component alu is
		port(
		in1     : in  std_logic_vector(15 downto 0);
		in2     : in  std_logic_vector(15 downto 0);
		res     : out std_logic_vector(15 downto 0);
		flags   : out std_logic_vector(7  downto 0);
	
		control : in  alu_control;
		clk     : in std_logic);
	end component;
	

	constant CLK_PERIOD : time := 100 ns;

	signal in1 : std_logic_vector(15 downto 0) := (others => '0');
	signal in2 : std_logic_vector(15 downto 0) := (others => '0');
	signal res : std_logic_vector(15 downto 0) := (others => '0');
	signal flags : std_logic_vector(7 downto 0) := (others => '0');

	signal control : alu_control := ADD_r8;
	signal clk : std_logic := '0';

	signal end_simulation : boolean := false;
begin 

	alu_inst : alu port map(in1 => in1,
				in2 => in2,
				res => res,
				flags => flags,
				control => control,
				clk => clk);

	test : process
		variable sum : natural;
	begin
		in1 <= (7 downto 0 => "00000111", others => '0');
		in2 <= (7 downto 0 => "00000011", others => '0');
		control <= ADD_r8;

		wait until rising_edge(clk);
		
		wait for CLK_PERIOD/2;

		sum := to_integer(unsigned(res));
		assert sum = 10 AND flags(7) = '0' AND flags(6) = '0'
		report "Unexpected result"
		severity error;
		
		end_simulation <= true;
		wait;
	end process test;

	clock_gen : process
	begin
		clk <= '0';
		wait for CLK_PERIOD/2;

		clk <= '1';
		wait for CLK_PERIOD/2;

		if end_simulation then
			wait;
		end if;
	end process clock_gen;
	
end architecture test;
