/*
* This file is part of ICL SDK4FPGA.
*
* ICL SDK4FPGA -- A framework to optimal design, easy validate
* and fast prototype mathematical algorithms on FPGA based systems.
* Copyright (C) 2014 by Andrea Suardi, Imperial College London.
* Supported by the EPSRC Impact Acceleration grant number EP/K503733/1
*
* ICL SDK4FPGA is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* ICL SDK4FPGA is distributed in the hope that it will help researchers and engineers
* to build their own mathematical algorithms into FPGA.
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
* It is the user's responsibility in assessing the correctness of the algorithm
* and software implementation before putting it to use in their own research
* or exploiting the results commercially.
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with ICL SDK4FPGA; if not, write to the Free Software
* Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*
*/


#include "eMPC_data.h"


void foo_user(  data_t x_in_int[N],
				data_t u_out_int[N]);


void foo	(
				uint32_t byte_x_in_offset,
				uint32_t byte_u_out_offset,
				volatile data_t_memory *memory_inout)
{

	//ap_bus is the only valid nativeVivado HLSinterface for memory mapped master ports
	#pragma HLS INTERFACE ap_bus port=memory_inout depth=2097152 //used only for RTL simulation

	//Port memory_inout is assigned to an AXI4-master interface
	#pragma HLS RESOURCE variable=memory_inout core=AXI4M

	//Foo function return is assigned to an AXI4-slave interface named BUS_A
	#pragma HLS RESOURCE variable=return core=AXI4LiteS metadata="-bus_bundle BUS_A"


	#pragma HLS INTERFACE ap_none register     port=byte_x_in_offset
	#pragma HLS RESOURCE core=AXI4LiteS    variable=byte_x_in_offset metadata="-bus_bundle BUS_A"

	#pragma HLS INTERFACE ap_none register     port=byte_u_out_offset
	#pragma HLS RESOURCE core=AXI4LiteS    variable=byte_u_out_offset metadata="-bus_bundle BUS_A"

	#ifndef __SYNTHESIS__
	//Any system calls which manage memory allocation within the system, for example malloc(), alloc() and free(), must be removed from the design code prior to synthesis. 

	data_t_interface *x_in;
	x_in = (data_t_interface *)malloc(N*sizeof (data_t_interface));
	data_t_interface *u_out;
	u_out = (data_t_interface *)malloc(N*sizeof (data_t_interface));

	data_t *x_in_int;
	x_in_int = (data_t *)malloc(N*sizeof (data_t));
	data_t *u_out_int;
	u_out_int = (data_t *)malloc(N*sizeof (data_t));

	#else
	//for synthesis

	data_t_interface  x_in[N];
	data_t_interface  u_out[N];

	data_t  x_in_int[N];
	data_t  u_out_int[N];

	#endif

	#ifdef FIX_IMPLEMENTATION
	///////////////////////////////////////
	//load input vectors from memory (DDR)

	memcpy(x_in,(const data_t_memory*)(memory_inout+byte_x_in_offset/4),N*sizeof(data_t_memory));


    //Initialisation: cast to the precision used for the algorithm
	input_cast_loop:for (int i=0; i< N; i++)
	{
		x_in_int[i]=(data_t)x_in[i];
	}

	#endif

	#ifdef FLOAT_IMPLEMENTATION
	///////////////////////////////////////
	//load input vectors from memory (DDR)

	memcpy(x_in_int,(const data_t_memory*)(memory_inout+byte_x_in_offset/4),N*sizeof(data_t_memory));

	#endif

	///////////////////////////////////////
	//USER algorithm function (foo_user.cpp) call
	//Input vectors are:
	//x_in_int[N] -> data type is data_t
	//Output vectors are:
	//u_out_int[N] -> data type is data_t
	foo_user_top: foo_user(	x_in_int,
							u_out_int);


	#ifdef FIX_IMPLEMENTATION
	///////////////////////////////////////
	//store output vectors to memory (DDR)

	output_cast_loop: for(int i = 0; i < N; i++)
	{
		u_out[i]=(data_t_interface)u_out_int[i];
	}

	//write results vector y_out to DDR
	memcpy((data_t_memory *)(memory_inout+byte_u_out_offset/4),u_out,N*sizeof(data_t_memory));

	#endif

	#ifdef FLOAT_IMPLEMENTATION
	///////////////////////////////////////
	//write results vector y_out to DDR
	memcpy((data_t_memory *)(memory_inout+byte_u_out_offset/4),u_out_int,N*sizeof(data_t_memory));

	#endif


}
