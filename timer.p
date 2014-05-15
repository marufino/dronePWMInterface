// Accurately measure duty cycle of PWM signal from 4 different channels and store it in
// a memory location accessible from an external program
// Generate PWMs based on the data at those memory locations
// Written by Miguel Rufino

.origin 0               // offset of start of program in PRU memory
.entrypoint START       // program entry point used by the debugger

#define INS_PER_US            200
#define INS_PER_LOOP          2
#define PRU0_R31_VEC_VALID    32
#define PRU_EVTOUT_0          3
#define PRU_EVTOUT_1          4       

// r1 : iteration counter
// r0 : measurement storage location
// r3 : channel 1 timer
// r4 : channel 2 timer
// r5 : channel 3 timer
// r6 : channel 4 timer

// r11 : channel 1 pwm out
// r12 : channel 2 pwm out
// r13 : channel 3 pwm out
// r14 : channel 4 pwm out

// r16 : signal period



START:
   // Read number of samples to read
   MOV    r0, 0x00000000                  //load the memory location, number of samples

   MOV R31.b0, PRU0_R31_VEC_VALID | PRU_EVTOUT_1

   

END:
   HALT
