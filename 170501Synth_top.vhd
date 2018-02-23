--Legal Notice: (C)2017 Altera Corporation. All rights reserved.  Your
--use of Altera Corporation's design tools, logic functions and other
--software and tools, and its AMPP partner logic functions, and any
--output files any of the foregoing (including device programming or
--simulation files), and any associated documentation or information are
--expressly subject to the terms and conditions of the Altera Program
--License Subscription Agreement or other applicable license agreement,
--including, without limitation, that your use is for the sole purpose
--of programming logic devices manufactured by Altera and sold by Altera
--or its authorized distributors.  Please refer to the applicable
--agreement for further details.


-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library altera_mf;
use altera_mf.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--------------------------------------------------------------------------------
--*************** This is a MegaWizard generated file ****************
--Automatically generated example top level design to allow compilation
--of your DDR SDRAM Controller instance in Quartus.
--.
--This module instantiates your configured Altera DDR SDRAM Controller,
--some example driver logic, and a suitably configured PLL and DLL (where needed).
--.
--.
--Altera strongly recommends that you use this file as the starting point of your
--own project top level. This is because the IP Toolbench wizard parses this file
--to update parameters or generics, pin prefixes and other settings to match any
--changes you make in the wizard. The wizard will only update sections of code
--between its special tags so it is safe to edit this file and add your own logic
--to it. This is the recommended design flow for using the megacore.
--If you create your own top level or remove the tags, then you must make sure that
--any changes you make in the wizard are also applied to this file.
--Whilst editing this file make sure the edits are not inside any 'MEGAWIZARD'
--text insertion areas.
--(between <<START MEGAWIZARD INSERT and<<END MEGAWIZARD INSERT comments)
--Any edits inside these delimiters will be overwritten by the megawizard if you
--re-run it.
--If you really need to make changes inside these delimiters then delete
--both 'START' and 'END' delimiters.  This will stop the megawizard updating this
--section again.
------------------------------------------------------------------------------------
--<< START MEGAWIZARD INSERT PARAMETER_LIST
--Parameters:
--Device Family                      : Cyclone II
--local Interface Data Width         : 32
--DQ_PER_DQS                         : 8
--LOCAL_AVALON_IF                    : false
--MEM_CHIPSELS                       : 1
--MEM_CHIP_BITS                      : 0
--MEM_BANK_BITS                      : 2
--MEM_ROW_BITS                       : 12
--MEM_COL_BITS                       : 8
--LOCAL_BURST_LEN                    : 1
--LOCAL_BURST_LEN_BITS               : 1
--Number Of Output Clock Pairs       : 1
--<< END MEGAWIZARD INSERT PARAMETER_LIST
------------------------------------------------------------------------------------
--<< MEGAWIZARD PARSE FILE DDR13.0
--.
--<< START MEGAWIZARD INSERT MODULE

entity 170501Synth_top is 
        port (
              -- inputs:
                 signal clock_source : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal clk_to_sdram : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                 signal clk_to_sdram_n : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                 signal ddr_a : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
                 signal ddr_ba : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal ddr_cas_n : OUT STD_LOGIC;
                 signal ddr_cke : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                 signal ddr_cs_n : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                 signal ddr_dm : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal ddr_dq : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ddr_dqs : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal ddr_ras_n : OUT STD_LOGIC;
                 signal ddr_we_n : OUT STD_LOGIC;
                 signal pnf : OUT STD_LOGIC;
                 signal pnf_per_byte : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal test_complete : OUT STD_LOGIC
              );
end entity 170501Synth_top;


architecture europa of 170501Synth_top is
  component ddrtst is
PORT (
    signal ddr_dm : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal ddr_dqs : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal ddr_cas_n : OUT STD_LOGIC;
        signal local_rdata_valid : OUT STD_LOGIC;
        signal local_rdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal local_rdvalid_in_n : OUT STD_LOGIC;
        signal local_init_done : OUT STD_LOGIC;
        signal ddr_ras_n : OUT STD_LOGIC;
        signal ddr_a : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
        signal local_ready : OUT STD_LOGIC;
        signal clk_to_sdram : OUT STD_LOGIC;
        signal local_refresh_ack : OUT STD_LOGIC;
        signal local_wdata_req : OUT STD_LOGIC;
        signal ddr_ba : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal ddr_cs_n : OUT STD_LOGIC;
        signal ddr_we_n : OUT STD_LOGIC;
        signal ddr_cke : OUT STD_LOGIC;
        signal ddr_dq : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        signal clk_to_sdram_n : OUT STD_LOGIC;
        signal resynch_clk : IN STD_LOGIC;
        signal local_wdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal reset_n : IN STD_LOGIC;
        signal write_clk : IN STD_LOGIC;
        signal local_read_req : IN STD_LOGIC;
        signal local_be : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal local_write_req : IN STD_LOGIC;
        signal clk : IN STD_LOGIC;
        signal local_addr : IN STD_LOGIC_VECTOR (20 DOWNTO 0)
      );
  end component ddrtst;
  component ddrtst_example_driver is
