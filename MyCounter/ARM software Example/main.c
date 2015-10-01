#include <stdio.h>
#include "platform.h"
#include "MyCounter.h"

#define MMU_BASE 0x43C00000 // change this to your SysAlloc base address
#define MMU_TOKEN 0
#define MMU_STATUS 4
#define MMU_RESULT 8
#define MMU_CMD 12
#define MMU_FREE 16

void print(char *str);

int hw_malloc(int address);
void hw_mfree(int address);
void init_ddr(void);


typedef volatile int data_t;
typedef volatile int ptr_t;
typedef volatile unsigned next_t;

#define LIST_CORE_BASE 0x43C20000

// struct info
struct node_t{
	data_t data;
	next_t next;
};

int main()
{
    init_platform();
    print("Hello World\n\r");

	// Starting your HLS IP
    Xil_Out32(LIST_CORE_BASE,1);
    int i,j;
    j=0;
    for(i = 0; i < 16000; i++){
    	j ++;
    }
    j=0;
    for(i = 0; i < 16000; i++){
    	j ++;
    }

    int returned_value;
    returned_value = Xil_In32(LIST_CORE_BASE + 0x10);
    putnum(returned_value);

	
    /*---------------- counter stuff------------------- */
	// Let's see the performance of your HLS IP!
    int timed_result;
    print("\ntiming result: ");
    timed_result = Xil_In32(COUNTER_BASE+COUNTER_RESULT);
    putnum(timed_result);
	
    //reset counter and check if the counter has value 0
    Xil_Out32(COUNTER_BASE,C_RESET);
    print("\nafter reset, counter value: ");
    timed_result = Xil_In32(COUNTER_BASE+COUNTER_RESULT);
    putnum(timed_result);

    // Let's try start & stop the timer from software now:)
    Xil_Out32(COUNTER_BASE,C_START);
    for(i = 1; i<100; i++){
    	j = 1+i;
    }
    Xil_Out32(COUNTER_BASE,C_STOP);
    print("\ntiming result of that software loop: ");
    timed_result = Xil_In32(COUNTER_BASE+COUNTER_RESULT);
    putnum(timed_result);

    cleanup_platform();
    return 0;
}