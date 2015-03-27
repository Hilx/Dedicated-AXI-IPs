#include <stdio.h>
#include "platform.h"
#include "xil_cache.h"



#define CSTART 0
#define NUMREQ 4
#define RESULT 8
#define COMMAND 12
#define CONTENT 16
#define READRESET 20
#define LATBACK 24

int FCORE_BASE[15] = {0x43C00000, 0x43C10000, 0x43C20000, 0x43C30000, 0x43C40000,
			          0x43C50000, 0x43C60000, 0x43C70000, 0x43C80000, 0x43C90000,
			          0x43CA0000, 0x43CB0000, 0x43CC0000, 0x43CD0000, 0x43CE0000};

int req_count;
int *pointer_array[15][200];
int malloc_counter[15],free_counter[15];

void print(char *str);

void sys_alloc(void);

void allocator(int num_req,int num_core);
int check_clients(int i);

int main()
{
	int num_client_working, req_each;
	int i,j,tback;
	char *str;
    init_platform();
    Xil_DCacheDisable();

    /* ---------------------------------------------------------*/
    num_client_working = 1;
    /*----------------------------------------------------------*/
    req_each = 80;

    // tell each fpga client how many requests they need to perform
    for(i = 0; i< num_client_working; i++)
    	Xil_Out32(FCORE_BASE[i] + NUMREQ, req_each);

    // start fpga clients
    for(i = 0; i < num_client_working; i++)
    	Xil_Out32(FCORE_BASE[i] + CSTART, 123);

    // system allocator
    allocator(req_each*num_client_working, num_client_working);

    // reset read counter before reading out latencies
    for(i = 0; i < num_client_working; i++)
    	j = Xil_In32(FCORE_BASE[i] + READRESET);

    // performance evaluation
    for (j = 0; j<req_each; j++){
    	for(i = 0; i <num_client_working; i++){
			tback = Xil_In32(FCORE_BASE[i] + LATBACK);
			xil_printf(" %d\r", tback);
		}
    	xil_printf("\n", tback);
    }
	return 0;

}

void allocator(int num_req,int num_core){


	int cmd;
	int client_id;
	int content;
	int i;

	int res;

	req_count = 0;
	client_id = 0;

	for(i = 0; i < 15; i++){
		malloc_counter[i] = 0;
		free_counter[i] = 0;
	}


	cmd = check_clients(client_id);

	while(req_count < num_req){

		//xil_printf(" req id %d \r\n", req_count);
		cmd = check_clients(client_id);
		//xil_printf(" new cmd read %d \r\n", cmd);
		while(cmd == 0){
			//xil_printf(" check cmd %d, client_id %d \r\n", cmd, client_id);
			if(client_id == num_core - 1){ client_id = 0;}
			else{ client_id++; }
			cmd = check_clients(client_id);
		}
		// read request content
		content =  Xil_In32(FCORE_BASE[client_id] + CONTENT);

		//xil_printf(" read content %d \r\n",content);

		if(cmd == 1){
			pointer_array[client_id][malloc_counter[client_id]] = (char*)malloc(content);
			Xil_Out32(FCORE_BASE[client_id] + RESULT, &pointer_array[client_id][malloc_counter[client_id]]);
			//res = &pointer_array[malloc_counter[client_id]];
			malloc_counter[client_id] ++;
			//xil_printf(" malloc?? \r\n");
		}else if(cmd ==2 ){
			free(pointer_array[client_id][free_counter[client_id]]);
			Xil_Out32(FCORE_BASE[client_id] + RESULT, 1111);
			//res = &pointer_array[free_counter[client_id]];
			free_counter[client_id]++;
			//xil_printf(" freeeee \r\n"); // stopped before here
		}

		//xil_printf(" %d %d %d %d\r\n", req_count, cmd, content, client_id);
		cmd = 0;
		req_count++;
		if(client_id == num_core - 1){ client_id = 0;}
		else{ client_id++; }
	}
}

int check_clients(int i){
	return Xil_In32(FCORE_BASE[i] + COMMAND);
}
