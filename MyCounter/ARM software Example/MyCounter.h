/* counter stuff */
//addresses
#define COUNTER_BASE 0x43C30000 // <- change this according to your system
#define COUNTER_RESULT 4 // only needed in ARM core if you want to read result back to software
//commands
#define C_START 1
#define C_STOP 2
#define C_RESET 3 // probably only needed in ARM core to reset the counter after the result has been read