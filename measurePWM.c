/* PRUSS program to drive a HC-SR04 sensor and display the sensor output
*  in Linux userspace by sending an interrupt.
*  written by Derek Molloy for the book Exploring BeagleBone
*/
#include <stdio.h>
#include <stdlib.h>
#include <prussdrv.h>
#include <pruss_intc_mapping.h>
#include <pthread.h>
#include <unistd.h>

#define PRU_NUM 0

static void *pru0DataMemory;
static unsigned int *pru0DataMemory_int, *period;
<<<<<<< HEAD

volatile float period1;
volatile float period2;
volatile float period3;
volatile float period4;
=======
>>>>>>> df0a10d8c5241c812c3fa7e58a1a191ca1698652

void *threadFunction(void *value){
   do {
      int notimes = prussdrv_pru_wait_event (PRU_EVTOUT_1);
      period1 = (float)*(pru0DataMemory_int+2);
      period2 = (float)*(pru0DataMemory_int+3);
      period3 = (float)*(pru0DataMemory_int+4);
      period4 = (float)*(pru0DataMemory_int+5);
      printf("%d periods are Ch1: %f s , Ch2: %f s , Ch3: %f s , Ch4: %f s \r",notimes, period1, period2, period3, period4);
      prussdrv_pru_clear_event (PRU_EVTOUT_1, PRU0_ARM_INTERRUPT);
   } while (1);
}

int  main (void)
{
   if(getuid()!=0){
      printf("You must run this program as root. Exiting.\n");
      exit(EXIT_FAILURE);
   }
   pthread_t thread;
   tpruss_intc_initdata pruss_intc_initdata = PRUSS_INTC_INITDATA;

   // Allocate and initialize memory
   prussdrv_init ();
   prussdrv_open (PRU_EVTOUT_0);
   prussdrv_open (PRU_EVTOUT_1);

   // Map PRU's INTC
   prussdrv_pruintc_init(&pruss_intc_initdata);

   // Copy data to PRU memory - different way
   prussdrv_map_prumem(PRUSS0_PRU0_DATARAM, &pru0DataMemory);
   pru0DataMemory_int = (unsigned int *) pru0DataMemory;
   // Use the first 4 bytes for the number of samples
<<<<<<< HEAD
   *pru0DataMemory_int = 1000000000;

   // Period
   *(pru0DataMemory_int+6) = 216346;
=======
   *pru0DataMemory_int = 10000000;

   // Period
   *(pru0DataMemory_int+6) = 8330;
>>>>>>> df0a10d8c5241c812c3fa7e58a1a191ca1698652

   // Load and execute binary on PRU
   prussdrv_exec_program (PRU_NUM, "./measureChannels.bin");
   if(pthread_create(&thread, NULL, &threadFunction, NULL)){
       printf("Failed to create thread!");
   }
   int n = prussdrv_pru_wait_event (PRU_EVTOUT_0);
   printf("PRU program completed, event number %d.\n", n);
   printf("The data that is in memory is:\n");
   printf("- the number of samples used is %d.\n", *pru0DataMemory_int);

   // number of loops = period
   float period1 = (float)*(pru0DataMemory_int+2);
   float period2 = (float)*(pru0DataMemory_int+3);
   float period3 = (float)*(pru0DataMemory_int+4);
   float period4 = (float)*(pru0DataMemory_int+5);
   printf("periods are Ch1: %f s , Ch2: %f s , Ch3: %f s , Ch4: %f s \n", period1, period2, period3, period4);

   /* Disable PRU and close memory mappings */
   prussdrv_pru_disable(PRU_NUM);
   prussdrv_exit ();
   return EXIT_SUCCESS;
}
