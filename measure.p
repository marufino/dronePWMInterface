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
   LBBO   r1, r0, 0, 4                    //load the value into memory - keep r1
   MOV    r0, 0x00000008                  // going to write the result to this address 
   LBBO   r16, r0, 16, 4                  // load signal period (1/frequency) 51Hz(?) for Turnigy

   MOV    r3, 0                           // r3 will store the echo pulse width for channel 1
   SBBO   r3, r0, 0, 4                    // initialize to 0
   MOV    r4, 0                           // r4 will store the echo pulse width for channel 2
   SBBO   r4, r0, 4, 4                    // initialize to 0
   MOV    r5, 0                           // r5 will store the echo pulse width for channel 3
   SBBO   r5, r0, 8, 4                     // initialize to 0
   MOV    r6, 0                           // r6 will store the echo pulse width for channel 4
   SBBO   r6, r0, 12, 4                   // initialize to 0

   MOV r31.b0,0


   MEASURE:

     CHANNEL1:               
         QBBS ADDCHAN1, r31.t5               // If r31.t5 is high then count (measuring echo pulse width)
                                            
            QBEQ NOPULSE1, r3, 0             // if pulse has not started do nothing
         
               SBBO   r3, r0, 0, 4           // if pulse is done (not high) store to memory
               MOV    r3, -1                 // reset channel counter ( -1 since ADDCHAN adds 1 after)

         ADDCHAN1:
            ADD r3, r3, 1                    // Increment channel counter

         NOPULSE1:

      CHANNEL2:
         QBBS ADDCHAN2, r31.t3               // If r31.t3 is high then count (measuring echo pulse width)
                                            
            QBEQ NOPULSE2, r4, 0             // if pulse has not started do nothing
         
               SBBO   r4, r0, 4, 4           // if pulse is done (not high) store to memory
               MOV    r4, -1                 // reset channel counter ( -1 since ADDCHAN adds 1 after)

         ADDCHAN2:
            ADD r4, r4, 1                    // Increment channel counter

         NOPULSE2:

      CHANNEL3:
         QBBS ADDCHAN3, r31.t1               // If r31.t1 is high then count (measuring echo pulse width)
                                            
            QBEQ NOPULSE3, r5, 0             // if pulse has not started do nothing
         
               SBBO   r5, r0, 8, 4           // if pulse is done (not high) store to memory
               MOV    r5, -1                 // reset channel counter ( -1 since ADDCHAN adds 1 after)

         ADDCHAN3:
            ADD r5, r5, 1                    // Increment channel counter

         NOPULSE3:

      CHANNEL4:
         QBBS ADDCHAN4, r31.t2               // If r31.t2 is high then count (measuring echo pulse width)
                                            
            QBEQ NOPULSE4, r6, 0             // if pulse has not started do nothing
         
               SBBO   r6, r0, 12, 4           // if pulse is done (not high) store to memory
               MOV    r6, -1                 // reset channel counter ( -1 since ADDCHAN adds 1 after)
               //MOV R31.b0, PRU0_R31_VEC_VALID | PRU_EVTOUT_0 // generate interrupt

         ADDCHAN4:
            ADD r6, r6, 1                    // Increment channel counter

         NOPULSE4:


   ITERATIONS:
      SUB    r1, r1, 1                 // take 1 away from the number of iterations
      QBNE   MEASURE, r1, 0            // loop if the no of iterations has not passed

END:
   //MOV R31.b0, PRU0_R31_VEC_VALID | PRU_EVTOUT_1
   HALT