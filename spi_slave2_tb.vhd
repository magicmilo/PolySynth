--http://dani.foroselectronica.es/spi-communications-slave-core-vhdl-137/
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

entity spi_slave2_tb is
end spi_slave2_tb;

architecture Behavioral of spi_slave2_tb is
	 
	    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT spi_slave2  --'test' is the name of the module needed to be tested.
--just copy and paste the input and output ports of your module as such. 
    PORT( 
          RESET_in    : in  std_logic;
			 CLK_in      : in  std_logic;
			 SPI_Clk     : in std_logic;
			 SPI_SS      : in std_logic;
			 SPI_MOSI    : in  std_logic;
			 SPI_MISO    : out std_logic;
			 SPI_DONE    : out std_logic;
			 DataToTx    : in std_logic_vector(7 downto 0);
			 DataToTxLoad: in std_logic;
			 DataRxd     : out std_logic_vector(7 downto 0)
        );
    END COMPONENT;
   --declare inputs and initialize them
	signal RESET_in : std_logic := '1';
   signal Clk_in : std_logic := '0';
   signal SPI_Clk : std_logic := '0';
	signal SPI_SS : std_logic := '1';
	signal SPI_MOSI : std_logic := '0';
	signal SPI_MISO : std_logic := '0';
	signal SPI_DONE : std_logic := '0';
	signal DataToTx : std_logic_vector(7 downto 0) := (others =>'0');
	signal DataToTxLoad : std_logic := '0';
	signal DataRxd : std_logic_vector(7 downto 0) := (others =>'0');
   -- Clock period definitions
   constant clk_period : time := 20 ns;
	constant byte : std_logic_vector(7 downto 0) := "10101011";
	signal index : integer range 0 to 7 := 7;
	 
begin
	 -- Instantiate the Unit Under Test (UUT)
   uut: spi_slave2 PORT MAP (
         RESET_in => RESET_in,
         CLK_in =>  CLK_in,
			 SPI_Clk => SPI_CLK,
			 SPI_SS => SPI_SS,
			 SPI_MOSI => SPI_MOSI,
			 SPI_MISO => SPI_MISO,
			 SPI_DONE => SPI_DONE,
			 DataToTx => DataToTx,
			 DataToTxLoad => DataToTxLoad,
			 DataRxd => DataRxd
        );  
 --
 -- Sync process
 --

     -- Clock process definitions( clock with 50% duty cycle is generated here.
   clk_process :process
   begin
        Clk_in <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        Clk_in <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
   end process;
	
	 -- Stimulus process
  stim_proc: process
   begin         
        wait for 2 us;
        RESET_in <='0';
        wait for 2 us;
        SPI_SS <='0';
		  for index in 7 to 0 loop
					SPI_MOSI <= byte(index);
					wait for 500 ns;
					SPI_Clk <= '1';
					wait for 500 ns;
					SPI_Clk <= '0';
		  end loop;
        wait for 500 ns;
        SPI_SS <= '1';
        wait;
  end process;


end Behavioral;