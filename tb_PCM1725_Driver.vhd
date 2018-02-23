-- Testbench automatically generated online
-- at http://vhdl.lapinoo.net
-- Generation date : 3.10.2017 16:00:57 GMT
-- Runs on 150MHz

library ieee;
use ieee.std_logic_1164.all;

entity tb_PCM1725_Driver is
end tb_PCM1725_Driver;

architecture tb of tb_PCM1725_Driver is

    component PCM1725_Driver
        port (Clk_In    : in std_logic;
              Reset     : in std_logic;
              Data_In   : in data_array (3 downto 0);
              noteonoff : in std_logic_vector (3 downto 0);
              o_LRC     : out std_logic;
              o_DIN     : out std_logic_vector (1 downto 0);
              o_BCK     : out std_logic;
              o_SCK     : out std_logic);
    end component;

    signal Clk_In    : std_logic;
    signal Reset     : std_logic;
    signal Data_In   : data_array (3 downto 0);
    signal noteonoff : std_logic_vector (3 downto 0);
    signal o_LRC     : std_logic;
    signal o_DIN     : std_logic_vector (1 downto 0);
    signal o_BCK     : std_logic;
    signal o_SCK     : std_logic;

    constant TbPeriod : time := 6666 ps; -- 150MHz
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : PCM1725_Driver
    port map (Clk_In    => Clk_In,
              Reset     => Reset,
              Data_In   => Data_In,
              noteonoff => noteonoff,
              o_LRC     => o_LRC,
              o_DIN     => o_DIN,
              o_BCK     => o_BCK,
              o_SCK     => o_SCK);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that Clk_In is really your main clock signal
    Clk_In <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        Data_In <= (others => '0');
        noteonoff <= (others => '0');

        -- Reset generation
        -- EDIT: Check that Reset is really your reset signal
        Reset <= '1';
        wait for 100 ns;
        Reset <= '0';
        wait for 100 ns;

        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_PCM1725_Driver of tb_PCM1725_Driver is
    for tb
    end for;
end cfg_tb_PCM1725_Driver;