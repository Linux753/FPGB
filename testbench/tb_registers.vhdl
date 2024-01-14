library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_registers is
end tb_registers;


architecture test of tb_registers is 
	component registers is
		port(
		in1        : in std_logic_vector(2 downto 0);
		in2        : in std_logic_vector(2 downto 0);

		out1       : out std_logic_vector(15 downto 0);
		out2       : out std_logic_vector(15 downto 0);
	
		write_data : in std_logic_vector(15 downto 0);
	
		clk        : in std_logic;
		write      : in std_logic;
		is_r16     : in std_logic);
	end component;
	
	signal in1 : std_logic_vector(2 downto 0) := (others => '0');
	signal in2 : std_logic_vector(2 downto 0) := (others => '0');

	signal out1 : std_logic_vector(15 downto 0) := (others => '0');
	signal out2 : std_logic_vector(15 downto 0) := (others => '0') ;

	signal write_data : std_logic_vector(15 downto 0) := (others => '0');

	signal clk : std_logic := '0';
	signal write : std_logic :='0';
	signal is_r16 : std_logic :='0';


	constant CLK_PERIOD : time := 100 ns;
	signal sim_ended : boolean := false;


begin
	regs : registers port map(in1 => in1,
			in2 => in2,
			out1 => out1,
			out2 => out2,
			write_data => write_data,
			clk => clk,
			write => write,
			is_r16 => is_r16);

	clk_gen : process
	begin 
		clk <= '0';
		wait for CLK_PERIOD/2;

		clk <= '1';
		wait for CLK_PERIOD/2;

		if sim_ended then
			wait;
		end if;
	end process clk_gen;
	
	test_set : process
		procedure write_8bit(constant reg_w : in std_logic_vector(2 downto 0); 
				     constant data : in integer range 0 to 65535) is
		begin
			is_r16 <= '0';
			write <= '1';
			in1 <= reg_w;
			write_data <= std_logic_vector(to_unsigned(data, write_data'length));
			
			wait until rising_edge(clk);
		end procedure;
	
		procedure read_8bit(constant r1 : in std_logic_vector(2 downto 0);
				constant r2 : in std_logic_vector(2 downto 0);
				constant read1_expected : in integer;
				constant read2_expected : in integer) is
	
				variable read1, read2 : integer;
		begin
			is_r16 <= '0';
			write <= '0';
			in1 <= r1;
			in2 <= r2;

			wait for CLK_PERIOD/4;

			read1 := to_integer(unsigned(out1));
			read2 := to_integer(unsigned(out2));

			assert read1 = read1_expected 
			report "Unexpected result reading register 8 bit"
			& " Read reg " & to_string(r1)
			& " Expected " & to_string(read1_expected)& " read " & to_string(read1)
			severity error;
	
			assert read2 = read2_expected
			report "Unexpected result reading register 8 bit"
			& "Read reg " & to_string(r2)
			& "Expected " & to_string(read2_expected)& " read " & to_string(read2)
			severity error;
		end procedure;

		procedure write_16bit(constant reg_w : in std_logic_vector(2 downto 0);
				      constant data : in integer range 0 to 65535) is
		begin
			is_r16 <= '1';
			write <= '1';
			in1 <= reg_w;
			write_data <= std_logic_vector(to_unsigned(data, write_data'length));
			
			wait until rising_edge(clk);
		end procedure;

		procedure read_16bit(constant r1 : in std_logic_vector(2 downto 0);
				constant r2 : in std_logic_vector(2 downto 0);
				constant read1_expected : in integer;
				constant read2_expected : in integer) is
	
				variable read1, read2 : integer;
		begin
			is_r16 <= '1';
			write <= '0';
			in1 <= r1;
			in2 <= r2;

			wait for CLK_PERIOD/4;

			read1 := to_integer(unsigned(out1));
			read2 := to_integer(unsigned(out2));

			assert read1 = read1_expected 
			report "Unexpected result reading register 16 bit"
			& " Read reg " & to_string(r1)
			& " Expected " & to_string(read1_expected)& " read " & to_string(read1)
			severity error;
	
			assert read2 = read2_expected
			report "Unexpected result reading register 16 bit "
			& "Read reg " & to_string(r2)
			& "Expected " & to_string(read2_expected)& " read " & to_string(read2)
			severity error;
		end procedure;
		
	begin
		write_8bit("000", 16#45#);
		write_8bit("001", 16#12#);

		write_8bit("010", 16#FF#);
		write_8bit("011", 16#E4#);

		read_8bit("000", "001", 16#45#, 16#12#);
		
		write_16bit("101", 16#1234#);

		read_16bit("000", "100", 16#1245#, 16#1234#);

		sim_ended <= true;
		wait;
	end process test_set;



end architecture test;

