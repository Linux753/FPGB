library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package control_signal is 

	type alu_control is (	ALU_add,
				ALU_sub,
				ALU_adc,
				ALU_sbc,
				ALU_and,
				ALU_xor,
				ALU_or,
				ALU_rlc,
				ALU_rl,
				ALU_rrc,
				ALU_rr,
				ALU_sl,
				ALU_sra,
				ALU_srl,
				ALU_bit,
				ALU_set,
				ALU_res,
				ALU_swap);
end package control_signal;

