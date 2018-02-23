library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

--SRAM organization
--19bit addresses
--bit 18 to 16 wave select
--bit 15 to 2  phase select from osc
--bit 1  to 0  "00" is zero padding "01" is highest byte "10" middle byte "11" lowest byte

--bank 19,18,17
--15 to 2 address xxxx xxxx xxxx xx
--1 to 0
--24-17, 16-8, 7-0 , 00000000

package SRAM_Controller_pkg is
        type address_array is array(natural range <>)  of std_logic_vector(13 downto 0);
		  type sample_array is array(natural range <>)  of std_logic_vector(23 downto 0);
		  type byte_array is array(natural range <>)  of std_logic_vector(7 downto 0);
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

use work.SRAM_Controller_pkg.all;
--THIS IS RUNNING NOW ON:
--100Mhz div 8 for 12.5MHz
--8 waves on SRAM
--
--Later versions need bank switching for true wavetable synthesis
--CE is low active
--		  OE WE
--Read  L  H
--Write x  L
--
--change in state from read to write is carried out with a cycle in idle first


entity SRAM_Controller is
	port (
			Clk_In 	  : in std_logic;
			o_Data	  : out sample_array(7 downto 0);
			i_Phases	  : in address_array(7 downto 0);
			i_Data	  : in std_logic_vector(7 downto 0);
			i_WrAddress: in std_logic_vector(18 downto 0);
			i_Write	  : in std_logic;
			i_reset    : in std_logic;
			i_WriteEn  : in std_logic;
			SRAM_Data  : inout std_logic_vector(7 downto 0);
			o_Address  : out std_logic_vector(18 downto 0);		
			o_chip_en  : out std_logic;
			o_write_en : out std_logic;
			o_out_en   : out std_logic
	);
end SRAM_Controller;

architecture behaviour of SRAM_Controller is
	signal data_out	: std_logic_vector(7 downto 0) := (others => '0');
	signal sbuf			: sample_array(7 downto 0)		  := (others=> (others=>'0'));
	signal abuf			: address_array(7 downto 0)	  := (others=> (others=>'0'));
	signal address 	: std_logic_vector(15 downto 0) := (others => '0');
	signal bank_sel	: unsigned(2 downto 0) := "000";
	signal section		: unsigned(1 downto 0) := "11"; -- 32bit section cnt
	signal state 		: integer range 0 to 2 := 1; --0,idle 1,read 2,write
	signal voice		: unsigned(2 downto 0) := "000";--voice counter
	signal prev_voice : unsigned(2 downto 0) := "111";
	signal clk_phase	: unsigned(2 downto 0) := "000";-- clk div by 8
	signal readvalid	: std_logic  := '0';
	signal chip_en		: std_logic  := '1';
	signal write_en	: std_logic  := '1';
	signal out_en		: std_logic  := '1';
	signal bytearr 	: byte_array(3 downto 0) := (others=> (others=>'0'));
	
begin
	process(clk_phase, i_reset)
	begin
		if (i_reset = '1') then
			state <= 1;
		else
			bank_sel <= "001";
			
			case state is
			when 0 => --idle----------------------------------------
			
				data_out <= (others => '0');
				chip_en <= '1';
				readvalid <= '0';
				voice <= "000";
				prev_voice <= "111";
			
			when 1 => --read from sram-----------------------------		
				data_out <= (others => '0');
				write_en <= '1';
				case clk_phase is
				when "000" =>
					address <= i_Phases(to_integer(voice)) & std_logic_vector(section);
					--address <= "01010101010101" & std_logic_vector(section);
				when "001" =>
					chip_en <= '0';
					out_en  <= '0';
				when "111" =>
					bytearr(to_integer(section)) <= SRAM_Data;
					--bytearr(to_integer(section)) <= "00001101";
					if (section = "00") then
						section <= "11";
						sbuf(to_integer(prev_voice)) <= bytearr(3) & bytearr(2) & bytearr(1);
					else
						section <= section - 1;
					end if;

				when others =>	
		
				end case;
			
			when 2 => --write to sram---------------------------------
				write_en <= '0';
			end case;		
		
		
		if state = 2 then
			SRAM_Data <= data_out;
		else
			SRAM_Data <= (others=>'Z');
		end if;
		--SRAM_Data <= data_out when state = 2 else (others=>'Z'); --when write to sram. assign data_out signal
		end if;
	end process;
	
	clkdiv : process(Clk_In, i_reset)
	begin
	if (rising_edge(Clk_In)) then
		if(i_reset = '1') then
			clk_phase <= "000";
		else
			clk_phase <= (clk_phase + 1);
		end if;
		o_Address <= std_logic_vector(bank_sel) & address;
		o_chip_en <= chip_en;
		o_write_en <= write_en;
		o_out_en <= out_en;
		o_Data <= sbuf;
	end if;
	end process;
	
end behaviour;
			
			
			