##Work-flow of adding the hardware counter to your system##

1. [Vivado] **Package a counter IP with the [code](https://github.com/Hilx/AXI-Peripherals/tree/master/MyCounter/MyCounter%20IP%20HDL)**
2. [Vivado] **Add the packaged IP to your system.**If an ARM core exists, make sure the counter IP's slave is connected to the processing core's master. The counter IP will be accessed by other FPGA IP's masters as well.
3. [Vivado HLS] **Add the [MyCounter.h](https://github.com/Hilx/AXI-Peripherals/tree/master/MyCounter/Application%20HLS%20Example) to your HLS design.** 
4. [Vivado HLS] **In MyCounter.h, change COUNTER_BASE's value** to the correct value which you could find in the address editor after step 2 is done.
5. [Vivado HLS] **Insert the counter start/stop commands in your design.**
6. [Vivado HLS] **Compile & Generate IP.**
7. [Vivado] **Update IPs, Re-syn,implement & Generate Bitstream.**
8. [Software Processor eg.ARM core] **Add [MyCounter.h](https://github.com/Hilx/AXI-Peripherals/blob/master/MyCounter/ARM%20software%20Example/MyCounter.h) to your software application.**
9. **:)**

## HOW TO USE ##

**To read the counter result out, read Reg1 (Base + 1)** Note that, the offset could be 1 or 4 depends on the offset format.

**To control the counter, write to Reg0 (Base + 0)**

**Command** ------- **||** ------- **Value**

Start Counter ------- **||** ------ **1** 

Stop Counter ------- **||** ------- **2** 

Reset Counter ------- **||** ------ **3**

**NOTE**

updated: 18 Dec 2017

For the first use, simply START the counter then STOP it, RESET THE COUNTER IN THE END!

If counter is reseted first, there might be an error... I shall look into this to make this more robust.
