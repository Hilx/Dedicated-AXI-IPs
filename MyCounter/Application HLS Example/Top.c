#include "top.h" // your own main header file
#include "MyCounter.h" // Contains info of how to communicate with counter

int ListIP(data_t *SlaveAXI, data_t *Master2Mem, data_t *Master2SysAlloc){

	#pragma HLS INTERFACE s_axilite port=SlaveAXI bundle=SlavePort
	#pragma HLS INTERFACE s_axilite port=return   bundle=SlavePort
	#pragma HLS INTERFACE m_axi depth=1 port=Master2Mem offset=off
	#pragma HLS INTERFACE m_axi depth=1 port=Master2SysAlloc offset=off // <- you need this port

	ptr_t hdPtr = NULL_PTR;
	int SizeOfList = 10;
	
	Master2SysAlloc[(COUNTER_BASE)/4] = C_START; //Start the counter
	
	/*------------ Your Application Code ------------*/
	
	/* Creating a list */
	hdPtr = ListGen(Master2Mem, Master2SysAlloc, SizeOfList, hdPtr);
	/* Reverse the list */
	hdPtr = ReverseList(Master2Mem, hdPtr);
	/* Delete the list */
	hdPtr = DeleteList(Master2Mem, Master2SysAlloc, hdPtr);
	
	/*------------ End Of Your Application Code  ----*/
	
	Master2SysAlloc[(COUNTER_BASE)/4] = C_STOP; // Stop the counter

	return hdPtr;
}
