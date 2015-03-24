LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- MASTER
ENTITY fcore_v1_0_M00_AXI IS
  GENERIC (
    -- Users to add parameters here

    -- User parameters ends
    -- Do not modify the parameters beyond this line

    -- The master will start generating data from the C_M_START_DATA_VALUE value
    C_M_START_DATA_VALUE       : std_logic_vector := x"AA000000";
    -- The master requires a target slave base address.
    -- The master will initiate read and write transactions on the slave with base address specified here as a parameter.
    C_M_TARGET_SLAVE_BASE_ADDR : std_logic_vector := x"40000000";
    -- Width of M_AXI address bus. 
    -- The master generates the read and write addresses of width specified as C_M_AXI_ADDR_WIDTH.
    C_M_AXI_ADDR_WIDTH         : integer          := 32;
    -- Width of M_AXI data bus. 
    -- The master issues write data and accept read data where the width of the data bus is C_M_AXI_DATA_WIDTH
    C_M_AXI_DATA_WIDTH         : integer          := 32;
    -- Transaction number is the number of write 
    -- and read transactions the master will perform as a part of this example memory test.
    C_M_TRANSACTIONS_NUM       : integer          := 4
    );
  PORT (
    -- Users to add ports here
    CtrThd          : IN  std_logic_vector(31 DOWNTO 0);
    NumReq          : IN  std_logic_vector(31 DOWNTO 0);
    MmuBase         : IN  std_logic_vector(31 DOWNTO 0);
    TimerBack       : OUT std_logic_vector(31 DOWNTO 0);
    info_valid      : IN  std_logic;
    readcount       : IN  std_logic_vector(5 DOWNTO 0);
    ReqResultBack   : OUT std_logic_vector(31 DOWNTO 0);
    readresultcount : IN  std_logic_vector(5 DOWNTO 0);
    allocation_size : IN  std_logic_vector(31 DOWNTO 0);
    -- User ports ends
    -- Do not modify the ports beyond this line

    -- Initiate AXI transactions
    --   INIT_AXI_TXN  : in  std_logic;
    -- Asserts when ERROR is detected
    error         : OUT std_logic;
    -- Asserts when AXI transactions is complete
    TXN_DONE      : OUT std_logic;
    -- AXI clock signal
    M_AXI_ACLK    : IN  std_logic;
    -- AXI active low reset signal
    M_AXI_ARESETN : IN  std_logic;
    -- Master Interface Write Address Channel ports. Write address (issued by master)
    M_AXI_AWADDR  : OUT std_logic_vector(C_M_AXI_ADDR_WIDTH-1 DOWNTO 0);
    -- Write channel Protection type.
    -- This signal indicates the privilege and security level of the transaction,
    -- and whether the transaction is a data access or an instruction access.
    M_AXI_AWPROT  : OUT std_logic_vector(2 DOWNTO 0);
    -- Write address valid. 
    -- This signal indicates that the master signaling valid write address and control information.
    M_AXI_AWVALID : OUT std_logic;
    -- Write address ready. 
    -- This signal indicates that the slave is ready to accept an address and associated control signals.
    M_AXI_AWREADY : IN  std_logic;
    -- Master Interface Write Data Channel ports. Write data (issued by master)
    M_AXI_WDATA   : OUT std_logic_vector(C_M_AXI_DATA_WIDTH-1 DOWNTO 0);
    -- Write strobes. 
    -- This signal indicates which byte lanes hold valid data.
    -- There is one write strobe bit for each eight bits of the write data bus.
    M_AXI_WSTRB   : OUT std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 DOWNTO 0);
    -- Write valid. This signal indicates that valid write data and strobes are available.
    M_AXI_WVALID  : OUT std_logic;
    -- Write ready. This signal indicates that the slave can accept the write data.
    M_AXI_WREADY  : IN  std_logic;
    -- Master Interface Write Response Channel ports. 
    -- This signal indicates the status of the write transaction.
    M_AXI_BRESP   : IN  std_logic_vector(1 DOWNTO 0);
    -- Write response valid. 
    -- This signal indicates that the channel is signaling a valid write response
    M_AXI_BVALID  : IN  std_logic;
    -- Response ready. This signal indicates that the master can accept a write response.
    M_AXI_BREADY  : OUT std_logic;
    -- Master Interface Read Address Channel ports. Read address (issued by master)
    M_AXI_ARADDR  : OUT std_logic_vector(C_M_AXI_ADDR_WIDTH-1 DOWNTO 0);
    -- Protection type. 
    -- This signal indicates the privilege and security level of the transaction, 
    -- and whether the transaction is a data access or an instruction access.
    M_AXI_ARPROT  : OUT std_logic_vector(2 DOWNTO 0);
    -- Read address valid. 
    -- This signal indicates that the channel is signaling valid read address and control information.
    M_AXI_ARVALID : OUT std_logic;
    -- Read address ready. 
    -- This signal indicates that the slave is ready to accept an address and associated control signals.
    M_AXI_ARREADY : IN  std_logic;
    -- Master Interface Read Data Channel ports. Read data (issued by slave)
    M_AXI_RDATA   : IN  std_logic_vector(C_M_AXI_DATA_WIDTH-1 DOWNTO 0);
    -- Read response. This signal indicates the status of the read transfer.
    M_AXI_RRESP   : IN  std_logic_vector(1 DOWNTO 0);
    -- Read valid. This signal indicates that the channel is signaling the required read data.
    M_AXI_RVALID  : IN  std_logic;
    -- Read ready. This signal indicates that the master can accept the read data and response information.
    M_AXI_RREADY  : OUT std_logic
    );
