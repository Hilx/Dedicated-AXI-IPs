LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY MyCounter_v1_0 IS
  GENERIC (
    -- Users to add parameters here

    -- User parameters ends
    -- Do not modify the parameters beyond this line


    -- Parameters of Axi Slave Bus Interface S00_AXI
    C_S00_AXI_DATA_WIDTH : integer := 32;
    C_S00_AXI_ADDR_WIDTH : integer := 4
    );
  PORT (
    -- Users to add ports here

    -- User ports ends
    -- Do not modify the ports beyond this line


    -- Ports of Axi Slave Bus Interface S00_AXI
    s00_axi_aclk    : IN  std_logic;
    s00_axi_aresetn : IN  std_logic;
    s00_axi_awaddr  : IN  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 DOWNTO 0);
    s00_axi_awprot  : IN  std_logic_vector(2 DOWNTO 0);
    s00_axi_awvalid : IN  std_logic;
    s00_axi_awready : OUT std_logic;
    s00_axi_wdata   : IN  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 DOWNTO 0);
    s00_axi_wstrb   : IN  std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 DOWNTO 0);
    s00_axi_wvalid  : IN  std_logic;
    s00_axi_wready  : OUT std_logic;
    s00_axi_bresp   : OUT std_logic_vector(1 DOWNTO 0);
    s00_axi_bvalid  : OUT std_logic;
    s00_axi_bready  : IN  std_logic;
    s00_axi_araddr  : IN  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 DOWNTO 0);
    s00_axi_arprot  : IN  std_logic_vector(2 DOWNTO 0);
    s00_axi_arvalid : IN  std_logic;
    s00_axi_arready : OUT std_logic;
    s00_axi_rdata   : OUT std_logic_vector(C_S00_AXI_DATA_WIDTH-1 DOWNTO 0);
    s00_axi_rresp   : OUT std_logic_vector(1 DOWNTO 0);
    s00_axi_rvalid  : OUT std_logic;
    s00_axi_rready  : IN  std_logic
    );
END MyCounter_v1_0;

ARCHITECTURE arch_imp OF MyCounter_v1_0 IS

  -- component declaration
  COMPONENT MyCounter_v1_0_S00_AXI IS
    GENERIC (
      C_S_AXI_DATA_WIDTH : integer := 32;
      C_S_AXI_ADDR_WIDTH : integer := 4
      );
    PORT (
      S_AXI_ACLK    : IN  std_logic;
      S_AXI_ARESETN : IN  std_logic;
      S_AXI_AWADDR  : IN  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0);
      S_AXI_AWPROT  : IN  std_logic_vector(2 DOWNTO 0);
      S_AXI_AWVALID : IN  std_logic;
      S_AXI_AWREADY : OUT std_logic;
      S_AXI_WDATA   : IN  std_logic_vector(C_S_AXI_DATA_WIDTH-1 DOWNTO 0);
      S_AXI_WSTRB   : IN  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 DOWNTO 0);
      S_AXI_WVALID  : IN  std_logic;
      S_AXI_WREADY  : OUT std_logic;
      S_AXI_BRESP   : OUT std_logic_vector(1 DOWNTO 0);
      S_AXI_BVALID  : OUT std_logic;
      S_AXI_BREADY  : IN  std_logic;
      S_AXI_ARADDR  : IN  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0);
      S_AXI_ARPROT  : IN  std_logic_vector(2 DOWNTO 0);
      S_AXI_ARVALID : IN  std_logic;
      S_AXI_ARREADY : OUT std_logic;
      S_AXI_RDATA   : OUT std_logic_vector(C_S_AXI_DATA_WIDTH-1 DOWNTO 0);
      S_AXI_RRESP   : OUT std_logic_vector(1 DOWNTO 0);
      S_AXI_RVALID  : OUT std_logic;
      S_AXI_RREADY  : IN  std_logic
      );
  END COMPONENT MyCounter_v1_0_S00_AXI;

BEGIN

-- Instantiation of Axi Bus Interface S00_AXI
  MyCounter_v1_0_S00_AXI_inst : MyCounter_v1_0_S00_AXI
    GENERIC MAP (
      C_S_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
      C_S_AXI_ADDR_WIDTH => C_S00_AXI_ADDR_WIDTH
      )
    PORT MAP (
      S_AXI_ACLK    => s00_axi_aclk,
      S_AXI_ARESETN => s00_axi_aresetn,
      S_AXI_AWADDR  => s00_axi_awaddr,
      S_AXI_AWPROT  => s00_axi_awprot,
      S_AXI_AWVALID => s00_axi_awvalid,
      S_AXI_AWREADY => s00_axi_awready,
      S_AXI_WDATA   => s00_axi_wdata,
      S_AXI_WSTRB   => s00_axi_wstrb,
      S_AXI_WVALID  => s00_axi_wvalid,
      S_AXI_WREADY  => s00_axi_wready,
      S_AXI_BRESP   => s00_axi_bresp,
      S_AXI_BVALID  => s00_axi_bvalid,
      S_AXI_BREADY  => s00_axi_bready,
      S_AXI_ARADDR  => s00_axi_araddr,
      S_AXI_ARPROT  => s00_axi_arprot,
      S_AXI_ARVALID => s00_axi_arvalid,
      S_AXI_ARREADY => s00_axi_arready,
      S_AXI_RDATA   => s00_axi_rdata,
      S_AXI_RRESP   => s00_axi_rresp,
      S_AXI_RVALID  => s00_axi_rvalid,
      S_AXI_RREADY  => s00_axi_rready
      );

  -- Add user logic here

  -- User logic ends

END arch_imp;
