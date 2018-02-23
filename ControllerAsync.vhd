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

--wavespace is 14 bit address for 4096 samples stored as 32 bit values padded zero

entity ControllerAsync is
	port (Clk 	: in std_logic;
			bclk : in std_logic;
			Data_In	: in std_logic_vector(7 downto 0);
			Reset		: in std_logic;
			CMD_ROut	: out std_logic;
			Cmd_Out	: out std_logic_vector(7 downto 0);
			Dat_Out  : out std_logic_vector(7 downto 0);
			SRAM_Dat : out std_logic_vector(7 downto 0);
			SRAM_Add : out std_logic_vector(17 downto 0);
			SRAM_Ld  : out std_logic;
			SRAM_Fill: out std_logic;
			LED_Out	: out std_logic_vector(3 downto 0)
	);
end ControllerAsync;

architecture behaviour of ControllerAsync is
	signal cbuf : std_logic_vector(7 downto 0) := "00000000";
	signal dbuf : std_logic_vector(7 downto 0) := "00000000";
	signal bytebuf : std_logic_vector(7 downto 0) := "00000000";
	signal srambuf : std_logic_vector(7 downto 0) := "00000000";
	signal sramaddress : unsigned(17 downto 0) := (others => '0');
	signal valid : integer range 0 to 2 := 0;
	signal state : integer range 0 to 4 := 0;
	signal SFill : std_logic := '0';

	signal r  : std_logic := '0';
	signal f : std_logic := '0';
	signal update : std_logic := '0';
	
begin

	r  <= '1' when update = '0' and bclk = '1' else '0';
	f  <= '1' when update = '1' and bclk = '0' else '0';

	process(Clk)
	begin
	if(rising_edge(Clk)) then
		if Reset = '1' then
			cbuf <= (others => '0');
			dbuf <= (others => '0');			
			srambuf <= (others => '0');
			sramaddress <= (others => '0');
			SFill <= '0';
			state <= 1;		
		else
			if(bytebuf /= Data_In) then
				update <= '1';
			end if;
			if(r = '1') then
				bytebuf <= Data_In;
			end if;
			if(f = '1') then
				if bytebuf(7) = '1' then
					sramaddress <= (others => '0');
					case state is
					when 0 =>
						state <= 1;
					when 1 =>

					when 2 =>
						state <= 1;
					when 3 =>
						state <= 1;
					when 4 =>
					
					end case;
					cbuf <= bytebuf;
				else
					case state is
					when 0 =>
					
					when 1 =>
						if(cbuf = "11111110") then --block write to sram
							state <= 4;
							srambuf <= bytebuf;
							sramaddress <= (others => '0');--start sram write
						else
							state <= 2;
							dbuf <= bytebuf;
						end if;				
					when 2 =>
						state <= 0;
					when 3 =>
						SRAM_Ld <= '0';
						sramaddress <= sramaddress + 1;
						srambuf <= bytebuf;
						state <= 4;
					when 4 =>
						
					end case;
				end if;
			end if;
				
			update <= bclk;
			
			if (state > 2) then
				SFill <= '1';
			else
				SFill <= '0';
			end if;
			
			if (state = 4) then
				SRAM_Ld <= '1';
				state <= 3;
			else
				SRAM_Ld <= '0';
			end if;
			
			if (state = 2) then
				Cmd_ROut <= '1';
			else
				Cmd_ROut <= '0';
			end if;
		end if;
	end if;
	end process;
	
	Cmd_Out <= cbuf;
	Dat_Out <= dbuf;
	SRAM_Dat <= srambuf;
	SRAM_Add <= std_logic_vector(sramaddress);
	SRAM_Fill <= SFill;
end behaviour;
			
			
			