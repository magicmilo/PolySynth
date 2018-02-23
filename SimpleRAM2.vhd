library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

--SRAM organization
--When FIFO full. Go into write mode.
--Dump Whole FIFO 4096 bytes, 2048 samples into SRAM_Data
--
--All other times,
--For All Voices
--Read MSB then LSB
--Each Read Cycles is 16 bytes
--
--We Read 16 at a time then halt read and process
--If FIFO full then goto write mode
--for address "xxxxxxx" & counter(18 downto 0)

package SimpleRAM_pkg is
        type address_array is array(natural range <>)  of std_logic_vector(18 downto 0);
		  type sample_array is array(natural range <>)  of std_logic_vector(15 downto 0);
		  type byte_array is array(natural range <>)  of std_logic_vector(7 downto 0);
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

use work.SimpleRAM_pkg.all;

--Later versions need bank switching for true wavetable synthesis
--CE is low active
--		  OE WE
--Read  L  H
--Write x  L


entity SimpleRAM is
	port (	Clk_In 	   : in std_logic;
			i_reset 	: in std_logic;
			o_Data	  	: out sample_array(7 downto 0);
			i_Phases	: in address_array(7 downto 0);
			i_FIFO	  	: in std_logic_vector(26 downto 0);
			i_FIFOFull : in std_logic;
			i_FIFOEmpty: in std_logic;
			o_RdReq    : in std_logic;
			SRAM_Data  : inout std_logic_vector(7 downto 0);
			o_Address  : out std_logic_vector(18 downto 0);		
			o_chip_en  : out std_logic;
			o_write_en : out std_logic;
			o_out_en   : out std_logic;
			o_ledstate : out std_logic_vector(3 downto 0)
	);
end SimpleRAM;

architecture behaviour of SimpleRAM is
	signal data_out		: std_logic_vector(7 downto 0) := (others => '0');
	signal sbuf			: sample_array(7 downto 0)		  := (others=> (others=>'0'));
	signal abuf			: address_array(7 downto 0)	  := (others=> (others=>'0'));
	signal address 		: std_logic_vector(18 downto 0) := (others => '0');
	signal datbyte 		: std_logic_vector(7 downto 0) := (others => '0');
	signal section		: std_logic := '0'; -- 32bit section cnt

	signal voice		: unsigned(2 downto 0) := "000";--voice counter
	signal prev_voice   : unsigned(2 downto 0) := "111";
	signal sample  		: std_logic_vector(15 downto 0) := (others => '0');

	signal ce			: std_logic  := '1';
	signal we			: std_logic  := '1';
	signal oe			: std_logic  := '1';
	signal wr_clk		: std_logic  := '0';
	
	signal wr_address 	: std_logic_vector(18 downto 0) := (others => '0');
	signal wr_byte 		: std_logic_vector(7 downto 0) := (others => '0');
	signal tempbyte 	: std_logic_vector(7 downto 0) := (others => '0');
	signal writecounter : unsigned(11 downto 0) := (others => '0');
	
	signal RW_state		: integer range 0 to 6 := 0;
	signal clk_div		: unsigned(2 downto 0) := "000";
	signal d_received 	: std_logic := '0';
	constant bank		: std_logic_vector(6 downto 0) := "0000000";
	
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
	when 0 => --idle
		voice <= "000";
		prev_voice <= "111";
		section <= '0';
		ce <= '1';
		oe <= '0';
		we <= '0';
		abuf <= i_Phases;
		if clk_div <= "111" then
			RW_State <= 1;
			ce <= '1';
			oe <= '1';
			we <= '1';
		end if;
		o_RdReq <= '0';
	when 1 => --initial address set data not valid
		address <= abuf(std_logic_vector(unsigned(voice))(18 downto 1) & section;
		if clk_div = "001" then
			ce <= '0';
		elsif clk_div = "010" then
			oe <= '0';
		elsif clk_div <= "111" then
			if section = '0' then
				prev_voice <= prev_voice + 1;
			end if;
			section <= '1';
			RW_state <= 2;
		end if;
		o_RdReq <= '0';
	when 2 => --receive data loop		
		if(clk_div = "000") then
			address <= abuf(std_logic_vector(unsigned(voice))(17 downto 0) & section;
			if(section = '1') then
				sbuf(std_logic_vector(unsigned(voice))(15 downto 8);
			else
				sbuf(std_logic_vector(unsigned(voice))(7 downto 0);
			end if;
		if clk_div = "111" then
			if section = '0' then
				prev_voice <= prev_voice + 1;
				section <= '1';
			else
				voice <= voice + 1;
				section <= '0';
				if(prev_voice = "111") and (voice = "000") and (section = '1') then
					RW_State <= 3;
					ce <= '1';
					oe <= '1';
					we <= '1';
				end if;
			end if;
		end if;
		o_RdReq <= '0';
	when 3 => 
		if (clk_div = "000") then
			o_data <= sbuf;
		elsif clk_div = "111" then
			if i_FIFOFull = '1' then
				RW_State <= 4;
				oe <= '0';
				write_counter <= (others => '0');
			else
				RW_State <= 0;
			end if;
		end if;
		o_RdReq <= '0'
	
	when 4 => --write start
		data_out <= i_FIFO;
		address <= "0000000" & write_counter;
		if clk_div = "001" then
			o_RdReq <= '1'
			we <= '0';
		elsif clk_div = "010" then
			o_RdReq <= '0';
			ce <= '0';
		elsif clk_div "111" then
			we <= '1';
			ce <= '1';
			if(write_counter = "111111111111") then
				RW_State <= 3;
			end if;
			write_counter <= write_counter + 1;
		end if;	
		
	end case;
	
	o_ledstate <= std_logic_vector(to_unsigned(RW_state, 4));
	clk_div <= clk_div + 1;
	
	if RW_state = 4 then
		SRAM_Data <= data_out;
	else
		SRAM_Data <= (others=>'Z');
	end if;

end if; --master clk edge

o_chip_en <= ce;
o_write_en <= we;
o_out_en <= oe;
o_Address <= address;
end process;
end behaviour;
			
			
			
