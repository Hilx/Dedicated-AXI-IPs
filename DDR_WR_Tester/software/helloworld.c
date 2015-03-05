/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* XILINX CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_cache.h"


#define BASE 0x43C00000
#define ADDR 0 //0
#define WRITE_DATA 4 //1
#define COMMAND 8 //2
#define READ_DATA 12 //3
#define STATUS 16 //4
#define START 20 //5
#define TRIAL 24 //6

/* Definitions for peripheral PS7_DDR_0 */
#define BASEADDR 0x00000000
#define HIGHADDR 0x1FFFFFFF

void print(char *str);

int main()
{
	int done_bit;
	int readback;
	int address;
	int content;

	done_bit = 0;


    init_platform();
    disable_caches();
    Xil_DCacheDisable();

    print("What's up World\n\r");


    address = 0x10000004;

    Xil_Out32(address,0x44446680);

    content = 0x12347777;

    Xil_Out32(BASE + COMMAND,0x00000001);
 //   Xil_Out32(BASE + WRITE_DATA,content);
    Xil_Out32(BASE + ADDR, address);

    Xil_Out32(BASE + START, 0); // start

    while(Xil_In32(BASE + STATUS) == 0){
    	print("READING DONE BIT in loop\n");
    }

    print("\nREADING FROM DDR\n");
    readback = Xil_In32(address);
    putnum(readback);

    print("\nREADING FROM FPGA\n");
    readback = Xil_In32(BASE+12);
    putnum(readback);





/*
    Xil_Out32(BASE + COMMAND, 0); // command = write
    Xil_Out32(BASE + WRITE_DATA, content); // data to be written to ddr
    Xil_Out32(BASE + ADDR, address); // address in ddr
    Xil_Out32(BASE + START, 0); // address in ddr

    while(done_bit == 0){
    	print("READING DONE BIT\n");
    	done_bit = Xil_In32(BASE + STATUS);
    	putnum(done_bit);
    }

*/
 /*   Xil_Out32(address,content);


    Xil_Out32(BASE + COMMAND, 1); // command = read
 //   Xil_Out32(BASE + WRITE_DATA, content); // data to be written to ddr
    Xil_Out32(BASE + ADDR, address); // address in ddr
    Xil_Out32(BASE + START, 0); // address in ddr

    while(done_bit == 0){
    	print("READING DONE BIT\n");
    	done_bit = Xil_In32(BASE + STATUS);
    	putnum(done_bit);
    }
*/

    /*
    print("\nREADING FROM FPGA\n");
    readback = Xil_In32(BASE + READ_DATA);
    putnum(readback);
*/



/*
    //check if the read happened
    print("\nREADING FROM DDR TO VERIFY THE CONTENT WRITTEN\n");
    readback = Xil_In32(address);
    putnum(readback);
*/


    return 0;
}
