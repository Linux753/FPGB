library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.control_signal.all;

entity alu is 
	port(
	in1     : in  std_logic_vector(15 downto 0);
	in2     : in  std_logic_vector(15 downto 0);
	res     : out std_logic_vector(15 downto 0);
	flags   : out std_logic_vector(7  downto 0);
	
	control : in  alu_control;
	clk     : in std_logic);
end alu;

architecture synth of alu is 
	signal res_temp : std_logic_vector(16 downto 0); --Result of calculation 1 bit wider to avoid losing overflow
begin
	calc : process(all) --Combinationnal circuit to perform the actual calculation
	begin
		case control is
			when ADD_r8 | ADD_r16 | INC_r8 | INC_r16 =>
				res_temp <= std_logic_vector(unsigned('0'&in1) + unsigned('0'&in2));
			when SUB_r8 | DEC_r8 | DEC_r16 =>
				res_temp <= std_logic_vector(unsigned('0'&in1) - unsigned('0'&in2));
			when AND_OP =>
				res_temp <= '0'&(in1 AND in2);
			when XOR_OP =>
				res_temp <= '0'&(in1 AND in2);
			when others =>
				res_temp <= (others => '0');
		end case;
	end process calc;
	
	res_prod : process(all) --Combinationnal circuit map res_temp to res (depending if it's an 8 bit or 16 bit operation)
	begin 
		case control is
			when ADD_r8 | INC_r8 | SUB_r8 | DEC_r8 | AND_OP | XOR_OP =>
				res <= "00000000"&res_temp(7 downto 0);
			when others =>
				res <= res_temp(15 downto 0);
		end case;
	end process res_prod;

	zero_flag_update : process(clk) --Zero flag sequential circuit
	begin
		if rising_edge(clk) then
			if control = ADD_r8 or control = INC_r8
			or control = SUB_r8 or control = DEC_r8
			or control = AND_OP or control = XOR_OP then
				if res = "0000000000000000" then
					flags(7) <= '1';
				else 
					flags(7) <= '0';
				end if;
			end if;
		end if;
	end process zero_flag_update;

	sub_flag_update : process(clk) --Sub flag sequential circuit
	begin
		if rising_edge(clk) then
			if control = SUB_r8 or control = DEC_r8 then
					flags(6) <= '1';
			elsif control = ADD_r8 or control = INC_r8 
			or control = XOR_OP or control = AND_OP then
					flags(6) <= '0';
			end if;
		end if;
	end process sub_flag_update;

end synth;



