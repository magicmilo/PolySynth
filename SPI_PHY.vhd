----------------------------------------------------------------------
-- SPI_PHY
----------------------------------------------------------------------
-- This entity serializes data sent to the bus and parallelizes data
-- received from the bus.  It "talks" to other devices using standard
-- SPI protocol, however, bus arbitration must be handled elsewhere 
-- (eg. SPI_Controller or other custom entity).
----------------------------------------------------------------------
-- KNOWN ISSUES:
--  * Currently only works for polarity=0, phase=1
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
library lpm;
use lpm.lpm_components.all;

entity SPI_PHY is
generic
(
	data_width : positive := 8;
	rising_edge_triggered : positive := 1
);
port
(
	-- Control Signals
	clock, load : in std_logic;

	-- Data Register (put TX data in here before transmission,
	-- read RX data from here after transmission)
	dataTX : in std_logic_vector(data_width-1 downto 0);
	dataRX : out std_logic_vector(data_width-1 downto 0);

	-- SPI Data Interface
	MISO : in std_logic;
	MOSI, SCLK : out std_logic
);
end entity SPI_PHY;

architecture behaviour of SPI_PHY is
begin
	
	sync_clock : process(clock) is
	begin
		if rising_edge_triggered = 1 then
			SCLK <= clock AND NOT load;
		else
			SCLK <= NOT clock AND NOT load;
		end if;
	end process sync_clock;

	shift_register : lpm_shiftreg
		generic map 
		(
			LPM_WIDTH => data_width
		)
		port map
		(
			-- MISO - Receives and buffers data bit from slave device
			-- MOSI - Transmits buffered data bit to slave device
			-- LOAD - Load DATA into transmit buffer
			shiftin => MISO,
			load => load,
			data => dataTX,
			clock => clock,
			shiftout => MOSI,
			q => dataRX
		);

end architecture behaviour;