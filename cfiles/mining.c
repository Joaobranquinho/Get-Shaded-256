/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"

#include "xparameters.h"
#include "xstatus.h"
#include "xgpio_l.h"
#include "xintc_l.h"
#include "stdlib.h"

#define INTC_BASEADDR			XPAR_INTC_0_BASEADDR
#define INTC_DEVICE_ID			XPAR_INTC_0_DEVICE_ID
#define SHA_256_0_INT_ID		XPAR_AXI_INTC_0_SHA256_PROJECT_0_DONE_INTERRUPT_INTR
#define SHA_256_0_INT_MASK		XPAR_SHA256_PROJECT_0_DONE_INTERRUPT_MASK
/*
#define FIT_TIMER_0_INT_ID		XPAR_AXI_INTC_0_FIT_TIMER_0_INTERRUPT_INTR
#define FIT_TIMER_0_INT_MASK	XPAR_FIT_TIMER_0_INTERRUPT_MASK
#define PUSH_BUT_INT_ID			XPAR_AXI_INTC_0_AXI_GPIO_PUSH_BUT_IP2INTC_IRPT_INTR
#define PUSH_BUT_INT_MASK		XPAR_AXI_GPIO_PUSH_BUT_IP2INTC_IRPT_MASK
*/
int stop = 0;

void HashSolvedCallBack(void *CallbackRef) // Will be called whenever a button is pressed
{

	Xil_Out32(XPAR_AXI_GPIO_ENABLE_BASEADDR, 0);
	xil_printf("\n\nDeve ter acontecido qualquer coisa. Assumindo que se resolveu uma hash ;)\n");
	xil_printf("\nVALOR DA HASH => %x %x %x%x%x%x%x%x\n", Xil_In32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 76),
	Xil_In32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 80),
	Xil_In32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 84),
	Xil_In32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 88),
	Xil_In32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 92),
	Xil_In32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 96),
	Xil_In32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 100),
	Xil_In32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 104));

	xil_printf("\nVALOR DO NOUNCE => ");
	xil_printf("%x\n", Xil_In32(XPAR_AXI_GPIO_NOUNCE_OUT_BASEADDR));

	xil_printf("\nHASH COUNT =>");
	xil_printf("%x\n", Xil_In32(XPAR_AXI_GPIO_HASH_COUNT_BASEADDR));

	stop = 1;
}

int SetupInterrupts(u32 IntcBaseAddress)
{
	/*
	 * Connect a callback handler that will be called when an interrupt for the timer occurs,
	 * to perform the specific interrupt processing for the timer.
	 */
	XIntc_RegisterHandler(IntcBaseAddress, SHA_256_0_INT_ID,
						  (XInterruptHandler)HashSolvedCallBack, (void *)0);


	/*
	 * Enable interrupts for all devices that cause interrupts, and enable
	 * the INTC master enable bit.
	 */
	XIntc_EnableIntr(IntcBaseAddress, SHA_256_0_INT_MASK);

	/*
	 * Set the master enable bit.
	 */
	XIntc_Out32(IntcBaseAddress + XIN_MER_OFFSET, XIN_INT_HARDWARE_ENABLE_MASK |
												  XIN_INT_MASTER_ENABLE_MASK);

	/*
	 * This step is processor specific, connect the handler for the
	 * interrupt controller to the interrupt source for the processor.
	 */
	Xil_ExceptionInit();

	/*
	 * Register the interrupt controller handler with the exception table.
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
								 (Xil_ExceptionHandler)XIntc_DeviceInterruptHandler,
								 INTC_DEVICE_ID);

	/*
	 * Enable exceptions.
	 */
	Xil_ExceptionEnable();

	return XST_SUCCESS;
}


int main()
{
	int status;

	init_platform();

	status = SetupInterrupts(INTC_BASEADDR);
	if (status != XST_SUCCESS) {
		cleanup_platform();
		return XST_FAILURE;
	}

	// Escrita no start
	//Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR, 1);

	// Escrita do bloco que ele deve dar hash

	Xil_Out32(XPAR_AXI_GPIO_RESET_BASEADDR, 1);

	/*Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR, 0x74696167);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 4, 0x6f746961);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 8, 0x676f7469);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 12, 0x61676f74);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 16, 0x6961676f);

	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 20, 0x74696167);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 24, 0x6f746961);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 28, 0x676f7469);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 32, 0x61676f74);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 36, 0x6961676f);

	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 40, 0x74696167);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 44, 0x6f746961);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 48, 0x676f7469);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 52, 0x61676f74);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 56, 0x6961676f);

	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 60, 0x74696167);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 64, 0x6f746961);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 68, 0x676f7469);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 72, 0x61676f74);*/
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR, 0x01000000);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 4, 0x9500c43a);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 8, 0x25c62452);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 12, 0x0b5100ad);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 16, 0xf82cb9f9);

	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 20, 0xda72fd24);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 24, 0x47a496bc);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 28, 0x600b0000);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 32, 0x00000000);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 36, 0x6cd86237);

	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 40, 0x0395dedf);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 44, 0x1da2841c);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 48, 0xcda0fc48);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 52, 0x9e3039de);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 56, 0x5f1ccdde);

	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 60, 0xf0e83499);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 64, 0x1a65600e);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 68, 0xa6c8cb4d);
	Xil_Out32(XPAR_SHA256_PROJECT_0_S00_AXI_BASEADDR + 72, 0xb3936a1a);

	Xil_Out32(XPAR_AXI_GPIO_ENABLE_BASEADDR, 1);
	Xil_Out32(XPAR_AXI_GPIO_RESET_BASEADDR, 0);

    while (1)
    {
    	xil_printf("\n%x\n", Xil_In32(XPAR_AXI_GPIO_HASH_COUNT_BASEADDR));
    	if(stop == 1){
    		// pôr aqui coisas
    		break;
    	}

    	//xil_printf("%x\n", Xil_In32(XPAR_SHA256_0_S00_AXI_BASEADDR + 76));
    	//Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR, 1); // Só para ele ficar preso no while 1
    }
	xil_printf("\n%d\n", Xil_In32(XPAR_AXI_GPIO_HASH_COUNT_BASEADDR));


    cleanup_platform();
    return 0;
}
