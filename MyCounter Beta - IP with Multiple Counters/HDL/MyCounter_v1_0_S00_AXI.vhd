LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY MyCounter_v1_0_S00_AXI IS
  GENERIC (
    -- Users to add parameters here

    -- User parameters ends
    -- Do not modify the parameters beyond this line

    -- Width of S_AXI data bus
    C_S_AXI_DATA_WIDTH : integer := 32;
    -- Width of S_AXI address bus
    C_S_AXI_ADDR_WIDTH : integer := 4
    );
  PORT (
    -- Users to add ports here

    -- User ports ends
    -- Do not modify the ports beyond this line

    -- Global Clock Signal
    S_AXI_ACLK    : IN  std_logic;
    -- Global Reset Signal. This Signal is Active LOW
    S_AXI_ARESETN : IN  std_logic;
    -- Write address (issued by master, acceped by Slave)
    S_AXI_AWADDR  : IN  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0);
    -- Write channel Protection type. This signal indicates the
    -- privilege and security level of the transaction, and whether
    -- the transaction is a data access or an instruction access.
    S_AXI_AWPROT  : IN  std_logic_vector(2 DOWNTO 0);
    -- Write address valid. This signal indicates that the master signaling
    -- valid write address and control information.
    S_AXI_AWVALID : IN  std_logic;
    -- Write address ready. This signal indicates that the slave is ready
    -- to accept an address and associated control signals.
    S_AXI_AWREADY : OUT std_logic;
    -- Write data (issued by master, acceped by Slave) 
    S_AXI_WDATA   : IN  std_logic_vector(C_S_AXI_DATA_WIDTH-1 DOWNTO 0);
    -- Write strobes. This signal indicates which byte lanes hold
    -- valid data. There is one write strobe bit for each eight
    -- bits of the write data bus.    
    S_AXI_WSTRB   : IN  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 DOWNTO 0);
    -- Write valid. This signal indicates that valid write
    -- data and strobes are available.
    S_AXI_WVALID  : IN  std_logic;
    -- Write ready. This signal indicates that the slave
    -- can accept the write data.
    S_AXI_WREADY  : OUT std_logic;
    -- Write response. This signal indicates the status
    -- of the write transaction.
    S_AXI_BRESP   : OUT std_logic_vector(1 DOWNTO 0);
    -- Write response valid. This signal indicates that the channel
    -- is signaling a valid write response.
    S_AXI_BVALID  : OUT std_logic;
    -- Response ready. This signal indicates that the master
    -- can accept a write response.
    S_AXI_BREADY  : IN  std_logic;
    -- Read address (issued by master, acceped by Slave)
    S_AXI_ARADDR  : IN  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0);
    -- Protection type. This signal indicates the privilege
    -- and security level of the transaction, and whether the
    -- transaction is a data access or an instruction access.
    S_AXI_ARPROT  : IN  std_logic_vector(2 DOWNTO 0);
    -- Read address valid. This signal indicates that the channel
    -- is signaling valid read address and control information.
    S_AXI_ARVALID : IN  std_logic;
    -- Read address ready. This signal indicates that the slave is
    -- ready to accept an address and associated control signals.
    S_AXI_ARREADY : OUT std_logic;
    -- Read data (issued by slave)
    S_AXI_RDATA   : OUT std_logic_vector(C_S_AXI_DATA_WIDTH-1 DOWNTO 0);
    -- Read response. This signal indicates the status of the
    -- read transfer.
    S_AXI_RRESP   : OUT std_logic_vector(1 DOWNTO 0);
    -- Read valid. This signal indicates that the channel is
    -- signaling the required read data.
    S_AXI_RVALID  : OUT std_logic;
    -- Read ready. This signal indicates that the master can
    -- accept the read data and response information.
    S_AXI_RREADY  : IN  std_logic
    );
END MyCounter_v1_0_S00_AXI;

