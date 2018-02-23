library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

--Processes Oscillator Commands
--1001xxxx note on 0-7
--1001xxxx note off 07-
--The NOTE Data contains step values for  the 32bit oscillator counters
--Based on 50MHz step rate

entity Settings_Controller is
	generic (Address 	: integer range 0 to 15 := 0);
	port (Clk_In 		: in std_logic;
			Reset		: in std_logic;
			I_Cmd	   	: in std_logic_vector(7 downto 0);
			I_Data   	: in std_logic_vector(13 downto 0);
			cmd_valid 	: in std_logic;
			o_Data  	: out std_logic_vector(13 downto 0)
	);
end Settings_Controller;

architecture behaviour of Settings_Controller is
signal cmd_byte : std_logic_vector(7 downto 0) 	:= (others => '0');
signal dat_byte : std_logic_vector(13 downto 0) := (others => '0');
signal datavalue: std_logic_vector(13 downto 0) := (others => '0');
signal tog 		: std_logic := '0';
begin
process(Clk_In, Reset)
begin
if (Reset = '1') then
	tog <= '0';
	cmd_byte <= "00000000";
	dat_byte <= (others => '0');
	datavalue <= (others => '0');
elsif rising_edge(Clk_In) then
	if(tog = '0') then
		if (cmd_valid = '1') then
			tog <= '1';
			cmd_byte <= I_Cmd;
			dat_byte <= I_Data;
		end if;
	else
		if (cmd_valid = '0') then
			tog <= '0';
			if(cmd_byte = (x"C" & std_logic_vector(to_unsigned(Address, 4)))) then
				datavalue <= dat_byte;
			end if;
		end if;
	end if;		
	o_Data <= datavalue;
end if;
end process;
end behaviour;
			
			
			
