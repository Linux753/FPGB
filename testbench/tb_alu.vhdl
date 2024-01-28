library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.control_signal.all;

entity tb_alu is
end tb_alu;

architecture test of tb_alu is 
	component alu is
	    port(
	    in1       : in  std_logic_vector(7 downto 0);
	    in2       : in  std_logic_vector(7 downto 0);
	    flags_in  : in  std_logic_vector(3 downto 0);

	    res       : out std_logic_vector(7 downto 0);
	    flags_out : out std_logic_vector(3 downto 0);
	    
	    control   : in  alu_control;
	    clk       : in std_logic);
	end component;
	

	constant CLK_PERIOD : time := 100 ns;

	signal in1 : std_logic_vector(7 downto 0) := (others => '0');
	signal in2 : std_logic_vector(7 downto 0) := (others => '0');
	signal res : std_logic_vector(7 downto 0);
	signal flags_in : std_logic_vector(3 downto 0) := (others => '0');
	signal flags_out : std_logic_vector(3 downto 0);

	signal control : alu_control := ALU_add;
	signal clk : std_logic := '0';

	signal end_simulation : boolean := false;
begin 

	alu_inst : alu port map(in1 => in1,
				in2 => in2,
				res => res,
				flags_in => flags_in,
				flags_out => flags_out,
				control => control,
				clk => clk);

	test : process
		variable sum : natural;

		procedure assert_eq(constant val : in integer;
				constant expected : in integer;
				constant element : in string) is
		--Print error message and throw error if not equal
		begin
		    assert val = expected 
		    report "Unexpected result reading "
		    & element
		    & " Expected " & to_string(expected)& " read " & to_string(val)
		    severity error;
		end procedure;


	begin
		in1 <= "00000111";
		in2 <= "00000011";
		control <= ALU_add;
		flags_in <= (others => '0');

		wait until rising_edge(clk);
		wait for CLK_PERIOD/4;
		
		assert_eq(to_integer(signed(res)), 10, "result");
		assert_eq(to_integer(unsigned(flags_out)), 0, "flags");
		
		in1 <= X"FE";
		in2 <= X"03";
		control <= ALU_add;
		flags_in <= (others => '0');

		wait until rising_edge(clk);
		wait for CLK_PERIOD/4;
		
		assert_eq(to_integer(signed(res)), 1, "result");
		assert_eq(to_integer(unsigned(flags_out)), 2#0011#, "flags");
	
		in1 <= X"F0";
		in2 <= X"10";
		control <= ALU_add;
		flags_in <= (others => '0');

		wait until rising_edge(clk);
		wait for CLK_PERIOD/4;
		
		assert_eq(to_integer(signed(res)), 0, "result");
		assert_eq(to_integer(unsigned(flags_out)), 2#1001#, "flags");
	
		in1 <= X"05";
		in2 <= X"08";
		control <= ALU_sub;
		flags_in <= (others => '0');

		wait until rising_edge(clk);
		wait for CLK_PERIOD/4;

		assert_eq(to_integer(signed(res)), -3, "result");
		assert_eq(to_integer(unsigned(flags_out)), 2#0111#, "flags");
		    	
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
