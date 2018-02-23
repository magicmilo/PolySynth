library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

entity SevenSeg is
	port (DIn  : in std_logic_vector(3 downto 0);
			DOT  : in std_logic;
			DOut : out std_logic_vector(7 downto 0)
	);
end SevenSeg;

architecture behaviour of SevenSeg is	
begin

process(DIn, DOT)
begin
case DIn is
	when "0000" =>
		DOut <= "1011111" & DOT;
	when "0001" =>
		DOut <= "0001001" & DOT;
	when "0010" =>
		DOut <= "0111110" & DOT;
	when "0011" =>
		DOut <= "0111011" & DOT;
	when "0100" =>
		DOut <= "1101001" & DOT;
	when "0101" =>
		DOut <= "1110011" & DOT;
	when "0110" =>
		DOut <= "1110111" & DOT;--
	when "0111" =>
		DOut <= "0011001" & DOT;
	when "1000" =>
		DOut <= "1111111" & DOT;
	when "1001" => --9
		DOut <= "1111001" & DOT;
	when "1010" => --a
		DOut <= "1111101" & DOT;
	when "1011" => --b
		DOut <= "1100111" & DOT;
	when "1100" => --c
		DOut <= "1010110" & DOT;
	when "1101" => --d
		DOut <= "0101111" & DOT;
	when "1110" => --e
		DOut <= "1110110" & DOT;	
	when "1111" => --f
		DOut <= "1110100" & DOT;
end case;

end process;
end behaviour;
			
			
			