ARCHITECTURE arch_imp OF MyCounter_v1_0_S00_AXI IS

  TYPE counter_state_t IS (c_idle, c_counting, c_freeze);

  -- /* new Counter Signals */
  -- [TYPE]counter themselves 
  TYPE counter_t IS ARRAY(1 TO 16) OF integer;
  -- [TYPE]arrays of state machines TYPE
  TYPE state_machine_t IS ARRAY(1 TO 16) OF counter_state_t;
  -- [TYPE]state machines control signal arrays TYPE
  TYPE control_t IS ARRAY(1 TO 16) OF std_logic;
  -- [SIGNAL]
  SIGNAL timer                                : counter_t;
  SIGNAL timer_state, timer_state_next        : state_machine_t;
  SIGNAL timer_start, timer_stop, timer_reset : control_t;

  -- AXI4LITE signals
  SIGNAL axi_awaddr  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0);
  SIGNAL axi_awready : std_logic;
  SIGNAL axi_wready  : std_logic;
  SIGNAL axi_bresp   : std_logic_vector(1 DOWNTO 0);
  SIGNAL axi_bvalid  : std_logic;
  SIGNAL axi_araddr  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0);
  SIGNAL axi_arready : std_logic;
  SIGNAL axi_rdata   : std_logic_vector(C_S_AXI_DATA_WIDTH-1 DOWNTO 0);
  SIGNAL axi_rresp   : std_logic_vector(1 DOWNTO 0);
  SIGNAL axi_rvalid  : std_logic;

  -- Example-specific design signals
  -- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
  -- ADDR_LSB is used for addressing 32/64 bit registers/memories
  -- ADDR_LSB = 2 for 32 bits (n downto 2)
  -- ADDR_LSB = 3 for 64 bits (n downto 3)
  CONSTANT ADDR_LSB          : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
  CONSTANT OPT_MEM_ADDR_BITS : integer := 1;
  ------------------------------------------------
  ---- Signals for user logic register space example
  --------------------------------------------------
  ---- Number of Slave Registers 4
  SIGNAL slv_reg0            : std_logic_vector(C_S_AXI_DATA_WIDTH-1 DOWNTO 0);
  SIGNAL slv_reg1            : std_logic_vector(C_S_AXI_DATA_WIDTH-1 DOWNTO 0);
  SIGNAL slv_reg2            : std_logic_vector(C_S_AXI_DATA_WIDTH-1 DOWNTO 0);
  SIGNAL slv_reg3            : std_logic_vector(C_S_AXI_DATA_WIDTH-1 DOWNTO 0);
  SIGNAL slv_reg_rden        : std_logic;
  SIGNAL slv_reg_wren        : std_logic;
  SIGNAL reg_data_out        : std_logic_vector(C_S_AXI_DATA_WIDTH-1 DOWNTO 0);
  SIGNAL byte_index          : integer;

