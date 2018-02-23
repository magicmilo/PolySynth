library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

package MultiPWM_pkg is
        type data_array is array(natural range <>)  of std_logic_vector(15 downto 0);
		  type phase_array is array(natural range <>)  of unsigned(11 downto 0);
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

use work.MultiPWM_pkg.all;

--PWM Driver
--150MHz clock
--12bit 36.621KHz
--250MHz
--12bit 61.035KHz


entity MultiPWM is
	port (Clk_In 	: in std_logic;
			Reset		: in std_logic;
			Data_In  : in data_array(7 downto 0);	
			O_PWM 	: out std_logic_vector(7 downto 0)
	);
end MultiPWM;

architecture behaviour of MultiPWM is
	signal Data   		: phase_array(7 downto 0) := (others => (others => '0'));
	signal phase  	 	: unsigned(11 downto 0) := (others => '0');
	signal pwmout  	: std_logic_vector(7 downto 0) := (others => '0');
begin
	process(Clk_In, Reset)
	begin
	if(Reset = '1') then
		Data <= (others => (others => '0'));
		phase <= (others => '0');
		pwmout <= (others => '0');
	elsif rising_edge(Clk_In) then		
		for I in 0 to 7 loop
			Data(I) <= unsigned(Data_In(I)(15 downto 4));
			if(Data(I) > 0) then
				if(phase > Data(I)) then
					pwmout(I) <= '0';
				else
					pwmout(I) <= '1';
				end if;
			else
				pwmout(I) <= '0';
			end if;
		end loop;
		phase <= phase + 1;
	end if;
	end process;
	O_PWM <= pwmout;
end behaviour;
			
			
			