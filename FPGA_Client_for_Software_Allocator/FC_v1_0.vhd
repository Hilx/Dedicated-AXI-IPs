library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FC_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface FCSlave
		C_FCSlave_DATA_WIDTH	: integer	:= 32;
		C_FCSlave_ADDR_WIDTH	: integer	:= 5
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface FCSlave
		fcslave_aclk	: in std_logic;
		fcslave_aresetn	: in std_logic;
		fcslave_awaddr	: in std_logic_vector(C_FCSlave_ADDR_WIDTH-1 downto 0);
		fcslave_awprot	: in std_logic_vector(2 downto 0);
		fcslave_awvalid	: in std_logic;
		fcslave_awready	: out std_logic;
		fcslave_wdata	: in std_logic_vector(C_FCSlave_DATA_WIDTH-1 downto 0);
		fcslave_wstrb	: in std_logic_vector((C_FCSlave_DATA_WIDTH/8)-1 downto 0);
		fcslave_wvalid	: in std_logic;
		fcslave_wready	: out std_logic;
		fcslave_bresp	: out std_logic_vector(1 downto 0);
		fcslave_bvalid	: out std_logic;
		fcslave_bready	: in std_logic;
		fcslave_araddr	: in std_logic_vector(C_FCSlave_ADDR_WIDTH-1 downto 0);
		fcslave_arprot	: in std_logic_vector(2 downto 0);
		fcslave_arvalid	: in std_logic;
		fcslave_arready	: out std_logic;
		fcslave_rdata	: out std_logic_vector(C_FCSlave_DATA_WIDTH-1 downto 0);
		fcslave_rresp	: out std_logic_vector(1 downto 0);
		fcslave_rvalid	: out std_logic;
		fcslave_rready	: in std_logic
	);
end FC_v1_0;

architecture arch_imp of FC_v1_0 is

	-- component declaration
	component FC_v1_0_FCSlave is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 5
		);
		port (
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component FC_v1_0_FCSlave;

begin

-- Instantiation of Axi Bus Interface FCSlave
FC_v1_0_FCSlave_inst : FC_v1_0_FCSlave
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_FCSlave_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_FCSlave_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK	=> fcslave_aclk,
		S_AXI_ARESETN	=> fcslave_aresetn,
		S_AXI_AWADDR	=> fcslave_awaddr,
		S_AXI_AWPROT	=> fcslave_awprot,
		S_AXI_AWVALID	=> fcslave_awvalid,
		S_AXI_AWREADY	=> fcslave_awready,
		S_AXI_WDATA	=> fcslave_wdata,
		S_AXI_WSTRB	=> fcslave_wstrb,
		S_AXI_WVALID	=> fcslave_wvalid,
		S_AXI_WREADY	=> fcslave_wready,
		S_AXI_BRESP	=> fcslave_bresp,
		S_AXI_BVALID	=> fcslave_bvalid,
		S_AXI_BREADY	=> fcslave_bready,
		S_AXI_ARADDR	=> fcslave_araddr,
		S_AXI_ARPROT	=> fcslave_arprot,
		S_AXI_ARVALID	=> fcslave_arvalid,
		S_AXI_ARREADY	=> fcslave_arready,
		S_AXI_RDATA	=> fcslave_rdata,
		S_AXI_RRESP	=> fcslave_rresp,
		S_AXI_RVALID	=> fcslave_rvalid,
		S_AXI_RREADY	=> fcslave_rready
	);

	-- Add user logic here

	-- User logic ends

end arch_imp;