END fcore_v1_0_M00_AXI;

ARCHITECTURE implementation OF fcore_v1_0_M00_AXI IS

  -- new signals
  TYPE FreeData IS ARRAY (0 TO 3) OF std_logic_vector(31 DOWNTO 0);
  SIGNAL FreePointer : FreeData;
  SIGNAL FreeDelay   : FreeData;

  SIGNAL internal_counter, free_internal_counter : integer RANGE 0 TO 4;

  SIGNAL command : unsigned(4 DOWNTO 0);  -- malloc 01100, free 10000

  SIGNAL request_size, request_delay, delay_time : std_logic_vector(31 DOWNTO 0);

  SIGNAL malloc_counter : integer RANGE 0 TO 500;

  -- dummy
  SIGNAL local_data_in : std_logic_vector(31 DOWNTO 0);
  SIGNAL local_wea     : std_logic_vector(0 DOWNTO 0);

  -- My signals

  TYPE timerType IS ARRAY (0 TO 500) OF std_logic_vector(31 DOWNTO 0);
  SIGNAL timerResult : timerType;
  SIGNAL reqcount    : integer RANGE 0 TO 500;

  TYPE resultArrayType IS ARRAY (0 TO 500) OF std_logic_vector(31 DOWNTO 0);
  SIGNAL ResultArray : resultArrayType;

  SIGNAL timerback_i : std_logic_vector(31 DOWNTO 0) := (OTHERS => '0');

  SIGNAL RateCtr_Counter : std_logic_vector(31 DOWNTO 0) := (OTHERS => '0');

  SIGNAL readcase_sel : std_logic_vector(2 DOWNTO 0) := "000";

  SIGNAL readcontent : std_logic_vector(31 DOWNTO 0);


  COMPONENT delayram IS
    PORT (
      clka  : IN  std_logic;
      wea   : IN  std_logic_vector(0 DOWNTO 0);
      addra : IN  std_logic_vector(8 DOWNTO 0);
      dina  : IN  std_logic_vector(31 DOWNTO 0);
      douta : OUT std_logic_vector(31 DOWNTO 0)
      );
  END COMPONENT delayram;

  COMPONENT sizeram IS
    PORT (
      clka  : IN  std_logic;
      wea   : IN  std_logic_vector(0 DOWNTO 0);
      addra : IN  std_logic_vector(8 DOWNTO 0);
      dina  : IN  std_logic_vector(31 DOWNTO 0);
      douta : OUT std_logic_vector(31 DOWNTO 0)
      );
  END COMPONENT sizeram;


  -- function called clogb2 that returns an integer which has the
  -- value of the ceiling of the log base 2
  FUNCTION clogb2 (bit_depth : integer) RETURN integer IS
    VARIABLE depth : integer := bit_depth;
    VARIABLE count : integer := 1;
  BEGIN
    FOR clogb2 IN 1 TO bit_depth LOOP   -- Works for up to 32 bit integers
      IF (bit_depth <= 2) THEN
        count := 1;
      ELSE
        IF(depth <= 1) THEN
          count := count;
        ELSE
          depth := depth / 2;
          count := count + 1;
        END IF;
      END IF;
    END LOOP;
    RETURN(count);
  END;

  -- Example user application signals

  -- TRANS_NUM_BITS is the width of the index counter for
  -- number of write or read transaction..
  CONSTANT TRANS_NUM_BITS : integer := clogb2(C_M_TRANSACTIONS_NUM-1);

  -- Example State machine to initialize counter, initialize write transactions, 
  -- initialize read transactions and comparison of read data with the 
  -- written data words.
  TYPE state IS (INITIAL,
                 IDLE,        -- This state initiates AXI4Lite transaction
                 -- after the state machine changes state to INIT_WRITE
                 -- when there is 0 to 1 transition on INIT_AXI_TXN
                 INIT_WRITE,  -- This state initializes write transaction,
                 -- once writes are done, the state machine 
                 -- changes state to INIT_READ 
                 INIT_READ,   -- This state initializes read transaction
                 -- once reads are done, the state machine 
                 -- changes state to INIT_COMPARE 
                 RTOKEN,
                 RDONE,
                 RRESULT
                 );
  -- of the written data with the read data

  SIGNAL mst_exec_state : state;

  -- AXI4LITE signals
  --write address valid
  SIGNAL axi_awvalid        : std_logic;
  --write data valid
  SIGNAL axi_wvalid         : std_logic;
  --read address valid
  SIGNAL axi_arvalid        : std_logic;
  --read data acceptance
  SIGNAL axi_rready         : std_logic;
  --write response acceptance
  SIGNAL axi_bready         : std_logic;
  --write address
  SIGNAL axi_awaddr         : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 DOWNTO 0);
  --write data
  SIGNAL axi_wdata          : std_logic_vector(C_M_AXI_DATA_WIDTH-1 DOWNTO 0);
  --read addresss
  SIGNAL axi_araddr         : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 DOWNTO 0);
  --Asserts when there is a write response error
  SIGNAL write_resp_error   : std_logic;
  --Asserts when there is a read response error
  SIGNAL read_resp_error    : std_logic;
  --A pulse to initiate a write transaction
  SIGNAL start_single_write : std_logic;
  --A pulse to initiate a read transaction
  SIGNAL start_single_read  : std_logic;
  --Asserts when a single beat write transaction is issued and remains asserted till the completion of write trasaction.
  SIGNAL write_issued       : std_logic;
  --Asserts when a single beat read transaction is issued and remains asserted till the completion of read trasaction.
  SIGNAL read_issued        : std_logic;
  --flag that marks the completion of write trasactions. The number of write transaction is user selected by the parameter C_M_TRANSACTIONS_NUM.
  SIGNAL writes_done        : std_logic;
  --flag that marks the completion of read trasactions. The number of read transaction is user selected by the parameter C_M_TRANSACTIONS_NUM
  SIGNAL reads_done         : std_logic;



