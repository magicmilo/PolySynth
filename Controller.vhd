--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

--Takes Serial Messages From UART_RX and controls all
--Protocol:
--SRAM 19bit addresses
--top 3 bits select bank
--32 bit sram samples
--66536 bytes

--wavespace is 14 bit address for 4096 samples stored as 32 bit values padded zero

entity Controller is
	port (Clk 		: in std_logic;
			bclk 		: in std_logic;
			Data_In	: in std_logic_vector(7 downto 0);
			Reset		: in std_logic;
			CMD_ROut	: out std_logic;
			Cmd_Out	: out std_logic_vector(7 downto 0);
			Dat_Out  : out std_logic_vector(7 downto 0);
			SRAM_Dat : out std_logic_vector(7 downto 0);
			SRAM_Add : out std_logic_vector(18 downto 0);
			SRAM_Ld  : out std_logic;
			SRAM_Fill: out std_logic;
			LED_Out	: out std_logic_vector(3 downto 0)
	);
end Controller;

architecture behaviour of Controller is
	signal cbuf 		: std_logic_vector(7 downto 0) 	:= "00000000";
	signal dbuf 		: std_logic_vector(7 downto 0) 	:= "00000000";
	signal bytebuf 		: std_logic_vector(7 downto 0) 	:= "00000000";
	signal srambuf 		: std_logic_vector(7 downto 0) 	:= "00000000";
	signal sramaddress	: std_logic_vector(18 downto 0)	:= (others => '0');
	signal valid 		: std_logic 					:= '0';
	signal state 		: integer range 0 to 3 		:= 0;
	signal SFill 		: std_logic 					:= '0';
	
	signal mode			: std_logic						:= '0';
	signal writestate : integer range 0 to 3		:= 0;

	constant writecmd : std_logic_Vector(7 downto 0) := "11111110";
	signal cmdcnt		: unsigned(1 downto 0) 			 := "00";
	signal dcounter	: unsigned(11 downto 0)			 := (others => '0');
	
	signal r  			: std_logic := '0';
	signal f 			: std_logic := '0';
	signal update  	: std_logic := '0';
	signal sramdatclk : std_logic := '0';
	
begin

	r  <= '1' when update = '0' and bclk = '1' else '0';
	f  <= '1' when update = '1' and bclk = '0' else '0';

	process(Clk, Reset)
	begin
	if(rising_edge(Clk)) then
		if Reset = '1' then
			cbuf <= (others => '0');
			dbuf <= (others => '0');			
			srambuf <= (others => '0');
			sramaddress <= (others => '0');
			dcounter <= (others => '0');
			SFill <= '0';
			state <= 0;
			cmdcnt <= "00";
			mode <= '0';
			valid <= '0';
			sramdatclk <= '0';
		else----------------------------------------------------------------no reset
			if(r = '1') then -----rising edge
				bytebuf <= Data_In;
				sramaddress <= "0000000" & std_logic_vector(dcounter);
			elsif(f = '1') then
				if(mode = '0') then ----------normal mode
					if bytebuf(7) = '1' then-----------------------------cmd byte received
						sramaddress <= (others => '0');
						case state is
						when 0 =>
							if(bytebuf = writecmd) then
								state <= 3;
								cmdcnt <= "01";
							else
								cmdcnt <= "00";
								state <= 1;
							end if;
							cbuf <= bytebuf;
						
						when 1 =>
							if(bytebuf = writecmd) then
								state <= 3;
								cmdcnt <= "01";
							else
								cmdcnt <= "00";
							end if;
							cbuf <= bytebuf;
						
						when 2 =>
							state <= 1;
							cbuf <= bytebuf;
						
						when 3 =>
							if(bytebuf = writecmd) then
								if(cmdcnt = "11") then
									mode <= '1';
									dcounter <= (others => '0');
									cmdcnt <= "00";
									writestate <= 0;
								else
									cmdcnt <= cmdcnt + 1;
								end if;
							else
								state <= 1;
							end if;
						
						end case;
					else------------------------------------------------data byte received
						case state is
						when 0 =>
						
						when 1 =>
							dbuf <= bytebuf;
							state <= 2;
						when 2 =>
							state <= 0;
						when 3 =>

						end case;
					end if;-------------------------end byte type choice
				else -------datadump mode
					case writestate is
					when 0 =>
						srambuf <= bytebuf;
						writestate <= 2;
						dcounter <= dcounter + 1;
					when 1 =>
						srambuf <= bytebuf;
						if (dcounter = "111111111111") then
							mode <= '0';
							state <= 0;
						else
							dcounter <= dcounter + 1;
							writestate <= 2;
						end if;
					when others =>
					
					end case;
				
				end if; -------------------end falling edge mode choice
			else
				
				if (state = 2) then
					valid <= '1';
				else
					valid <= '0';
				end if;
			
			end if; --end falling edge
				
			update <= bclk;
			
			if (mode = '1')then
				SFill <= '1';
			else
				SFill <= '0';
			end if;
			
			if writestate = 2 then
				writestate <= 3;
				sramdatclk <= '1';
			elsif writestate = 3 then
				writestate <= 1;
				sramdatclk <= '0';
			else
				sramdatclk <= '0';
			end if;
		end if;--end reset
		
		
	end if;--end rising clk
	end process;
	
	CMD_ROut <= valid;
	LED_Out <= SFill & mode & std_logic_vector(to_unsigned(state, 2));
	Cmd_Out <= cbuf;
	Dat_Out <= dbuf;
	SRAM_Add <= sramaddress;
	SRAM_Dat <= srambuf;
	SRAM_Fill <= SFill;
	SRAM_Ld <= sramdatclk;
end behaviour;
			
			
			
