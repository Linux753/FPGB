library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package control_signal is 

	type alu_control is ( 	NOP_OP,
				ADD_r8,
				ADD_r16,
				INC_r8,
				INC_r16,
				SUB_r8,
				DEC_r8,
				DEC_r16,
				ADC_OP,
				SBC_OP,
				AND_OP,
				XOR_OP,
				OR_OP,
				CP_OP,
				RLC_OP,
				RL_OP,
				RRC_OP,
				RR_OP,
				SLA_OP,
				SRA_OP,
				SRL_OP,
				SWAP_OP,
				BIT_OP,
				SET_OP,
				RES_OP);
end package control_signal;

