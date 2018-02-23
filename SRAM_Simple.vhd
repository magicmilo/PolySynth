library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

--SRAM organization

--ACCOUNT FOR 2 BYTES 9th June 2017
--NEED INTERMEDIATE STATES!

package SRAM_Simple_pkg is
        type address_array is array(natural range <>)  of std_logic_vector(18 downto 0);
		  type sample_array is array(natural range <>)  of std_logic_vector(15 downto 0);
		  type byte_array is array(natural range <>)  of std_logic_vector(7 downto 0);
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

use work.SRAM_Simple_pkg.all;
--THIS IS RUNNING NOW ON:
--2048 samples @ 16bit
--12bit address persample
--7bit bank sel 128 waves
--
--Later versions need bank switching for true wavetable synthesis
--CE is low active
--		  OE WE
--Read  L  H
--Write x  L


entity SRAM_Simple is
	port (
			Clk_In 	  : in std_logic;
			o_Data	  : out sample_array(7 downto 0);
			i_Phases	  : in address_array(7 downto 0);
			i_Data	  : in std_logic_vector(7 downto 0);
			i_WrAddress: in std_logic_vector(18 downto 0);
			i_WrClk	  : in std_logic;
			i_reset    : in std_logic;
			i_WriteEn  : in std_logic;
			SRAM_Data  : inout std_logic_vector(7 downto 0);
			o_Address  : out std_logic_vector(18 downto 0);		
			o_chip_en  : out std_logic;
			o_write_en : out std_logic;
			o_out_en   : out std_logic;
			o_ledstate : out std_logic_vector(1 downto 0)
	);
end SRAM_Simple;

architecture behaviour of SRAM_Simple is
	signal data_out	: std_logic_vector(7 downto 0) := (others => '0');
	signal sbuf			: sample_array(7 downto 0)		  := (others=> (others=>'0'));
	signal abuf			: address_array(7 downto 0)	  := (others=> (others=>'0'));
	signal address 	: std_logic_vector(18 downto 0) := (others => '0');
	signal datbyte 	: std_logic_vector(7 downto 0) := (others => '0');
	signal section		: std_logic := '0'; -- 32bit section cnt

	signal voice		: unsigned(2 downto 0) := "000";--voice counter
	signal prev_voice : unsigned(2 downto 0) := "111";
	signal sample  	: std_logic_vector(15 downto 0) := (others => '0');

	signal ce			: std_logic  := '1';
	signal we			: std_logic  := '1';
	signal oe			: std_logic  := '1';
	signal wr_clk		: std_logic  := '0';
	
	signal wr_address : std_logic_vector(18 downto 0) := (others => '0');
	signal wr_byte 	: std_logic_vector(7 downto 0) := (others => '0');
	signal tempbyte 	: std_logic_vector(7 downto 0) := (others => '0');
	
	signal RW_state	: integer range 0 to 2 := 0;
	signal clk_div		: unsigned(2 downto 0) := "000";
	signal d_received : std_logic := '0';
	
begin
process(Clk_In, i_reset)
begin
if (i_reset = '1') then
	voice <= "000";
	prev_voice <= "111";
	RW_state <= 0;
	clk_div <= "000";
	d_received <= '0';
	ce <= '0';
	we <= '1';
	oe <= '0';
	section <= '0';
	wr_clk <= '0';
	sbuf <= (others=> (others=>'0'));
	abuf <= (others=> (others=>'0'));
	address <= (others => '0');
	sample <= (others => '0');
elsif rising_edge(Clk_In) then
	case RW_state is
	when 0 =>
		if (clk_div = "111") then
			if(i_WriteEn = '1') then
				RW_state <= 2;
			else
				RW_state <= 1;
			end if;
		end if;
		clk_div <= clk_div + 1;
		section <= '0';
		wr_clk <= '0';
		sample <= (others => '0');
	when 1 => --read--------------------------------------------------------------------------------------
		case clk_div is
		when "000" =>
			ce <= '1';
			we <= '1';
			oe <= '1';
			address <= abuf(to_integer(voice))(18 downto 1) & section;
			tempbyte <= SRAM_Data;
		when "001" =>
			ce <= '0';
		when "010" =>
			oe <= '0';
		when "011" =>
			if(section = '0') then
				sample(15 downto 8) <= tempbyte;
			else
				sample(7 downto 0) <= tempbyte;
			end if;
		when "100" =>
			if(section = '1') then
				sbuf(to_integer(prev_voice)) <= sample;
			end if;
		when "101" =>
		
		when "110" =>
		
		when "111" =>
			if (section = '1') then
				voice <= voice + 1;
				prev_voice <= prev_voice + 1;
				section <= '0';
				if(d_received = '1') then
					RW_state <= 2;
				end if;
			else
				section <= '1';
			end if;
			ce <= '1';
			oe <= '1';
			
		when others =>
		end case;
		clk_div <= clk_div + 1;
		
	when 2 => --write------------------------------------------------------------------------------------
		case clk_div is
		when "000" =>
			ce <= '1';
			we <= '1';
			oe <= '0';
			address <= wr_address;
			datbyte <= wr_byte;		
		when "001" =>
			ce <= '0';
		when "010" =>
			we <= '0';
		when "011" =>
			
		when "100" =>
		
		when "101" =>
		
		when "110" =>
			we <= '1';
		when "111" =>
			ce <= '1';
			
			RW_State <= 1;
		when others =>
		end case;
			clk_div <= clk_div + 1;
			d_received <= '0';
		when others =>
	end case;
	
	if (i_WriteEn = '1') then
		if(i_WrClk /= wr_clk) then
			if (wr_clk = '0') then --risingedge
				d_received <= '1';
				wr_address <= i_WrAddress;
				wr_byte <= i_Data;
			end if;
			wr_clk <= i_WrClk;
		end if;
	end if;
	
	if RW_state = 2 then
		SRAM_Data <= data_out;
	else
		SRAM_Data <= (others=>'Z');
	end if;
	
	o_ledstate <= std_logic_vector(to_unsigned(RW_state, 2));

end if; --master clk edge

o_chip_en <= ce;
o_write_en <= we;
o_out_en <= oe;
o_data <= sbuf;
o_Address <= address;
data_out <= datbyte;
abuf <= i_Phases;
end process;
end behaviour;
			
			
			