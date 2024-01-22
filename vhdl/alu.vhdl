library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.control_signal.all;

--The alu perform all the operation suypported by the ISA, 
--it comport a single bit register for 16 bit operation emulation

--TODO : 
    --ALU_rlc,
    --ALU_rl,
    --ALU_rrc,
    --ALU_rr,
    --ALU_sl,
    --ALU_sra,
    --ALU_srl,
    --ALU_bit,
    --ALU_set,
    --ALU_res,
    --ALU_swap

    --Plus support for 16 bit emulation (principaly a register storing an internal carry for addition)
entity alu is 
    port(
    in1       : in  std_logic_vector(7 downto 0);
    in2       : in  std_logic_vector(7 downto 0);
    flags_in  : in  std_logic_vector(3 downto 0);

    res       : out std_logic_vector(7 downto 0);
    flags_out : out std_logic_vector(3 downto 0);
    
    control   : in  alu_control;
    clk       : in std_logic);
end alu;

architecture synth of alu is 
    signal res_temp : std_logic_vector(16 downto 0); --Result of calculation 1 bit wider to avoid losing overflow
begin
    calc : process(all) --Combinationnal circuit to decode control signal and execute operation
    begin
	case control is
	    when ALU_add =>
		res_temp <= std_logic_vector(unsigned('0'&in1) + unsigned('0'&in2));
	    when ALU_sub =>
		res_temp <= std_logic_vector(unsigned('0'&in1) - unsigned('0'&in2));
	    when ALU_adc =>
		res_temp <= std_logic_vector(unsigned('0'&in1) + unsigned('0'&in2) + 
			    unsigned(0 => flags_in(0), others => '0'));
	    when ALU_sbc => 
		res_temp <= std_logic_vector(unsigned('0'&in1) - unsigned('0'&in2) - 
			    unsigned(0 => flags_in(0), others => '0'));
	    when ALU_and =>
		res_temp <= '0'&(in1 AND in2);
	    when ALU_xor =>
		res_temp <= '0'&(in1 AND in2);
	    when ALU_or =>
		res_temp <= '0'&(in1 OR in2);
	    when others =>
		res_temp <= (others => '0');
	end case;
    end process calc;
    
    --Combinationnal to not select the lsb of res_temp to produce res
    res <= res_temp(7 downto 0);

    zero_flag_update : process(all) --Zero flag combinational circuit
    begin
	flags_out(3) <= '0';
	if control = ALU_add or control = ALU_sub
	or control = ALU_adc or control = ALU_sbc
	or control = ALU_xor or control = ALU_and
	or control = ALU_and then
	    if res = "0000000000000000" then
		flags_out(3) <= '1';
	    end if;
	end if;
    end process zero_flag_update;

    sub_flag_calc : process(all) --Sub flag combinational circuit
    begin
	flags_out(3) <= '0';
	if control = ALU_sub or control = ALU_sbc then
	    flags_out(3) <= '1';
	end if;
    end process sub_flag_calc;

    --Carry flag combinational circuit
    flags_out(0) <= res_temp(4); 
     
end synth;



