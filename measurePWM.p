// PRUSS program to measure frequency of PWM signal and store it in a memory location
// that can be read by a Linux userspace program when an interrupt is sent
// modified by Miguel Rufino, from Derek Molloy for the book Exploring BeagleBone 

.origin 0               // offset of start of program in PRU memory
.entrypoint START       // program entry point used by the debugger

#define TRIGGER_PULSE_US    10
#define INS_PER_US          200
#define INS_PER_LOOP        2
#define TRIGGER_COUNT       (TRIGGER_PULSE_US * INS_PER_US) / INS_PER_LOOP
#define SAMPLE_DELAY_1MS    (1000 * INS_PER_US) / INS_PER_LOOP
#define PRU0_R31_VEC_VALID  32;
#define PRU_EVTOUT_0	    3
#define PRU_EVTOUT_1	    4

// Using register 0 for all temporary storage (reused multiple times)
START:
   // Read number of samples to read and inter-sample delay
   MOV    r0, 0x00000000        //load the memory location, number of samples
   LBBO   r1, r0, 0, 4          //load the value into memory - keep r1

TRIGGERING:                     // delay for 10us
   // clear the counter and wait until the echo goes high
   MOV    r3, 0                 // r3 will store the echo pulse width
   WBS    r31.t3                // wait until the echo goes high

   // start counting (measuring echo pulse width)  until the echo goes low
COUNTING:
   ADD    r3, r3, 1             // increment the counter by 1
   QBBS   COUNTING, r31.t3      // loop if the echo is still high
   // at this point the echo is now low - write the value to shared memory
   MOV    r0, 0x00000008        // going to write the result to this address
   SBBO   r3, r0, 0, 4          // store the count at this address
   // one more sample iteration has taken place
   SUB    r1, r1, 1             // take 1 away from the number of iterations

   // generate an interrupt to update the display on the host computer
   MOV R31.b0, PRU0_R31_VEC_VALID | PRU_EVTOUT_1
   QBNE   TRIGGERING, r1, 0       // loop if the no of iterations has not passed

END:
   MOV R31.b0, PRU0_R31_VEC_VALID | PRU_EVTOUT_0
   HALT
