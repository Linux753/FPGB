library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.control_signal.all;

entity control is 
	port(
	inst : in std_logic_vector(7 downto 0);

	--ALU Control signal
	alu : out alu_control;

	--Register control signal
	write : out std_logic;
	is_r16 : out std_logic;

	clk : in std_logic);

end control;

--This is basically a big FSM
architecture synth of control is
	signal arithm_opcode : std_logic_vector(4 downto 0);
begin 
	--Opcode linking
	arithm_opcode <= inst(7 downto 3);

	arithm : process(all)
	begin
	
	end process arithm;

end architecture synth;
