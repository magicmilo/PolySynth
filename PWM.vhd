library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--PWM Driver
--150MHz clock
--12bit 36.621KHz
--250MHz
--12bit 61.035KHz


entity PWM is
	port (Clk_In 	: in std_logic;
			Data_In  : in std_logic_vector(11 downto 0);	
			O_PWM 	: out std_logic
	);
end PWM;

architecture behaviour of PWM is
	signal Data   		: unsigned(11 downto 0) := (others => '0');
	signal phase  	 	: unsigned(11 downto 0) := (others => '0');
begin
	process(Clk_In)
	begin
	if rising_edge(Clk_In) then
		Data <= unsigned(Data_In);
		if(Data > 0) then
			if(phase > Data) then
				O_PWM <= '0';
			else
				O_PWM <= '1';
			end if;
		else
			O_PWM <= '0';
		end if;
		
		phase <= phase + 1;

	end if;
	end process;

end behaviour;
			
			
			