BEGIN
  -- I/O Connections assignments

  S_AXI_AWREADY <= axi_awready;
  S_AXI_WREADY  <= axi_wready;
  S_AXI_BRESP   <= axi_bresp;
  S_AXI_BVALID  <= axi_bvalid;
  S_AXI_ARREADY <= axi_arready;
  S_AXI_RDATA   <= axi_rdata;
  S_AXI_RRESP   <= axi_rresp;
  S_AXI_RVALID  <= axi_rvalid;
  -- Implement axi_awready generation
  -- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
  -- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
  -- de-asserted when reset is low.

  PROCESS (S_AXI_ACLK)
  BEGIN
    IF rising_edge(S_AXI_ACLK) THEN
      IF S_AXI_ARESETN = '0' THEN
        axi_awready <= '0';
      ELSE
        IF (axi_awready = '0' AND S_AXI_AWVALID = '1' AND S_AXI_WVALID = '1') THEN
          -- slave is ready to accept write address when
          -- there is a valid write address and write data
          -- on the write address and data bus. This design 
          -- expects no outstanding transactions. 
          axi_awready <= '1';
        ELSE
          axi_awready <= '0';
        END IF;
      END IF;
    END IF;
  END PROCESS;

  -- Implement axi_awaddr latching
  -- This process is used to latch the address when both 
  -- S_AXI_AWVALID and S_AXI_WVALID are valid. 

  PROCESS (S_AXI_ACLK)
  BEGIN
    IF rising_edge(S_AXI_ACLK) THEN
      IF S_AXI_ARESETN = '0' THEN
        axi_awaddr <= (OTHERS => '0');
      ELSE
        IF (axi_awready = '0' AND S_AXI_AWVALID = '1' AND S_AXI_WVALID = '1') THEN
          -- Write Address latching
          axi_awaddr <= S_AXI_AWADDR;
        END IF;
      END IF;
    END IF;
  END PROCESS;

  -- Implement axi_wready generation
  -- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
  -- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
  -- de-asserted when reset is low. 

  PROCESS (S_AXI_ACLK)
  BEGIN
    IF rising_edge(S_AXI_ACLK) THEN
      IF S_AXI_ARESETN = '0' THEN
        axi_wready <= '0';
      ELSE
        IF (axi_wready = '0' AND S_AXI_WVALID = '1' AND S_AXI_AWVALID = '1') THEN
          -- slave is ready to accept write data when 
          -- there is a valid write address and write data
          -- on the write address and data bus. This design 
          -- expects no outstanding transactions.           
          axi_wready <= '1';
        ELSE
          axi_wready <= '0';
        END IF;
      END IF;
    END IF;
  END PROCESS;

  -------------------------------------------------------------------------
  -------------------------------------------------------------------------
  -------------------------------------------------------------------------
  -------------------------------------------------------------------------
  --------------------------------WRITING----------------------------------
  -------------------------------------------------------------------------
  -------------------------------------------------------------------------
  -------------------------------------------------------------------------
  -------------------------------------------------------------------------     
  -- Implement memory mapped register select and write logic generation
  -- The write data is accepted and written to memory mapped registers when
  -- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
  -- select byte enables of slave registers while writing.
  -- These registers are cleared when reset (active low) is applied.
  -- Slave register write enable is asserted when valid address and data are available
  -- and the slave is ready to accept the write address and write data.
  slv_reg_wren <= axi_wready AND S_AXI_WVALID AND axi_awready AND S_AXI_AWVALID;

  PROCESS (S_AXI_ACLK)
    
    VARIABLE loc_index : integer;
  BEGIN
    IF rising_edge(S_AXI_ACLK) THEN
      IF S_AXI_ARESETN = '0' THEN
        FOR i IN 1 TO 16 LOOP
          timer_start(i) <= '0';
          timer_stop(i)  <= '0';
          timer_reset(i) <= '0';
        END LOOP;
      ELSE
        loc_index := (to_integer(unsigned(axi_awaddr)) + 1);
        IF (slv_reg_wren = '1') THEN
          
          CASE S_AXI_WDATA(1 DOWNTO 0) IS
            WHEN "01" =>                -- start 
              timer_reset(loc_index) <= '0';
              timer_start(loc_index) <= '1';
              timer_stop(loc_index)  <= '0';
            WHEN "10" =>                -- stop
              timer_reset(loc_index) <= '0';
              timer_start(loc_index) <= '0';
              timer_stop(loc_index)  <= '1';
            WHEN "11" =>                -- reset
              timer_reset(loc_index) <= '1';
              timer_start(loc_index) <= '0';
              timer_stop(loc_index)  <= '0';
            WHEN OTHERS => NULL;
          END CASE;
        END IF;
      END IF;
    END IF;
  END PROCESS;

  -- Implement write response logic generation
  -- The write response and response valid signals are asserted by the slave 
  -- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
  -- This marks the acceptance of address and indicates the status of 
  -- write transaction.

  PROCESS (S_AXI_ACLK)
  BEGIN
    IF rising_edge(S_AXI_ACLK) THEN
      IF S_AXI_ARESETN = '0' THEN
        axi_bvalid <= '0';
        axi_bresp  <= "00";             --need to work more on the responses
      ELSE
        IF (axi_awready = '1' AND S_AXI_AWVALID = '1' AND axi_wready = '1' AND S_AXI_WVALID = '1' AND axi_bvalid = '0') THEN
          axi_bvalid <= '1';
          axi_bresp  <= "00";
        ELSIF (S_AXI_BREADY = '1' AND axi_bvalid = '1') THEN  --check if bready is asserted while bvalid is high)
          axi_bvalid <= '0';  -- (there is a possibility that bready is always asserted high)
        END IF;
      END IF;
    END IF;
  END PROCESS;

  -- Implement axi_arready generation
  -- axi_arready is asserted for one S_AXI_ACLK clock cycle when
  -- S_AXI_ARVALID is asserted. axi_awready is 
  -- de-asserted when reset (active low) is asserted. 
  -- The read address is also latched when S_AXI_ARVALID is 
  -- asserted. axi_araddr is reset to zero on reset assertion.

  PROCESS (S_AXI_ACLK)
  BEGIN
    IF rising_edge(S_AXI_ACLK) THEN
      IF S_AXI_ARESETN = '0' THEN
        axi_arready <= '0';
        axi_araddr  <= (OTHERS => '1');
      ELSE
        IF (axi_arready = '0' AND S_AXI_ARVALID = '1') THEN
          -- indicates that the slave has acceped the valid read address
          axi_arready <= '1';
          -- Read Address latching 
          axi_araddr  <= S_AXI_ARADDR;
        ELSE
          axi_arready <= '0';
        END IF;
      END IF;
    END IF;
  END PROCESS;

  -- Implement axi_arvalid generation
  -- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
  -- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
  -- data are available on the axi_rdata bus at this instance. The 
  -- assertion of axi_rvalid marks the validity of read data on the 
  -- bus and axi_rresp indicates the status of read transaction.axi_rvalid 
  -- is deasserted on reset (active low). axi_rresp and axi_rdata are 
  -- cleared to zero on reset (active low).  
  PROCESS (S_AXI_ACLK)
  BEGIN
    IF rising_edge(S_AXI_ACLK) THEN
      IF S_AXI_ARESETN = '0' THEN
        axi_rvalid <= '0';
        axi_rresp  <= "00";
      ELSE
        IF (axi_arready = '1' AND S_AXI_ARVALID = '1' AND axi_rvalid = '0') THEN
          -- Valid read data is available at the read data bus
          axi_rvalid <= '1';
          axi_rresp  <= "00";           -- 'OKAY' response
        ELSIF (axi_rvalid = '1' AND S_AXI_RREADY = '1') THEN
          -- Read data is accepted by the master
          axi_rvalid <= '0';
        END IF;
      END IF;
    END IF;
  END PROCESS;

  -------------------------------------------------------------------------
  -------------------------------------------------------------------------
  -------------------------------------------------------------------------
  -------------------------------------------------------------------------
  --------------------------------READING----------------------------------
  -------------------------------------------------------------------------
  -------------------------------------------------------------------------
  -------------------------------------------------------------------------
  -------------------------------------------------------------------------     
  -- Implement memory mapped register select and read logic generation
  -- Slave register read enable is asserted when valid address is available
  -- and the slave is ready to accept the read address.
  slv_reg_rden <= axi_arready AND S_AXI_ARVALID AND (NOT axi_rvalid);

  PROCESS (timer, axi_araddr, S_AXI_ARESETN, slv_reg_rden)
    VARIABLE loc_index : integer;
  BEGIN
    -- Address decoding for reading registers
    loc_index    := (to_integer(unsigned(axi_araddr)) + 1);
    reg_data_out <= std_logic_vector(to_unsigned(timer(loc_index), 32));
  END PROCESS;

  -- Output register or memory read data
  PROCESS(S_AXI_ACLK) IS
  BEGIN
    IF (rising_edge (S_AXI_ACLK)) THEN
      IF (S_AXI_ARESETN = '0') THEN
        axi_rdata <= (OTHERS => '0');
      ELSE
        IF (slv_reg_rden = '1') THEN
          -- When there is a valid read address (S_AXI_ARVALID) with 
          -- acceptance of read address by the slave (axi_arready), 
          -- output the read dada 
          -- Read address mux
          axi_rdata <= reg_data_out;    -- register read data
        END IF;
      END IF;
    END IF;
  END PROCESS;


  -- Add user logic here

  timer_comb : PROCESS(timer_state, timer_start, timer_stop, timer_reset)
  BEGIN
    FOR i IN 1 TO 16 LOOP
      
      timer_state_next(i) <= c_idle;
      CASE timer_state(i) IS
        WHEN c_idle =>
          timer_state_next(i) <= c_idle;
          IF timer_start(i) = '1' THEN
            timer_state_next(i) <= c_counting;
          END IF;
        WHEN c_counting =>
          timer_state_next(i) <= c_counting;
          IF timer_stop(i) = '1' THEN
            timer_state_next(i) <= c_freeze;
          END IF;
        WHEN c_freeze =>
          timer_state_next(i) <= c_freeze;
          IF timer_reset(i) = '1' THEN
            timer_state_next(i) <= c_idle;
          END IF;
        WHEN OTHERS => NULL;
      END CASE;
    END LOOP;
    
  END PROCESS;


  timer_reg : PROCESS
  BEGIN
    WAIT UNTIL S_AXI_ACLK'event AND S_AXI_ACLK = '1';
    FOR i IN 1 TO 16 LOOP
      
      timer_state(i) <= timer_state_next(i);

      IF S_AXI_ARESETN = '0' THEN       -- system reset, active low
        timer_state(i) <= c_idle;
      ELSE
        CASE timer_state(i) IS
          WHEN c_idle =>
            timer(i) <= 0;
          WHEN c_counting =>
            timer(i) <= timer(i) + 1;
          WHEN c_freeze =>
            NULL;
          WHEN OTHERS => NULL;
        END CASE;
      END IF;

    END LOOP;
  END PROCESS;

END arch_imp;
