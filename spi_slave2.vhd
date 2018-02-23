--http://dani.foroselectronica.es/spi-communications-slave-core-vhdl-137/
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

entity spi_slave2 is
  port (
    RESET_in    : in  std_logic;
    CLK_in      : in  std_logic;
    SPI_CLK     : in std_logic;
    SPI_SS      : in std_logic;
    SPI_MOSI    : in  std_logic;
    SPI_MISO    : out std_logic;
    SPI_DONE    : out std_logic;
    DataToTx    : in std_logic_vector(7 downto 0);
    DataToTxLoad: in std_logic;
    DataRxd     : out std_logic_vector(7 downto 0)
    );
end spi_slave2;

architecture Behavioral of spi_slave2 is

    signal SCLK_latched, SCLK_old : std_logic;
    signal SS_latched, SS_old : std_logic;
    signal MOSI_latched: std_logic;
    signal TxData : std_logic_vector(7 downto 0);
    signal index: natural range 0 to 7;
    signal RxdData : std_logic_vector(7 downto 0);

begin

 --
 -- Sync process
 --

  process(CLK_in, RESET_in)

 begin
    if (RESET_in = '1') then
      RxdData <= (others => '0');
      index <= 7;
      TxData <= (others => '0');
      SCLK_old <= '0';
      SCLK_latched <= '0';
      SS_old <= '0';
      SS_latched <= '0';
      SPI_DONE <= '0';
      MOSI_latched <= '0';

    elsif( rising_edge(CLK_in) ) then

      SCLK_latched <= SPI_CLK;
      SCLK_old <= SCLK_latched;
      SS_latched <= SPI_SS;
      SS_old <= SS_latched;
      SPI_done <= '0';
      MOSI_latched <= SPI_MOSI;

      if(DataToTxLoad = '1') then
          TxData <= DataToTx;
      end if;

      if (SS_old = '1' and SS_latched = '0') then
          index <= 7;
      end if;

      if( SS_latched = '0' ) then
         if(SCLK_old = '0' and SCLK_latched = '1') then
            RxdData <= RxdData(6 downto 0) & MOSI_latched;
            if(index = 0) then -- cycle ended
               index <= 7;
            else
               index <= index-1;
            end if;
         elsif(SCLK_old = '1' and SCLK_latched = '0') then
            if( index = 7 ) then
               SPI_DONE <= '1';
            end if;
            TxData <= TxData(6 downto 0) & '1';
         end if;
      end if;
   end if;
   end process;

   --
   -- Combinational assignments
   --

   SPI_MISO <= TxData(7);
   DataRxd <= RxdData;

end Behavioral;