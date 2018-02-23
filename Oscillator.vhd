library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

package Oscillator_pkg is
        type step_array is array(natural range <>)  of std_logic_vector(23 downto 0);
		  type phase_array is array(natural range <>)  of std_logic_vector(31 downto 0);
		  type oscout_array is array(natural range <>)  of std_logic_vector(15 downto 0);
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.Oscillator_pkg.all;

--dual 32bit ramp wave oscillator
--SETUP 200MHZ clock div 2 for 100MHZ and 50MHZ update

entity Oscillator is
	port (Clk_In 	: in std_logic;
			reset		: in std_logic;
			I_Steps  : in step_array(7 downto 0);
			I_Mode   : in std_logic_vector(7 downto 0); --0quiet,1A+B,2A+Boffset
			O_Phases : out oscout_array(7 downto 0);
			o_stat   : out std_logic_vector(7 downto 0)
	);
end Oscillator;

architecture behaviour of Oscillator is
	signal Step   : step_array(7 downto 0) := (others => (others => '0'));
	signal Phases : phase_array(7 downto 0) := (others => (others => '0'));
	signal mode	  : std_logic_vector(7 downto 0) := "00000000";
	signal switch : std_logic := '0';
	signal clk_div : unsigned(1 downto 0) := "00";
begin
process(Clk_In, reset)
begin
if rising_edge(Clk_In) then
	if(reset = '0') then	
		if(clk_div = "01") then
			if switch = '0' then
				for sel in 0 to 7 loop
					Phases(sel) <= Phases(sel) + Step(sel);
				end loop;
				switch <= '1';		
			else			
				mode <= I_Mode;
				Step <= I_Steps;
				switch <= '0';			
			end if;
			clk_div <= "00";
		else
			clk_div <= clk_div + 1;
		end if;
	else --reset
		Step <= (others => (others => '0'));
		Phases <= (others => (others => '0'));
		switch <= '0';
		mode <= "00000000";
		clk_div <= "00";
	end if;--reset
	
	for I in 0 to 7 loop
		O_Phases(I) <= Phases(I)(31 downto 16);
	end loop;
	
	o_stat <= mode;
end if;--clk
end process;

end behaviour;
			
			
			