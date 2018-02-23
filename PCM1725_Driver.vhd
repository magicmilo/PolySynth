library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


--Controls PCM1725 DAC 16 bit chip up to 96KHz
--System Clock 256/384fs max 38.4MHz
--		@96KHz 24.576MHz or 36.864MHz
--Bit Clock
--		@96KHz 3.072MHz
--Sample rate L/R clock
--		96KHz
--Audio Data

--384fs SysClk = BitClock * 12 = SampleRate  *(12*32)
--256fs SysClk = BitClock * 8 = SampleRate  *(8*32)
--Clocked at sysclk * 2

--This Configuration runs at 150MHz
--if sysclk_div 4 384fs
--37.5MHz SystemClock
--3.125MHz BitClock
--97.656KHz
--if sysclk_div 6 256fs
--25MHz SystemClock
--3.125MHz BitClock
--97.656KHz

package PCM1725_Driver_pkg is
		  type data_array is array(natural range <>)  of std_logic_vector(15 downto 0);
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

use work.PCM1725_Driver_pkg.all;

entity PCM1725_Driver is
	port (Clk_In 	: in std_logic;
			Reset		: in std_logic;
			Data_In  : in data_array(3 downto 0);
			noteonoff: in std_logic_vector(3 downto 0);
			o_LRC  	: out std_logic;
			o_DIN  	: out std_logic_vector(1 downto 0);
			o_BCK	 	: out std_logic;
			o_SCK		: out std_logic
	);
end PCM1725_Driver;

architecture behaviour of PCM1725_Driver is
	signal data   : data_array(3 downto 0) := (others => (others => '0'));
	signal sysclk_div    : unsigned(2 downto 0) := "101";
	signal clk_div    : unsigned(1 downto 0) := "00";
	signal bitclk   : std_logic := '1';
	signal bit_counter: unsigned(3 downto 0) := "1111";
	signal lrclk : std_logic := '0';
	signal sysclk : std_logic := '0';
	signal dbit : std_logic_vector(1 downto 0) := "00";
begin
process(Clk_In, Reset)
begin
if (Reset = '1') then
	data <= (others => (others => '0'));
	lrclk <= '0';
	sysclk <= '0';
	sysclk_div <= "101";
	clk_div <= "00";
	bitclk <= '0';
	bit_counter <= "1111";
	o_LRC <= '0';
	o_BCK <= '0';
	dbit <= "00";
	
elsif rising_edge(Clk_In) then
if(sysclk_div = "101") then --50MHz toggle for 25MHz
	if (sysclk = '0') then
		if(clk_div = "00") then --25/8 3.125MHz
			if(bitclk = '1') then --/2 1.536MHz
				if(bit_counter = "1111") then				
						
					if(lrclk = '1') then
						dbit(0) <= data(0)(to_integer(unsigned(bit_counter)));
						if(noteonoff(1) = '1') then
							data(1) <= Data_In(1);
						else
							data(1) <= (others => '0');
						end if;
						dbit(1) <= data(2)(to_integer(unsigned(bit_counter)));
						if(noteonoff(3) = '1') then
							data(3) <= Data_In(3);
						else
							data(3) <= (others => '0');
						end if;
					else
						dbit(0) <= data(1)(to_integer(unsigned(bit_counter))); --Really?
						if(noteonoff(0) = '1') then
							data(0) <= Data_In(0);
						else
							data(0) <= (others => '0');
						end if;
						dbit(1) <= data(3)(to_integer(unsigned(bit_counter))); --Really?
						if(noteonoff(2) = '1') then
							data(2) <= Data_In(2);
						else
							data(2) <= (others => '0');
						end if;
					end if;
					lrclk <= not lrclk;
				else
					if(lrclk = '0') then
						dbit(0) <= data(0)(to_integer(unsigned(bit_counter)));
						dbit(1) <= data(2)(to_integer(unsigned(bit_counter)));
					else
						dbit(0) <= data(1)(to_integer(unsigned(bit_counter)));
						dbit(1) <= data(3)(to_integer(unsigned(bit_counter)));
					end if;
				end if;
				
				bitclk <= not bitclk;
			else
				bit_counter <= bit_counter - 1;
				bitclk <= not bitclk;
			end if; --1.536MHz	
				
			
			
		end if; --3.125MHz
		clk_div <= clk_div + 1;	
		sysclk <= '1';
	else
		sysclk <= '0';
	end if;--50MHz
	
	sysclk <= not sysclk;
   sysclk_div <= "000";
else
	sysclk_div <= sysclk_div + 1;
end if;--clkdiv3	
end if;--clk
o_BCK <= bitclk;
o_LRC <= lrclk;	
o_SCK <= sysclk;
o_DIN <= dbit;
end process;
end behaviour;
			
			
			
