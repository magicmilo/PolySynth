library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
--Running on 150MHz

entity ClockTrigger is
	port (Clk_In 	: in std_logic;
			Reset		: in std_logic;
			Trigger  : out std_logic
	);
end ClockTrigger;

architecture behaviour of ClockTrigger is
	signal switch : std_logic := '0';
	constant diva : unsigned(7 downto 0) := to_unsigned(150, 8);
	signal cnta : unsigned(7 downto 0) := (others => '0');
	constant divb : unsigned(10 downto 0) := to_unsigned(1000, 11);
	signal cntb : unsigned(10 downto 0) := (others => '0');
begin
process(Clk_In, reset)
begin
if rising_edge(Clk_In) then
	if(reset = '0') then	
		if(cnta = (others => '0')) then
			if(cntb = (others => '0')) then
			-------------------------------
				Trigger <= '1';
			------------------------------
				cntb <= divb;
			else
				Trigger <= '0';
				cntb <= cntb - 1;
			end if;
			cnta <= diva;
		else
			cnta <= cnta - 1;
		end if;
	else --reset
		Trigger <= '0';
		cnta <= diva;
		cntb <= divb;
	end if;--reset
end if;--clk
end process;

end behaviour;
			
			
			