PORT (
    signal local_size : OUT STD_LOGIC;
        signal pnf_persist : OUT STD_LOGIC;
        signal local_cs_addr : OUT STD_LOGIC;
        signal local_bank_addr : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal local_read_req : OUT STD_LOGIC;
        signal local_wdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal local_be : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal local_write_req : OUT STD_LOGIC;
        signal local_col_addr : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal local_row_addr : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
        signal test_complete : OUT STD_LOGIC;
        signal pnf_per_byte : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal local_rdata_valid : IN STD_LOGIC;
        signal local_rdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal local_wdata_req : IN STD_LOGIC;
        signal clk : IN STD_LOGIC;
        signal reset_n : IN STD_LOGIC;
        signal local_ready : IN STD_LOGIC
      );
  end component ddrtst_example_driver;
  component ddr_pll_cycloneii is
PORT (
    signal locked : OUT STD_LOGIC;
        signal c0 : OUT STD_LOGIC;
        signal c2 : OUT STD_LOGIC;
        signal c1 : OUT STD_LOGIC;
        signal areset : IN STD_LOGIC;
        signal inclk0 : IN STD_LOGIC
      );
  end component ddr_pll_cycloneii;
                signal clk :  STD_LOGIC;
                signal ddr_local_addr :  STD_LOGIC_VECTOR (20 DOWNTO 0);
                signal ddr_local_be :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal ddr_local_col_addr :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal ddr_local_cs_addr :  STD_LOGIC;
                signal ddr_local_rdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ddr_local_rdata_valid :  STD_LOGIC;
                signal ddr_local_read_req :  STD_LOGIC;
                signal ddr_local_ready :  STD_LOGIC;
                signal ddr_local_refresh_req :  STD_LOGIC;
                signal ddr_local_size :  STD_LOGIC;
                signal ddr_local_wdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ddr_local_wdata_req :  STD_LOGIC;
                signal ddr_local_write_req :  STD_LOGIC;
                signal dedicated_resynch_or_capture_clk :  STD_LOGIC;
                signal internal_clk_to_sdram :  STD_LOGIC_VECTOR (0 DOWNTO 0);
                signal internal_clk_to_sdram_n :  STD_LOGIC_VECTOR (0 DOWNTO 0);
                signal internal_ddr_a :  STD_LOGIC_VECTOR (11 DOWNTO 0);
                signal internal_ddr_ba :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_ddr_cas_n :  STD_LOGIC;
                signal internal_ddr_cke :  STD_LOGIC_VECTOR (0 DOWNTO 0);
                signal internal_ddr_cs_n :  STD_LOGIC_VECTOR (0 DOWNTO 0);
                signal internal_ddr_dm :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_ddr_ras_n :  STD_LOGIC;
                signal internal_ddr_we_n :  STD_LOGIC;
                signal internal_pnf :  STD_LOGIC;
                signal internal_pnf_per_byte :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal internal_test_complete :  STD_LOGIC;
                signal pll_locked :  STD_LOGIC;
                signal pll_reset :  STD_LOGIC;
                signal soft_reset_reg2_n :  STD_LOGIC;
                signal soft_reset_reg_n :  STD_LOGIC;
                signal write_clk :  STD_LOGIC;

