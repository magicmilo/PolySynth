library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--Controls AD1865 DAC chip Clocked at 4*Dac_Clk
--Min DAC Clk 13.5MHz
--MSB first data is clocked in on the rising edge
--1 set bit (latch low on MSB)
--2 clk high (latch high on LSB)
--3
--4 clk low

entity AD1865_Driver is
	port (Clk_In 	: in std_logic;
			Reset		: in std_logic;
			LData_In : in std_logic_vector(15 downto 0);	
			RData_In : in std_logic_vector(15 downto 0);	
			Latch  	: out std_logic;
			LData  	: out std_logic;
			RData	 	: out std_logic;
			DAC_Clk 	: out std_logic
	);
end AD1865_Driver;

architecture behaviour of AD1865_Driver is
	signal left_dat   : std_logic_vector(17 downto 0) := (others => '0');
	signal right_dat  : std_logic_vector(17 downto 0) := (others => '0');
	signal status  	 : unsigned(1 downto 0) := "11";
	signal bit_counter : integer range 0 to 17 := 0;
	signal Dclk : std_logic := '0';
	signal daclatch : std_logic := '0';
	signal Lbit : std_logic := '0';
	signal Rbit : std_logic := '0';
begin
	process(Clk_In, Reset)
	begin
	if Reset = '1'then
		left_dat <= (others => '0');
		right_dat <= (others => '0');
		status <= "11";
		bit_counter <= 0;
		Dclk <= '0';
		daclatch <= '0';
		Lbit <= '0';
		Rbit <= '0';
	elsif rising_edge(Clk_In) then
	
		case status is
			when b"00" => --idle
				status <= "01";
				Lbit <= left_dat(bit_counter);
				Rbit <= right_dat(bit_counter);
				if (bit_counter = 17) then
					daclatch <= '0';
				end if;
				
				if (bit_counter = 0) then
					daclatch <= '1';
				end if;
				
				if (bit_counter = 1) then
					daclatch <= '0';
				end if;
				
			when b"01" => --1
				status <= "10";
				Dclk <= '1';
					
			
			when b"10" => --2
				status <= "11";

			when b"11" => --3
				status <= "00";
				Dclk <= '0';
				
				if bit_counter = 0 then
					bit_counter <= 17;
					if ((LData_In & "00") /= left_dat) then --dont need this check!
						left_dat <= LData_In & "00";
					end if;
					if ((RData_In & "00") /= right_dat) then
						right_dat <= RData_In & "00";
					end if;
										
				else
					bit_counter <= bit_counter - 1;
				end if;
			when others =>
		end case;
	end if;
	Latch  	<= daclatch;
	LData  	<= Lbit;
	RData	 	<= Rbit;
	DAC_Clk 	<= Dclk;
	end process;

end behaviour;
			
			
			
