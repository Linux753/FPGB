library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_registers is
end tb_registers;


architecture test of tb_registers is 
    component registers_bank is
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
    end component;	
    signal in1 : std_logic_vector(2 downto 0) := (others => '0');
    signal in2 : std_logic_vector(2 downto 0) := (others => '0');

    signal out1 : std_logic_vector(7 downto 0) := (others => '0');
    signal out2 : std_logic_vector(7 downto 0) := (others => '0') ;

    signal HL     : std_logic_vector(15 downto 0);
    signal BC     : std_logic_vector(15 downto 0);
    signal DE     : std_logic_vector(15 downto 0);
    signal SP     : std_logic_vector(15 downto 0);

    signal w_data : std_logic_vector(7 downto 0) := (others => '0');

    signal clk : std_logic := '0';
    signal w_en : std_logic :='0';

    constant CLK_PERIOD : time := 100 ns;
    signal sim_ended : boolean := false;


begin
    regs : registers_bank port map(in1 => in1,
		    in2 => in2,
		    out1 => out1,
		    out2 => out2,
		    HL => HL,
		    BC => BC,
		    DE => DE,
		    SP => SP,
		    w_data => w_data,
		    clk => clk,
		    w_en => w_en);

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
	--Write data in the 8 bit register specified
	begin
	    w_en <= '1';
	    in1 <= reg_w;
	    w_data <= std_logic_vector(to_unsigned(data, w_data'length));
	    
	    wait until rising_edge(clk);
	    w_en <= '0';
	end procedure;

	procedure read_8bit(constant r1 : in std_logic_vector(2 downto 0);
			    constant r2 : in std_logic_vector(2 downto 0);
			    constant read1_expected : in integer;
			    constant read2_expected : in integer) is

			    variable read1, read2 : integer;

	--Read 8 bit register and compare it to value expected, throw error if not consistent
	begin
	    w_en <= '0';
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
	
	procedure write_16bit(constant reg_w : in std_logic_vector(1 downto 0);
			      constant data : in integer range 0 to 65535) is
	    variable data_vector : std_logic_vector(15 downto 0);
	--Write data in a virtual 16 bit register by two consecutive write in 8 bit register
	begin
	    data_vector := std_logic_vector(to_unsigned(data, data_vector'length));

	    write_8bit(reg_w&'1', to_integer(unsigned(data_vector(7 downto 0))));
	    write_8bit(reg_w&'0', to_integer(unsigned(data_vector(15 downto 8))));
	end procedure;

	procedure assert_eq(constant val : in integer;
				constant expected : in integer;
				constant info : in string) is
	--Print error message and throw error if not equal
	begin
	    assert val = expected 
	    report "Unexpected result reading register\n"
	    & info
	    & " Expected " & to_string(expected)& " read " & to_string(val)
	    severity error;
	end procedure;

    begin
	write_8bit("000", 16#45#);
	write_8bit("001", 16#12#);

	write_8bit("110", 16#FF#);
	write_8bit("111", 16#E4#);

	read_8bit("000", "001", 16#45#, 16#12#);
	
	write_16bit("10", 16#1234#);
	write_16bit("01", 16#89FF#);

	wait for CLK_PERIOD/4;
	assert_eq(to_integer(unsigned(HL)), 16#1234#, "Reading register HL");
	wait for CLK_PERIOD/4;
	assert_eq(to_integer(unsigned(BC)), 16#4512#, "Reading register BC");
	wait for CLK_PERIOD/4;
	assert_eq(to_integer(unsigned(DE)), 16#89FF#, "Reading register DE");
	wait for CLK_PERIOD/4;
	assert_eq(to_integer(unsigned(SP)), 16#FFE4#, "Reading register SP");

	sim_ended <= true;
	wait;
    end process test_set;
end architecture test;

