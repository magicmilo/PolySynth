library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

package Osc_Control_pkg is
        type step_array is array(natural range <>)  of std_logic_vector(23 downto 0);
		  type note_array is array(natural range <>) of std_logic_vector(6 downto 0);
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.Osc_Control_pkg.all;

--Processes Oscillator Commands
--10001xxx note on 0-7
--10000xxx note off 07-
--The NOTE Data contains step values for  the 32bit oscillator counters
--Based on 50MHz step rate

entity Osc_Control is
	port(Clk_In : in std_logic;
			i_Reset  : in std_logic;
			i_Cmd	   : in std_logic_vector(7 downto 0);
			i_Data   : in std_logic_vector(13 downto 0);
			cmd_valid: in std_logic;
			o_Phases : out step_array(7 downto 0);
			o_Mode 	: out std_logic_vector(7 downto 0);
			o_Note 	: out note_array(7 downto 0);
			o_LED  	: out std_logic_vector(7 downto 0)
	);
end Osc_Control;

architecture behaviour of Osc_Control is
signal phasebuf : step_array(7 downto 0) := (others => (others => '0'));
signal notebuf : note_array(7 downto 0) := (others => (others => '0'));
signal cmd_byte : std_logic_vector(7 downto 0) := (others => '0');
signal cmda : std_logic_vector(3 downto 0) := "0000";
signal cmdb : integer range 0 to 15 := 0;
signal dat_int : integer range 0 to 255 := 0;
signal led_buf : std_logic_vector(7 downto 0) := "00000000";
signal mode : std_logic_vector(7 downto 0) := "00000000";
signal newbyte : std_logic := '0';
signal clkbuf  : std_logic := '0';
signal currclk  : std_logic := '0';
begin
process(Clk_In, i_Reset, cmd_valid)
type NOTE_DATA is array (0 to 127)
of integer range 0 to 2097151;
constant NOTE : NOTE_DATA :=
			(702,744,788,835,884,937,993,1052,
			1114,1181,1251,1325,1404,1488,1576,1670,
			1769,1874,1986,2104,2229,2362,2502,2651,
			2809,2976,3153,3340,3539,3749,3972,4209,
			4459,4724,5005,5303,5618,5952,6306,6681,
			7078,7499,7945,8418,8918,9448,10010,10606,
			11236,11904,12612,13362,14157,14999,15891,16836,
			17837,18897,20021,21212,22473,23809,25225,26725,
			28314,29998,31782,33672,35674,37795,40043,42424,
			44946,47619,50451,53451,56629,59996,63564,67344,
			71348,75591,80086,84848,89893,95239,100902,106902,
			113259,119993,127129,134688,142697,151182,160172,169697,
			179787,190478,201804,213804,226518,239987,254258,269377,
			285395,302365,320345,339394,359575,380956,403609,427609,
			453036,479975,508516,538754,570790,604731,640690,678788,
			719150,761913,807219,855219,906073,959951,1017032,1077508);

begin
if(i_Reset = '1') then
	phasebuf <= (others => (others => '0'));
	notebuf <= (others => (others => '0'));
	cmd_byte <= "00000000";
	cmda <= "0000";
	cmdb <= 0;
	led_buf <= "00000000";
	mode <= "00000000";
	newbyte <= '0';
	clkbuf <= '0';
elsif rising_edge(Clk_In) then
	if(newbyte = '1') then	
		case cmda is
		when x"9" => --note on A
			phasebuf(cmdb) <= std_logic_vector(to_unsigned(NOTE(dat_int),24));
			notebuf(cmdb) <= std_logic_vector(to_unsigned(dat_int,7)); 
			mode(cmdb) <= '1';
		when x"8" => --note off A
			phasebuf(cmdb) <= (others => '0');
			notebuf(cmdb) <= std_logic_vector(to_unsigned(0,7)); 
			mode(cmdb) <= '0';
		when others =>
		
		end case;
		newbyte <= '0';
	end if;

	if(clkbuf /= currclk) then
		if(clkbuf = '0') then --rising transition
			cmd_byte <= I_Cmd;
			cmda <= I_Cmd(7 downto 4);
			cmdb <= to_integer(unsigned(I_Cmd(3 downto 0)));
			dat_int <= to_integer(unsigned(I_Data(13 downto 7)));
			newbyte <= '1';
		end if;
		clkbuf <= currclk;
	end if;
	currclk <= cmd_valid;
end if;--reset
o_Note <= notebuf;
o_LED <= led_buf;
o_Mode <= mode;
o_Phases <= phasebuf;
end process;
end behaviour;
			
			
			