library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

package Envelope_pkg is
        type step_array is array(natural range <>) of unsigned(23 downto 0);
		  type amp_array  is array(natural range <>) of unsigned(24 downto 0);
		  type out_array  is array(natural range <>) of std_logic_vector(15 downto 0);
		  type mode_array is array(natural range <>) of integer range 0 to 4;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.Envelope_pkg.all;

--24bit Clocked at 150MHz
--clock divisor 4096 for 36621Hz
--
--max 458 seconds min 27us

--Currently taking padded 14 bit data
--xxxxxxxx[13..0]xx
--giving a range of 115 seconds to 6.99ms

entity Envelope is
	port (Clk_In 	: in std_logic;
			Reset		: in std_logic;
			Trigger  : in std_logic_vector(7 downto 0);
			i_Cmd 	: in std_logic_vector(7 downto 0);
			i_Data	: in std_logic_vector(13 downto 0);
			cmd_valid: in std_logic;
			o_amp    : out out_array(7 downto 0);
			o_tst		: out std_logic_vector(13 downto 0)
	);
end Envelope;

architecture behaviour of Envelope is
	signal steps : step_array(3 downto 0) := (others => (others => '0'));
	signal Amplitude : amp_array(7 downto 0) := (others => (others => '0'));
	signal NextAmp	  : amp_array(7 downto 0) := (others => (others => '0'));
	signal mode	  : mode_array(7 downto 0) := (4,4,4,4,4,4,4,4);
	signal cmd_byte : std_logic_vector(7 downto 0) := (others => '0');
	signal clk_div : unsigned(11 downto 0) := (others => '0');
	constant max : unsigned(24 downto 0) := "0111111111111111111111111";
	signal temp : std_logic_vector(23 downto 0) := (others => '0');
	signal v : std_logic := '0';
	signal newdat : std_logic := '0';
begin
mainstep : process(Clk_In, Reset, cmd_valid)
begin
if rising_edge(Clk_In) then
	if(Reset = '0') then -------------------NOT RESET MAIN--------------------------------
		for index in 0 to 7 loop
			if clk_div = x"000" then
				case mode(index) is
				when 0 => --attack
					if Trigger(index) = '1' then
						if(NextAmp(index) > max) then
							Amplitude(index) <= max;
							NextAmp(index) <= max;	
							mode(index) <= 1;
						else
							Amplitude(index) <= NextAmp(index);
							NextAmp(index) <= NextAmp(index) + steps(0);	
						end if;
					else
						mode(index) <= 3;
					end if;
													
				when 1 => --decay
					if Trigger(index) = '1' then
						if(NextAmp(index) < ('0' & steps(2))) then
							Amplitude(index) <= '0' & steps(2);
							NextAmp(index) <= '0' & steps(2);
							mode(index) <= 2;
						else
							Amplitude(index) <= NextAmp(index);
							NextAmp(index) <= NextAmp(index) - steps(1);	
						end if;
					else
						mode(index) <= 3;
					end if;
					
				when 2 => --sustain
					Amplitude(index) <= '0' & steps(2);
					if Trigger(index) = '0' then
						mode(index) <= 3;
						NextAmp(index) <= NextAmp(index) - steps(3);
					end if;
					
				when 3 => --release
					if Trigger(index) = '1' then
						mode(index) <= 0;
					else
						if(NextAmp(index) > max) then
							Amplitude(index) <= (others => '0');
							NextAmp(index) <= (others => '0');
							mode(index) <= 4;
						else
							Amplitude(index) <= NextAmp(index);
							NextAmp(index) <= NextAmp(index) - steps(3);
						end if;
					end if;
				when 4 => --flat
					if Trigger(index) = '1' then
						mode(index) <= 0;
					else
						Amplitude(index) <= (others => '0');
						NextAmp(index) <= (others => '0');
					end if;
				end case;
			end if;
		end loop;
		clk_div <= clk_div + 1;
		
		--update all outputs---------------------BESTWAY??
		for set in 0 to 7 loop
			o_amp(set) <= std_logic_vector(Amplitude(set)(23 downto 8));
		end loop;

	else ----------------------------------RESET-------------------------------------------------
		mode <= (4,4,4,4,4,4,4,4);
		clk_div <= (others => '0');
		Amplitude <= (others => (others => '0'));
		NextAmp <= (others => (others => '0'));
		o_amp <= (others => (others => '0'));
		steps <= (others => (others => '0'));
		v <= '0';
		newdat <= '0';
	end if;--reset
	
	--------------------------THE NEXT PART IS FOR REGISTER UPDATING---------------------------------
		if (v = '0') then --catch rising edge of cmd valid
			if(cmd_valid = '1') then --rising_edge
				v <= '1';
				cmd_byte <= i_Cmd;
				temp <= "00000000" & i_Data & "00";
				newdat <= '1';
			end if;
		else
			if(cmd_valid = '1') then --falling
				v <= '0';
			end if;
		end if;
	                                                                                                     
		if (newdat = '1') then --if new data then update
			newdat <= '0';
			if (cmd_byte(7 downto 4) = "1100") then
				steps(to_integer(unsigned(cmd_byte(3 downto 0)))) <= unsigned(temp);		
			end if;
		end if;
		o_tst <= "0000000000" & std_logic_vector(to_unsigned(mode(0), 4));
		--o_tst <= std_logic_vector(steps(0)(23 downto 10));
	
	------------------------------------------------------------------------------------------------
end if;--clk
end process;
end behaviour;

			
			
			