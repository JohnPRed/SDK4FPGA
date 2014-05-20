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


#include "foo_data.h"


void foo_user(  data_t x0_in_int[N],
				data_t x_ref_in_int[N],
				data_t u_out_int[N]);


void foo	(	volatile data_t_memory *memory_inout,
				uint32_t byte_x0_in_offset,
				uint32_t byte_x_ref_in_offset,
				uint32_t byte_u_out_offset,
				uint32_t* status)
{

	//ap_bus is the only valid nativeVivado HLSinterface for memory mapped master ports
	#pragma HLS INTERFACE ap_bus port=memory_inout depth=3145728 //used only for RTL simulation

	//Port memory_inout is assigned to an AXI4-master interface
	#pragma HLS RESOURCE variable=memory_inout core=AXI4M

	//Foo function return is assigned to an AXI4-slave interface named BUS_A
	#pragma HLS RESOURCE variable=return core=AXI4LiteS metadata="-bus_bundle BUS_A"

	//Port status is assigned to an AXI4-slave interface named BUS_A
	#pragma HLS INTERFACE ap_none register     port=status
	#pragma HLS RESOURCE variable=status core=AXI4LiteS metadata="-bus_bundle BUS_A"

	#pragma HLS INTERFACE ap_none register     port=byte_x0_in_offset
	#pragma HLS RESOURCE core=AXI4LiteS    variable=byte_x0_in_offset metadata="-bus_bundle BUS_A"

	#pragma HLS INTERFACE ap_none register     port=byte_x_ref_in_offset
	#pragma HLS RESOURCE core=AXI4LiteS    variable=byte_x_ref_in_offset metadata="-bus_bundle BUS_A"

	#pragma HLS INTERFACE ap_none register     port=byte_u_out_offset
	#pragma HLS RESOURCE core=AXI4LiteS    variable=byte_u_out_offset metadata="-bus_bundle BUS_A"

	data_t_interface  x0_in[N];
	data_t_interface  x_ref_in[N];
	data_t_interface  u_out[N];

	data_t  x0_in_int[N];
	data_t  x_ref_in_int[N];
	data_t  u_out_int[N];

	*status=0; //IP running

	///////////////////////////////////////
	//load input vectors from memory (DDR)

	memcpy(x0_in,(const data_t_memory*)(memory_inout+byte_x0_in_offset/4),N*sizeof(data_t_memory));
	memcpy(x_ref_in,(const data_t_memory*)(memory_inout+byte_x_ref_in_offset/4),N*sizeof(data_t_memory));


    //Initialisation: cast to the precision used for the algorithm
	input_cast_loop:for (int i=0; i< N; i++)
	{
		x0_in_int[i]=(data_t)x0_in[i];
		x_ref_in_int[i]=(data_t)x_ref_in[i];
	}


	///////////////////////////////////////
	//USER algorithm function (foo_user.cpp) call
	//Input vectors are:
	//x0_in_int[N] -> data type is data_t
	//x_ref_in_int[N] -> data type is data_t
	//Output vectors are:
	//u_out_int[N] -> data type is data_t
	foo_user_top: foo_user(	x0_in_int,
							x_ref_in_int,
							u_out_int);


	///////////////////////////////////////
	//store output vectors to memory (DDR)

	output_cast_loop: for(int i = 0; i < N; i++)
	{
		u_out[i]=(data_t_interface)u_out_int[i];
	}

	//write results vector y_out to DDR
	memcpy((data_t_memory *)(memory_inout+byte_u_out_offset/4),u_out,N*sizeof(data_t_memory));


	*status=1; //IP stop

}
