library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--Takes Serial Messages From UART_RX and controls all
--Protocol:
--0,command byte 1xxx_xxxx
--1,data byte	  0xxx_xxxx
--Status:
--0,idle, wait for command
--1,controlbyte stored, wait for byte_ready to go low
--2,idle wait for byte
--3,

entity spirreg is
	port (
	 clk			  : IN STD_LOGIC;
    rrdy         : IN 	STD_LOGIC;  --receive ready bit
    rx_data      : IN 	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --receive register output to logic
	 o_dat	: OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --asynchronous tx data to load
	 o_cmd	: OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')  --asynchronous tx data to load
	);
end spirreg;

architecture behaviour of spirreg is
signal temp : std_logic_vector(7 downto 0) := (others => '0');
signal phase : std_logic := '0';
begin


	process(clk)
	begin
	if rising_edge(clk) then
		o_dat <= temp;
		if(rrdy = '1') then
			temp <= rx_data;
		end if;
		
	end if;
	end process;

end behaviour;
			
			
			