// Accurately measure duty cycle of PWM signal from 4 different channels and store it in
// a memory location accessible from an external program
// Generate PWMs based on the data at those memory locations

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

START:
   // Read number of samples to read
   MOV    r0, 0x00000000                  //load the memory location, number of samples
   LBBO   r1, r0, 0, 4                    //load the value into memory - keep r1
   MOV    r0, 0x00000008                  // going to write the result to this address

TRIGGERING:                     
   MOV    r3, 0                           // r3 will store the echo pulse width for channel 1

   MEASURE:                    
      QBBS ADDCHAN1, r31.t3               // If r31.t3 is high start counting (measuring echo pulse width)
                                         
         QBBS NOPULSE1, r3                // if pulse has not started do nothing
      
            SBBO   r3, r0, 0, 4           // if pulse is done (not high) store to memory
            MOV    r3, -1                 // reset channel 1 counter ( -1 since ADDCHAN adds 1 after)
            MOV R31.b0, PRU0_R31_VEC_VALID | PRU_EVTOUT_1 // generate interrupt

      ADDCHAN1:
         ADD r3, r3, 1                    // Increment channel 1 counter

      NOPULSE1:
         SUB    r1, r1, 1                 // take 1 away from the number of iterations
         QBNE   MEASURE, r1, 0         // loop if the no of iterations has not passed

END:
   MOV R31.b0, PRU0_R31_VEC_VALID | PRU_EVTOUT_0
   HALT

