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



void foo	(	volatile data_t_memory *memory_inout,
				uint32_t byte_x_in_offset,
				uint32_t byte_num_iter_in_offset,
				uint32_t byte_x_out_offset,
				uint32_t* status);


using namespace std;
#define BUF_SIZE 64

#define x_IN_DEFINED_MEM_ADDRESS 0
#define num_iter_IN_DEFINED_MEM_ADDRESS 160
#define x_OUT_DEFINED_MEM_ADDRESS 320


int main()
{

	char filename[BUF_SIZE]={0};

    int max_iter;

	uint32_t byte_x_in_offset;
	uint32_t byte_num_iter_in_offset;
	uint32_t byte_x_out_offset;

	int32_t tmp_value;
	uint32_t status;

	//assign the input/output vectors base address in the DDR memory
	byte_x_in_offset=x_IN_DEFINED_MEM_ADDRESS;
	byte_num_iter_in_offset=num_iter_IN_DEFINED_MEM_ADDRESS;
	byte_x_out_offset=x_OUT_DEFINED_MEM_ADDRESS;

	//allocate a memory named address of uint32_t or float words. Number of words is 1024 * (number of inputs and outputs vectors)
	data_t_memory *memory_inout;
	memory_inout = (data_t_memory *)malloc(3* 1048576 * sizeof (data_t_memory));	//malloc size should be max_vector_length * (number of inputs and outputs vectors)

	FILE *stimfile;
	FILE * pFile;

	float x_in[N];
	float num_iter_in[N];
	float x_out[N];

	float x_out_log[N];


	////////////////////////////////////////
	//read x_in vector

	// Open stimulus x_in.dat file for reading
	sprintf(filename,"x_in.dat");
	stimfile = fopen(filename, "r");

	// read data from file
	ifstream input1(filename);
	vector<float> myValues1;

	for (float f; input1 >> f; )
		myValues1.push_back(f);

	//fill in input vector
	for (int i = 0; i < N; i++)
	{
		x_in[i]=(float)myValues1[i];

		#ifdef FIX_IMPLEMENTATION
			tmp_value=(int32_t)(x_in[i]*(float)pow(2,(FRACTIONLENGTH)));
			memory_inout[i+byte_x_in_offset/4] = *(uint32_t*)&tmp_value;
		#endif

		#ifdef FLOAT_IMPLEMENTATION
			memory_inout[i+byte_x_in_offset/4] = (float)x_in[i];
		#endif

	}


	////////////////////////////////////////
	//read num_iter_in vector

	// Open stimulus num_iter_in.dat file for reading
	sprintf(filename,"num_iter_in.dat");
	stimfile = fopen(filename, "r");

	// read data from file
	ifstream input2(filename);
	vector<float> myValues2;

	for (float f; input2 >> f; )
		myValues2.push_back(f);

	//fill in input vector
	for (int i = 0; i < N; i++)
	{
		num_iter_in[i]=(float)myValues2[i];

		#ifdef FIX_IMPLEMENTATION
			tmp_value=(int32_t)(num_iter_in[i]*(float)pow(2,(FRACTIONLENGTH)));
			memory_inout[i+byte_num_iter_in_offset/4] = *(uint32_t*)&tmp_value;
		#endif

		#ifdef FLOAT_IMPLEMENTATION
			memory_inout[i+byte_num_iter_in_offset/4] = (float)num_iter_in[i];
		#endif

	}


	/////////////////////////////////////
	// foo c-simulation
	
	foo(	memory_inout,
				byte_x_in_offset,
				byte_num_iter_in_offset,
				byte_x_out_offset,
				&status);
	
	
	/////////////////////////////////////
	// read computed x_out and store it as x_out.dat
	pFile = fopen ("../../../../../../src/x_out.dat","w+");

	for (int i = 0; i < N; i++)
	{

		#ifdef FIX_IMPLEMENTATION
			tmp_value=*(int32_t*)&memory_inout[i+byte_x_out_offset/4];
			x_out[i]=((float)tmp_value)/(float)pow(2,(FRACTIONLENGTH));
		#endif
		
		#ifdef FLOAT_IMPLEMENTATION
			x_out[i]=(float)memory_inout[i+byte_x_out_offset/4];
		#endif
		
		fprintf(pFile,"%f, ",x_out[i]);

	}
	fprintf(pFile,"\n");
	fclose (pFile);
		

	return 0;
}
