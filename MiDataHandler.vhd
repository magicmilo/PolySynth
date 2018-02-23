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
--8*(0xFE) 2048 16 bit samples 5000bytes
--1xxx xxxx 0xxx xxxx 0xxx xxxx 0xxx xxxx

--MIDI common messages
--9x note on
--8x note off
--ex pitch bend
--f8 timing clock /24
--fe active sensing (reserved not sent to fpga)
--bx sys message -- 120 all sound off
					  -- 121 reset all
					  -- 123 all notes off
					  
--MiMessages
--c 0000 register sel x0000000x0000000

entity MiDataHandler is
	port (Clk 		: in std_logic;
			bclk 		: in std_logic;
			Data_In	: in std_logic_vector(7 downto 0);
			Reset		: in std_logic;
			CMD_ROut	: out std_logic;
			Cmd_Out	: out std_logic_vector(7 downto 0);
			Dat_Out  : out std_logic_vector(13 downto 0);
			SRAM_Dat : out std_logic_vector(7 downto 0);
			SRAM_Ld  : out std_logic;
			LED_Out	: out std_logic_vector(3 downto 0)
	);
end MiDataHandler;

architecture behaviour of MiDataHandler is
	signal cbuf 		: std_logic_vector(7 downto 0) 	:= "00000000";
	signal dbuf 		: std_logic_vector(13 downto 0) 	:= (others => '0');
	signal bytebuf 		: std_logic_vector(7 downto 0) 	:= "00000000";
	signal srambuf 		: std_logic_vector(7 downto 0) 	:= "00000000";
	signal valid 		: std_logic 					:= '0';
	signal state 		: integer range 0 to 4 			:= 0;
	
	signal mode			: std_logic						:= '0';
	signal writestate : integer range 0 to 3			:= 0;

	constant writecmd : std_logic_Vector(7 downto 0) 	:= "11111110";
	signal cmdcnt		: unsigned(2 downto 0) 			:= "000";
	signal dcounter	: unsigned(11 downto 0)			 	:= (others => '0');
	
	signal r  			: std_logic := '0';
	signal f 			: std_logic := '0';
	signal update  	: std_logic 	:= '0';
	signal sramdatclk : std_logic 	:= '0';
	
begin

process(Clk, Reset)
begin
if(rising_edge(Clk)) then
if Reset = '1' then
	cbuf <= (others => '0');
	dbuf <= (others => '0');			
	srambuf <= (others => '0');
	dcounter <= (others => '0');
	state <= 0;
	cmdcnt <= "000";
	mode <= '0';
	valid <= '0';
	sramdatclk <= '0';
	update <= '0';
else----------------------------------------------------------------no reset
	if(r = '1') then -----rising edge
		bytebuf <= Data_In;
		update <= '1';	
	elsif(f = '1') then
		if(mode = '0') then ----------normal mode
			if bytebuf(7) = '1' then-----------------------------cmd byte received
				case state is
				when 0 =>
					if(bytebuf = writecmd) then
						state <= 4;
						cmdcnt <= "001";
					else
						cmdcnt <= "000";
						state <= 1;
					end if;
					cbuf <= bytebuf;
				
				when 1 =>
					if(bytebuf = writecmd) then
						state <= 4;
						cmdcnt <= "001";
					else
						cmdcnt <= "000";
					end if;
					cbuf <= bytebuf;
				
				when 2 =>
					if(bytebuf = writecmd) then
						state <= 4;
						cmdcnt <= "001";
					else
						state <= 1;
						cmdcnt <= "000";
					end if;
					cbuf <= bytebuf;
					
				when 3 =>
					if(bytebuf = writecmd) then
						state <= 4;
						cmdcnt <= "001";
					else
						state <= 1;
						cmdcnt <= "000";
					end if;
					cbuf <= bytebuf;
					
				when 4 =>
					if(bytebuf = writecmd) then
						if(cmdcnt = "111") then
							mode <= '1';
							dcounter <= (others => '0');
							cmdcnt <= "000";
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
					dbuf(13 downto 7) <= bytebuf(6 downto 0);
					state <= 2;
				when 2 =>
					dbuf(6 downto 0) <= bytebuf(6 downto 0);
					state <= 3;
				when 3 =>
					state <= 0;
				when 4 =>
					state <= 0;
				end case;
			end if;-------------------------end byte type choice
		else -------datadump mode 1
			case writestate is
			when 0 =>
				srambuf <= bytebuf;
				writestate <= 2;
				dcounter <= dcounter + 1;
			when 1 =>
				srambuf <= bytebuf;
				dcounter <= dcounter + 1;
				writestate <= 2;
				
			when others =>
			
			end case;
			
		end if; -------------------end falling edge mode choice
	update <= '0';	
	else
		
		if(mode = '0') then
			if (state = 3) then
				valid <= '1';
			else
				valid <= '0';
			end if;
			sramdatclk <= '0';
		else
			valid <= '0';
			if writestate = 2 then
				if (dcounter = "000000000000") then
					mode <= '0';
					state <= 0;
				end if;
				sramdatclk <= '1';
				writestate <= 1;
			else
				sramdatclk <= '0';
			end if;
		end if;
	
	end if; --end falling edge
	
end if;--end reset		
end if;--end rising clk

end process;

r  <= '1' when update = '0' and bclk = '1' else '0';
f  <= '1' when update = '1' and bclk = '0' else '0';
	
CMD_ROut <= valid;
LED_Out <= std_logic_vector(to_unsigned(state, 4));
Cmd_Out <= cbuf;
Dat_Out <= dbuf;
SRAM_Dat <= srambuf;
SRAM_Ld <= sramdatclk;
end behaviour;
			
			
			