BEGIN
  -- I/O Connections assignments

  --Adding the offset address to the base addr of the slave
  M_AXI_AWADDR  <= axi_awaddr;
  --AXI 4 write data
  M_AXI_WDATA   <= axi_wdata;
  M_AXI_AWPROT  <= "000";
  M_AXI_AWVALID <= axi_awvalid;
  --Write Data(W)
  M_AXI_WVALID  <= axi_wvalid;
  --Set all byte strobes in this example
  M_AXI_WSTRB   <= "1111";
  --Write Response (B)
  M_AXI_BREADY  <= axi_bready;
  --Read Address (AR)
  M_AXI_ARADDR  <= axi_araddr;
  M_AXI_ARVALID <= axi_arvalid;
  M_AXI_ARPROT  <= "001";
  --Read and Read Response (R)
  M_AXI_RREADY  <= axi_rready;
  --Example design I/O

  ----------------------
  --Write Address Channel
  ----------------------

  -- The purpose of the write address channel is to request the address and 
  -- command information for the entire transaction.  It is a single beat
  -- of information.

  -- Note for this example the axi_awvalid/axi_wvalid are asserted at the same
  -- time, and then each is deasserted independent from each other.
  -- This is a lower-performance, but simplier control scheme.

  -- AXI VALID signals must be held active until accepted by the partner.

  -- A data transfer is accepted by the slave when a master has
  -- VALID data and the slave acknoledges it is also READY. While the master
  -- is allowed to generated multiple, back-to-back requests by not 
  -- deasserting VALID, this design will add rest cycle for
  -- simplicity.

  -- Since only one outstanding transaction is issued by the user design,
  -- there will not be a collision between a new request and an accepted
  -- request on the same clock cycle. 

  PROCESS(M_AXI_ACLK)
  BEGIN
    IF (rising_edge (M_AXI_ACLK)) THEN
      --Only VALID signals must be deasserted during reset per AXI spec             
      --Consider inverting then registering active-low reset for higher fmax        
      IF (M_AXI_ARESETN = '0') THEN
        axi_awvalid <= '0';
      ELSE
        --Signal a new address/data command is available by user logic              
        IF (start_single_write = '1') THEN
          axi_awvalid <= '1';
        ELSIF (M_AXI_AWREADY = '1' AND axi_awvalid = '1') THEN
          --Address accepted by interconnect/slave (issue of M_AXI_AWREADY by slave)
          axi_awvalid <= '0';
        END IF;
      END IF;
    END IF;
  END PROCESS;

  -- start_single_write triggers a new write                                        
  -- transaction. write_index is a counter to                                       
  -- keep track with number of write transaction                                    
  -- issued/initiated                                                               



  ----------------------
  --Write Data Channel
  ----------------------

  --The write data channel is for transfering the actual data.
  --The data generation is speific to the example design, and 
  --so only the WVALID/WREADY handshake is shown here

  PROCESS(M_AXI_ACLK)
  BEGIN
    IF (rising_edge (M_AXI_ACLK)) THEN
      IF (M_AXI_ARESETN = '0') THEN
        axi_wvalid <= '0';
      ELSE
        IF (start_single_write = '1') THEN
          --Signal a new address/data command is available by user logic        
          axi_wvalid <= '1';
        ELSIF (M_AXI_WREADY = '1' AND axi_wvalid = '1') THEN
          --Data accepted by interconnect/slave (issue of M_AXI_WREADY by slave)
          axi_wvalid <= '0';
        END IF;
      END IF;
    END IF;
  END PROCESS;


  ------------------------------
  --Write Response (B) Channel
  ------------------------------

  --The write response channel provides feedback that the write has committed
  --to memory. BREADY will occur after both the data and the write address
  --has arrived and been accepted by the slave, and can guarantee that no
  --other accesses launched afterwards will be able to be reordered before it.

  --The BRESP bit [1] is used indicate any errors from the interconnect or
  --slave for the entire write burst. This example will capture the error.

  --While not necessary per spec, it is advisable to reset READY signals in
  --case of differing reset latencies between master/slave.

  PROCESS(M_AXI_ACLK)
  BEGIN
    IF (rising_edge (M_AXI_ACLK)) THEN
      IF (M_AXI_ARESETN = '0') THEN
        axi_bready <= '0';
      ELSE
        IF (M_AXI_BVALID = '1' AND axi_bready = '0') THEN
          -- accept/acknowledge bresp with axi_bready by the master    
          -- when M_AXI_BVALID is asserted by slave                    
          axi_bready <= '1';
        ELSIF (axi_bready = '1') THEN
          -- deassert after one clock cycle                            
          axi_bready <= '0';
        END IF;
      END IF;
    END IF;
  END PROCESS;
  --Flag write errors                                                    
  write_resp_error <= (axi_bready AND M_AXI_BVALID AND M_AXI_BRESP(1));


  ------------------------------
  --Read Address Channel
  ------------------------------

  -- A new axi_arvalid is asserted when there is a valid read address              
  -- available by the master. start_single_read triggers a new read                
  -- transaction                                                                   
  PROCESS(M_AXI_ACLK)
  BEGIN
    IF (rising_edge (M_AXI_ACLK)) THEN
      IF (M_AXI_ARESETN = '0') THEN
        axi_arvalid <= '0';
      ELSE
        IF (start_single_read = '1') THEN
          --Signal a new read address command is available by user logic           
          axi_arvalid <= '1';
        ELSIF (M_AXI_ARREADY = '1' AND axi_arvalid = '1') THEN
          --RAddress accepted by interconnect/slave (issue of M_AXI_ARREADY by slave)
          axi_arvalid <= '0';
        END IF;
      END IF;
    END IF;
  END PROCESS;


  ----------------------------------
  --Read Data (and Response) Channel
  ----------------------------------

  --The Read Data channel returns the results of the read request 
  --The master will accept the read data by asserting axi_rready
  --when there is a valid read data available.
  --While not necessary per spec, it is advisable to reset READY signals in
  --case of differing reset latencies between master/slave.

  PROCESS(M_AXI_ACLK)
  BEGIN
    IF (rising_edge (M_AXI_ACLK)) THEN
      IF (M_AXI_ARESETN = '0') THEN
        axi_rready <= '1';
      ELSE
        IF (M_AXI_RVALID = '1' AND axi_rready = '0') THEN
          -- accept/acknowledge rdata/rresp with axi_rready by the master
          -- when M_AXI_RVALID is asserted by slave                      
          axi_rready <= '1';
        ELSIF (axi_rready = '1') THEN
          -- deassert after one clock cycle                             
          axi_rready <= '0';
        END IF;
      END IF;
    END IF;
  END PROCESS;

  --Flag write errors                                                     
  read_resp_error <= (axi_rready AND M_AXI_RVALID AND M_AXI_RRESP(1));


  ----------------------------------
  --User Logic
  ----------------------------------

  --Address/Data Stimulus

  --Address/data pairs for this example. The read and write values should
  --match.
  --Modify these as desired for different address patterns.

  --  Write Addresses                                                               
  PROCESS(MmuBase, command)
  BEGIN
    axi_awaddr <= std_logic_vector(unsigned(MmuBase) + command);
  END PROCESS;

  -- Read Addresses                                                                      
  PROCESS(readcase_sel, MmuBase)
  BEGIN
    
    CASE readcase_sel IS
      WHEN "001" =>                     -- token
        axi_araddr <= MmuBase;
      WHEN "010" =>                     -- donebit
        axi_araddr <= std_logic_vector(unsigned(MmuBase) + 4);
      WHEN "100" =>                     -- result
        axi_araddr <= std_logic_vector(unsigned(MmuBase) + 8);
      WHEN OTHERS => NULL;
    END CASE;

  END PROCESS;

  -- Write data                                                                          
  PROCESS(M_AXI_ACLK)
  BEGIN
    IF (rising_edge (M_AXI_ACLK)) THEN

      --axi_wdata <= allocation_size; --ALLOCATION SIZE
      IF command = "01100" THEN
        axi_wdata <= request_size;
      END IF;
      IF command = "10000" THEN         -- free
        axi_wdata <= FreePointer(free_internal_counter);
      END IF;
      
    END IF;
  END PROCESS;


  --implement master command interface state machine                                           
  MASTER_EXECUTION_PROC : PROCESS(M_AXI_ACLK)
  BEGIN
    IF (rising_edge (M_AXI_ACLK)) THEN
      IF (M_AXI_ARESETN = '0') THEN
        -- reset condition                                                                          
        -- All the signals are ed default values under reset condition                              
        mst_exec_state     <= INITIAL;
        start_single_write <= '0';
        write_issued       <= '0';
        start_single_read  <= '0';
        read_issued        <= '0';
        error              <= '0';
      ELSE
        
        IF (mst_exec_state /= INITIAL) AND (mst_exec_state /= IDLE) THEN
          timerback_i <= std_logic_vector(unsigned(timerback_i)+1);
          IF mst_exec_state = INIT_READ AND reads_done = '1' AND readcase_sel = "100" THEN
            timerResult(reqcount) <= timerback_i;
            timerback_i           <= (OTHERS => '0');
            reqcount              <= reqcount + 1;
            ResultArray(reqcount) <= M_AXI_RDATA;

            IF command = "01100" THEN   -- if malloc
              malloc_counter                <= malloc_counter + 1;
              FreePointer(internal_counter) <= M_AXI_RDATA;  -- keeps pointer
              FreeDelay(internal_counter)   <= request_delay;
              internal_counter              <= internal_counter + 1;  -- increment counter
            END IF;
            IF command = "10000" THEN   -- if free
              free_internal_counter <= free_internal_counter + 1;
            END IF;
          END IF;
        END IF;

        -- state transition                                                                         
        CASE (mst_exec_state) IS
          
          WHEN INITIAL =>
            command               <= "01100";  -- malloc
            free_internal_counter <= 0;
            internal_counter      <= 0;
            reqcount              <= 0;
            malloc_counter        <= 0;
            IF info_valid = '1' THEN
              mst_exec_state <= IDLE;
            END IF;
            
          WHEN IDLE =>
            
            read_issued    <= '0';
            mst_exec_state <= IDLE;

            RateCtr_Counter <= std_logic_vector(unsigned(RateCtr_Counter) + 1);

            IF reqcount = unsigned(NumReq) THEN
              mst_exec_state <= INITIAL;
            --elsif RateCtr_Counter = CtrThd then
            ELSIF RateCtr_Counter = delay_time THEN
              mst_exec_state <= RTOKEN;
            END IF;
            
          WHEN INIT_WRITE =>
            -- This state is responsible to issue start_single_write pulse to                       
            -- initiate a write transaction. Write transactions will be                             
            -- issued until last_write signal is asserted.                                          
            -- write controller                                                                     
            IF (writes_done = '1') THEN
              mst_exec_state <= RDONE;
              -- when write is issued, increment the internal counter
              
            ELSE
              mst_exec_state <= INIT_WRITE;
              
              IF (axi_awvalid = '0' AND axi_wvalid = '0' AND M_AXI_BVALID = '0' AND
                  start_single_write = '0' AND write_issued = '0') THEN          
                start_single_write <= '1';
                write_issued       <= '1';
              ELSE
                start_single_write <= '0';  --Negate to generate a pulse                             
              END IF;
            END IF;
            
          WHEN INIT_READ =>
            -- This state is responsible to issue start_single_read pulse to                        
            -- initiate a read transaction. Read transactions will be                               
            -- issued until last_read signal is asserted.                                           
            -- read controller                                                                      
            IF (reads_done = '1') THEN
              readcontent <= M_AXI_RDATA;
              CASE readcase_sel IS
                WHEN "001" =>           -- token
                  mst_exec_state <= RTOKEN;
                WHEN "010" =>           -- donebit
                  mst_exec_state <= RDONE;
                WHEN "100" =>           -- result
                  mst_exec_state <= IDLE;
                --   mst_exec_state <= INITIAL;  -- FOR NOW
                WHEN OTHERS => NULL;
              END CASE;
            ELSE
              mst_exec_state <= INIT_READ;
              
              IF (axi_arvalid = '0' AND M_AXI_RVALID = '0' AND
                  start_single_read = '0' AND read_issued = '0') THEN                                 
                start_single_read <= '1';
                read_issued       <= '1';
              ELSE
                start_single_read <= '0';  --Negate to generate a pulse                              
              END IF;
            END IF;

          WHEN RTOKEN =>
            read_issued     <= '0';
            readcase_sel    <= "001";
            RateCtr_Counter <= (OTHERS => '0');  -- reset rate control counter
            mst_exec_state  <= INIT_READ;
            IF readcontent(0) = '1' THEN
              mst_exec_state <= INIT_WRITE;
              readcontent    <= (OTHERS => '0');
            END IF;
            
          WHEN RDONE =>
            write_issued   <= '0';
            read_issued    <= '0';
            readcase_sel   <= "010";
            mst_exec_state <= INIT_READ;
            IF readcontent(0) = '1' THEN
              mst_exec_state <= RRESULT;
              readcontent    <= (OTHERS => '0');
            END IF;
          WHEN RRESULT =>
            readcase_sel   <= "100";
            mst_exec_state <= INIT_READ;

          WHEN OTHERS =>
            mst_exec_state <= IDLE;
        END CASE;

        IF internal_counter = 4 and command = "01100" THEN
          -- change command from malloc to free
          command               <= "10000";
          free_internal_counter <= 0;
        END IF;

        IF free_internal_counter = 4 AND command = "10000" THEN
          -- change command from free to malloc
          command          <= "01100";
          internal_counter <= 0;
        END IF;
        
        
      END IF;
    END IF;
  END PROCESS;

  PROCESS(M_AXI_ACLK)
  BEGIN
    IF (rising_edge (M_AXI_ACLK)) THEN
      IF (M_AXI_ARESETN = '0') THEN
        -- reset condition                                                                          
        writes_done <= '0';
      ELSE
        writes_done <= '0';
        IF (M_AXI_BVALID = '1' AND axi_bready = '1') THEN
          --The writes_done should be associated with a bready response                             
          writes_done <= '1';
        END IF;
      END IF;
    END IF;
  END PROCESS;

  PROCESS(M_AXI_ACLK)
  BEGIN
    IF (rising_edge (M_AXI_ACLK)) THEN
      IF (M_AXI_ARESETN = '0') THEN
        reads_done <= '0';
      ELSE
        reads_done <= '0';
        IF (M_AXI_RVALID = '1' AND axi_rready = '1') THEN
          --The reads_done should be associated with a read ready response                          
          reads_done <= '1';
        END IF;
      END IF;
    END IF;
  END PROCESS;

  PROCESS(request_delay, FreeDelay, free_internal_counter, command)
  BEGIN    
    delay_time <= request_delay;
    IF command = "10000" THEN
      delay_time <= FreeDelay(free_internal_counter);
    END IF;
    
  END PROCESS;

  PROCESS(readcount)
  BEGIN
    TimerBack     <= timerResult(to_integer(unsigned(readcount)));
    ReqResultBack <= ResultArray(to_integer(unsigned(readresultcount)));
  END PROCESS;

  -- PORT MAPS

  mydelay : delayram
    PORT MAP(
      clka  => M_AXI_ACLK,
      wea   => local_wea,
      addra => std_logic_vector(to_unsigned(malloc_counter, 9)),
      dina  => local_data_in,
      douta => request_delay
      );

  mysize : sizeram
    PORT MAP(
      clka  => M_AXI_ACLK,
      wea   => local_wea,
      addra => std_logic_vector(to_unsigned(malloc_counter, 9)),
      dina  => local_data_in,
      douta => request_size
      );          


  -- Add user logic here

  -- User logic ends

END implementation;
