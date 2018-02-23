library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity counter is
	port (Clk_In 	: in std_logic;
			LED_Out	: out std_logic_vector(3 downto 0)
	);
end counter;

architecture behaviour of counter is
	signal data_byte   : std_logic_vector(3 downto 0) := (others => '0');
begin
	process(Clk_In)
	begin
	if rising_edge(Clk_In) then
		data_byte <= data_byte + 1;	
	end if;
		LED_Out <= data_byte;
	end process;
end behaviour;
			
			
			