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

void *threadFunction(void *value){
   do {
      int notimes = prussdrv_pru_wait_event (PRU_EVTOUT_0);

      printf("interrupt hit %d times", notimes);

      prussdrv_pru_clear_event (PRU_EVTOUT_0, PRU0_ARM_INTERRUPT);
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

   // Map PRU's INTC
   prussdrv_pruintc_init(&pruss_intc_initdata);

   // Copy data to PRU memory - different way
   prussdrv_map_prumem(PRUSS0_PRU0_DATARAM, &pru0DataMemory);
   pru0DataMemory_int = (unsigned int *) pru0DataMemory;
   // Use the first 4 bytes for the number of samples
   *pru0DataMemory_int = 1000000;

   // Load and execute binary on PRU
   prussdrv_exec_program (PRU_NUM, "./timer.bin");
   if(pthread_create(&thread, NULL, &threadFunction, NULL)){
       printf("Failed to create thread!");
   }

   printf("before loop");
   while(1);
   
   /* Disable PRU and close memory mappings */
   prussdrv_pru_disable(PRU_NUM);
   prussdrv_exit ();
   return EXIT_SUCCESS;
}

