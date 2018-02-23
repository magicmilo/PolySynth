library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

--0 no toggle
--1 half
--2 div3

entity CLKDIV is
	generic(div : unsigned(3 downto 0) := "0001");
	port (Clk_In 	: in std_logic;
			Clk_Out	: out std_logic
	);
end CLKDIV;

architecture behaviour of CLKDIV is
	signal cnt : unsigned(3 downto 0) := "0000";
begin

mainstep : process(Clk_In)
begin
if rising_edge(Clk_In) then
	if(cnt = div) then
		cnt <= "0000";
	else
		cnt <= cnt + 1;
	end if;
	if (cnt = "0000") then
		Clk_Out <= '1';
	else
		Clk_Out <= '0';
	end if;
end if;--clk
end process;
end behaviour;
			
			
			