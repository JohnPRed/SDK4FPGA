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


#include "clip_data.h"

void foo	(	volatile data_t_memory *memory_inout,
				uint32_t byte_bmax_in_offset,
				uint32_t byte_bmin_in_offset,
				uint32_t byte_beta_in_offset,
				uint32_t byte_lipschitz_in_offset,
				uint32_t byte_x_in_offset,
				uint32_t byte_w_in_offset,
				uint32_t byte_num_iter_in_offset,
				uint32_t byte_results_out_offset,
				bool* ovflo);




using namespace std;
#define BUF_SIZE 64

#define bmax_IN_DEFINED_MEM_ADDRESS 0
#define bmin_IN_DEFINED_MEM_ADDRESS 2048
#define beta_IN_DEFINED_MEM_ADDRESS 4096
#define lipschitz_IN_DEFINED_MEM_ADDRESS 6144
#define x_IN_DEFINED_MEM_ADDRESS 8192
#define w_IN_DEFINED_MEM_ADDRESS 10240
#define num_iter_IN_DEFINED_MEM_ADDRESS 12288
#define results_OUT_DEFINED_MEM_ADDRESS 14336


int main()
{

	char filename[BUF_SIZE]={0};

    int max_iter;

	uint32_t byte_bmax_in_offset;
	uint32_t byte_bmin_in_offset;
	uint32_t byte_beta_in_offset;
	uint32_t byte_lipschitz_in_offset;
	uint32_t byte_x_in_offset;
	uint32_t byte_w_in_offset;
	uint32_t byte_num_iter_in_offset;
	uint32_t byte_results_out_offset;

	int32_t tmp_value;
	uint32_t status;

	//assign the input/output vectors base address in the DDR memory
	byte_bmax_in_offset=bmax_IN_DEFINED_MEM_ADDRESS;
	byte_bmin_in_offset=bmin_IN_DEFINED_MEM_ADDRESS;
	byte_beta_in_offset=beta_IN_DEFINED_MEM_ADDRESS;
	byte_lipschitz_in_offset=lipschitz_IN_DEFINED_MEM_ADDRESS;
	byte_x_in_offset=x_IN_DEFINED_MEM_ADDRESS;
	byte_w_in_offset=w_IN_DEFINED_MEM_ADDRESS;
	byte_num_iter_in_offset=num_iter_IN_DEFINED_MEM_ADDRESS;
	byte_results_out_offset=results_OUT_DEFINED_MEM_ADDRESS;

	//allocate a memory named address of uint32_t or float words. Number of words is 1024 * (number of inputs and outputs vectors)
	data_t_memory *memory_inout;
	memory_inout = (data_t_memory *)malloc(8* 1048576 * sizeof (data_t_memory));	//malloc size should be max_vector_length * (number of inputs and outputs vectors)

	FILE *stimfile;
	FILE * pFile;
	int count_data;

	float bmax_in[N];
	float bmin_in[N];
	float beta_in[N];
	float lipschitz_in[N];
	float x_in[N];
	float w_in[N];
	float num_iter_in[N];
	float results_out[N];

	float results_out_log[N];


	////////////////////////////////////////
	//read bmax_in vector

	// Open stimulus bmax_in.dat file for reading
	sprintf(filename,"bmax_in.dat");
	stimfile = fopen(filename, "r");

	// read data from file
	ifstream input1(filename);
	vector<float> myValues1;

	count_data=0;

	for (float f; input1 >> f; )
	{
		myValues1.push_back(f);
		count_data++;
	}

	//fill in input vector
	for (int i = 0; (i < N || i<count_data); i++)
	{
		bmax_in[i]=(float)myValues1[i];

		#ifdef FIX_IMPLEMENTATION
			tmp_value=(int32_t)(bmax_in[i]*(float)pow(2,(FRACTIONLENGTH)));
			memory_inout[i+byte_bmax_in_offset/4] = *(uint32_t*)&tmp_value;
		#endif

		#ifdef FLOAT_IMPLEMENTATION
			memory_inout[i+byte_bmax_in_offset/4] = (float)bmax_in[i];
		#endif

	}


	////////////////////////////////////////
	//read bmin_in vector

	// Open stimulus bmin_in.dat file for reading
	sprintf(filename,"bmin_in.dat");
	stimfile = fopen(filename, "r");

	// read data from file
	ifstream input2(filename);
	vector<float> myValues2;

	count_data=0;

	for (float f; input2 >> f; )
	{
		myValues2.push_back(f);
		count_data++;
	}

	//fill in input vector
	for (int i = 0; (i < N || i<count_data); i++)
	{
		bmin_in[i]=(float)myValues2[i];

		#ifdef FIX_IMPLEMENTATION
			tmp_value=(int32_t)(bmin_in[i]*(float)pow(2,(FRACTIONLENGTH)));
			memory_inout[i+byte_bmin_in_offset/4] = *(uint32_t*)&tmp_value;
		#endif

		#ifdef FLOAT_IMPLEMENTATION
			memory_inout[i+byte_bmin_in_offset/4] = (float)bmin_in[i];
		#endif

	}


	////////////////////////////////////////
	//read beta_in vector

	// Open stimulus beta_in.dat file for reading
	sprintf(filename,"beta_in.dat");
	stimfile = fopen(filename, "r");

	// read data from file
	ifstream input3(filename);
	vector<float> myValues3;

	count_data=0;

	for (float f; input3 >> f; )
	{
		myValues3.push_back(f);
		count_data++;
	}

	//fill in input vector
	for (int i = 0; (i < N || i<count_data); i++)
	{
		beta_in[i]=(float)myValues3[i];

		#ifdef FIX_IMPLEMENTATION
			tmp_value=(int32_t)(beta_in[i]*(float)pow(2,(FRACTIONLENGTH)));
			memory_inout[i+byte_beta_in_offset/4] = *(uint32_t*)&tmp_value;
		#endif

		#ifdef FLOAT_IMPLEMENTATION
			memory_inout[i+byte_beta_in_offset/4] = (float)beta_in[i];
		#endif

	}


	////////////////////////////////////////
	//read lipschitz_in vector

	// Open stimulus lipschitz_in.dat file for reading
	sprintf(filename,"lipschitz_in.dat");
	stimfile = fopen(filename, "r");

	// read data from file
	ifstream input4(filename);
	vector<float> myValues4;

	count_data=0;

	for (float f; input4 >> f; )
	{
		myValues4.push_back(f);
		count_data++;
	}

	//fill in input vector
	for (int i = 0; (i < N || i<count_data); i++)
	{
		lipschitz_in[i]=(float)myValues4[i];

		#ifdef FIX_IMPLEMENTATION
			tmp_value=(int32_t)(lipschitz_in[i]*(float)pow(2,(FRACTIONLENGTH)));
			memory_inout[i+byte_lipschitz_in_offset/4] = *(uint32_t*)&tmp_value;
		#endif

		#ifdef FLOAT_IMPLEMENTATION
			memory_inout[i+byte_lipschitz_in_offset/4] = (float)lipschitz_in[i];
		#endif

	}


	////////////////////////////////////////
	//read x_in vector

	// Open stimulus x_in.dat file for reading
	sprintf(filename,"x_in.dat");
	stimfile = fopen(filename, "r");

	// read data from file
	ifstream input5(filename);
	vector<float> myValues5;

	count_data=0;

	for (float f; input5 >> f; )
	{
		myValues5.push_back(f);
		count_data++;
	}

	//fill in input vector
	for (int i = 0; (i < N || i<count_data); i++)
	{
		x_in[i]=(float)myValues5[i];

		#ifdef FIX_IMPLEMENTATION
			tmp_value=(int32_t)(x_in[i]*(float)pow(2,(FRACTIONLENGTH)));
			memory_inout[i+byte_x_in_offset/4] = *(uint32_t*)&tmp_value;
		#endif

		#ifdef FLOAT_IMPLEMENTATION
			memory_inout[i+byte_x_in_offset/4] = (float)x_in[i];
		#endif

	}


	////////////////////////////////////////
	//read w_in vector

	// Open stimulus w_in.dat file for reading
	sprintf(filename,"w_in.dat");
	stimfile = fopen(filename, "r");

	// read data from file
	ifstream input6(filename);
	vector<float> myValues6;

	count_data=0;

	for (float f; input6 >> f; )
	{
		myValues6.push_back(f);
		count_data++;
	}

	//fill in input vector
	for (int i = 0; (i < N || i<count_data); i++)
	{
		w_in[i]=(float)myValues6[i];

		#ifdef FIX_IMPLEMENTATION
			tmp_value=(int32_t)(w_in[i]*(float)pow(2,(FRACTIONLENGTH)));
			memory_inout[i+byte_w_in_offset/4] = *(uint32_t*)&tmp_value;
		#endif

		#ifdef FLOAT_IMPLEMENTATION
			memory_inout[i+byte_w_in_offset/4] = (float)w_in[i];
		#endif

	}


	////////////////////////////////////////
	//read num_iter_in vector

	// Open stimulus num_iter_in.dat file for reading
	sprintf(filename,"num_iter_in.dat");
	stimfile = fopen(filename, "r");

	// read data from file
	ifstream input7(filename);
	vector<float> myValues7;

	count_data=0;

	for (float f; input7 >> f; )
	{
		myValues7.push_back(f);
		count_data++;
	}

	//fill in input vector
	for (int i = 0; (i < N || i<count_data); i++)
	{
		num_iter_in[i]=(float)myValues7[i];

		#ifdef FIX_IMPLEMENTATION
			tmp_value=(int32_t)(num_iter_in[i]);
			memory_inout[i+byte_num_iter_in_offset/4] = *(uint32_t*)&tmp_value;
		#endif

		#ifdef FLOAT_IMPLEMENTATION
			memory_inout[i+byte_num_iter_in_offset/4] = (float)num_iter_in[i];
		#endif

	}


	/////////////////////////////////////
	// foo c-simulation
	
	bool ovflo;

	foo(	memory_inout,
				byte_bmax_in_offset,
				byte_bmin_in_offset,
				byte_beta_in_offset,
				byte_lipschitz_in_offset,
				byte_x_in_offset,
				byte_w_in_offset,
				byte_num_iter_in_offset,
				byte_results_out_offset,
				&ovflo);
	
	
	/////////////////////////////////////
	// read computed results_out and store it as results_out.dat
	pFile = fopen ("../../../../../../src/results_out.dat","w+");

	for (int i = 0; i < N; i++)
	{

		#ifdef FIX_IMPLEMENTATION
			tmp_value=*(int32_t*)&memory_inout[i+byte_results_out_offset/4];
			results_out[i]=((float)tmp_value)/(float)pow(2,(FRACTIONLENGTH));
		#endif
		
		#ifdef FLOAT_IMPLEMENTATION
			results_out[i]=(float)memory_inout[i+byte_results_out_offset/4];
		#endif
		
		fprintf(pFile,"%f, ",results_out[i]);

	}
	fprintf(pFile,"\n");
	fclose (pFile);
		

	return 0;
}