begin

  --
 
  --
 
  --<< END MEGAWIZARD INSERT MODULE

  --<< START MEGAWIZARD INSERT REFRESH_REQ
  -- Custom logic to implement user controlled refreshes can be added here....
  -- refreshes disabled
  ddr_local_refresh_req <= std_logic'('0');
  --<< END MEGAWIZARD INSERT REFRESH_REQ

  --<< START MEGAWIZARD INSERT WRAPPER_NAME
  ddrtst_ddr_sdram : ddrtst
    port map(
            clk => clk,
            clk_to_sdram => internal_clk_to_sdram(0),
            clk_to_sdram_n => internal_clk_to_sdram_n(0),
            ddr_a => internal_ddr_a,
            ddr_ba => internal_ddr_ba,
            ddr_cas_n => internal_ddr_cas_n,
            ddr_cke => internal_ddr_cke(0),
            ddr_cs_n => internal_ddr_cs_n(0),
            ddr_dm => internal_ddr_dm(1 DOWNTO 0),
            ddr_dq => ddr_dq,
            ddr_dqs => ddr_dqs(1 DOWNTO 0),
            ddr_ras_n => internal_ddr_ras_n,
            ddr_we_n => internal_ddr_we_n,
            local_addr => ddr_local_addr,
            local_be => ddr_local_be,
            local_init_done => open,
            local_rdata => ddr_local_rdata,
            local_rdata_valid => ddr_local_rdata_valid,
            local_rdvalid_in_n => open,
            local_read_req => ddr_local_read_req,
            local_ready => ddr_local_ready,
            local_refresh_ack => open,
            local_wdata => ddr_local_wdata,
            local_wdata_req => ddr_local_wdata_req,
            local_write_req => ddr_local_write_req,
            reset_n => soft_reset_reg2_n,
            resynch_clk => dedicated_resynch_or_capture_clk,
            write_clk => write_clk
    );

  --<< END MEGAWIZARD INSERT WRAPPER_NAME

  --<< START MEGAWIZARD INSERT CS_ADDR_MAP
  --connect up the column address bits
  ddr_local_addr(6 DOWNTO 0) <= ddr_local_col_addr(7 DOWNTO 1);
  --<< END MEGAWIZARD INSERT CS_ADDR_MAP

  --<< START MEGAWIZARD INSERT EXAMPLE_DRIVER
  --Self-test, synthesisable code to exercise the DDR SDRAM Controller
  driver : ddrtst_example_driver
    port map(
            clk => clk,
            local_bank_addr => ddr_local_addr(20 DOWNTO 19),
            local_be => ddr_local_be,
            local_col_addr => ddr_local_col_addr,
            local_cs_addr => ddr_local_cs_addr,
            local_rdata => ddr_local_rdata,
            local_rdata_valid => ddr_local_rdata_valid,
            local_read_req => ddr_local_read_req,
            local_ready => ddr_local_ready,
            local_row_addr => ddr_local_addr(18 DOWNTO 7),
            local_size => ddr_local_size,
            local_wdata => ddr_local_wdata,
            local_wdata_req => ddr_local_wdata_req,
            local_write_req => ddr_local_write_req,
            pnf_per_byte => internal_pnf_per_byte,
            pnf_persist => internal_pnf,
            reset_n => soft_reset_reg2_n,
            test_complete => internal_test_complete
    );

  --<< END MEGAWIZARD INSERT EXAMPLE_DRIVER

  --<< START MEGAWIZARD INSERT PLL
  process (clk, pll_locked)
  begin
    if pll_locked = '0' then
      soft_reset_reg_n <= std_logic'('0');
      soft_reset_reg2_n <= std_logic'('0');
    elsif clk'event and clk = '1' then
      soft_reset_reg_n <= std_logic'('1');
      soft_reset_reg2_n <= soft_reset_reg_n;
    end if;

  end process;

  pll_reset <= NOT(reset_n);
  g_cyclonepll_ddr_pll_inst : ddr_pll_cycloneii
    port map(
            areset => pll_reset,
            c0 => clk,
            c1 => write_clk,
            c2 => dedicated_resynch_or_capture_clk,
            inclk0 => clock_source,
            locked => pll_locked
    );

  --<< END MEGAWIZARD INSERT PLL

  --<< START MEGAWIZARD INSERT DLL

  --<< END MEGAWIZARD INSERT DLL

  --<< START MEGAWIZARD INSERT DQS_REF_CLK
  --   No reference clock required in non-DQS mode
  --<< END MEGAWIZARD INSERT DQS_REF_CLK

  --<< start europa
  --vhdl renameroo for output signals
  clk_to_sdram <= internal_clk_to_sdram;
  --vhdl renameroo for output signals
  clk_to_sdram_n <= internal_clk_to_sdram_n;
  --vhdl renameroo for output signals
  ddr_a <= internal_ddr_a;
  --vhdl renameroo for output signals
  ddr_ba <= internal_ddr_ba;
  --vhdl renameroo for output signals
  ddr_cas_n <= internal_ddr_cas_n;
  --vhdl renameroo for output signals
  ddr_cke <= internal_ddr_cke;
  --vhdl renameroo for output signals
  ddr_cs_n <= internal_ddr_cs_n;
  --vhdl renameroo for output signals
  ddr_dm <= internal_ddr_dm;
  --vhdl renameroo for output signals
  ddr_ras_n <= internal_ddr_ras_n;
  --vhdl renameroo for output signals
  ddr_we_n <= internal_ddr_we_n;
  --vhdl renameroo for output signals
  pnf <= internal_pnf;
  --vhdl renameroo for output signals
  pnf_per_byte <= internal_pnf_per_byte;
  --vhdl renameroo for output signals
  test_complete <= internal_test_complete;

end europa;

