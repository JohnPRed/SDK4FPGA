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


void clip_pipe(
		//constant input vectors
		data_t_large  bmax[FFT_LENGTH],
		data_t_large  bmin[FFT_LENGTH],
		data_t_large  lipschitz,
		data_t_large  beta,
		data_t_large  x[FFT_LENGTH],

		//input vectors (change every iteration)
		data_t_large  	theta_i[FFT_LENGTH],
		data_t_large  	y_i[FFT_LENGTH],
		data_t_large	from_fft_cplx_i[FFT_LENGTH],

		//output vectors (change every iteration),
		data_t_large  	theta_o[FFT_LENGTH],
		data_t_large  	y_o[FFT_LENGTH],
		cmpxData	to_fft_cplx_o[FFT_LENGTH])

	{

	int i =0 ;
	int j =0 ;


	data_t_large Grad[FFT_LENGTH];
	data_t_large theta_tilde[FFT_LENGTH];
	data_t_large theta_new[FFT_LENGTH];
	data_t_large theta_delta[FFT_LENGTH];
	data_t_large beta_theta_delta[FFT_LENGTH];
	data_t_large theta[FFT_LENGTH];
	data_t_large y_new[FFT_LENGTH];
	data_t_large y[FFT_LENGTH];
	data_t_large from_fft[FFT_LENGTH];
	data_t_large to_fft[FFT_LENGTH];
	data_t to_fft_cast[FFT_LENGTH];

	cmpxData  from_fft_cplx[FFT_LENGTH];
	cmpxData  to_fft_cplx[FFT_LENGTH];

	data_t tmp_im = 0;

	//printf("L=%f\n",(float)lipschitz);
	//printf("beta=%f\n",(float)beta);


		g_loop_row:	for(i = 0; i < FFT_LENGTH; i++)
		{


			//Multiply FFT-IFF results by lipschitz constants to compute the gradient
			Grad[i] = from_fft_cplx_i[i] * lipschitz; //gradient
			//printf("Grad[%d]=%f\n",i,(float)Grad );

			theta_tilde[i]=y_i[i]-Grad[i]; //unconstrained update
			//printf("theta_tilde[%d]=%10.40f\n",i,theta_tilde[i] );

			//projection
			if (theta_tilde[i]>bmax[i])
									   {
				theta_new[i]=bmax[i];
									   }
			else if (theta_tilde[i]<bmin[i])
											{
				 theta_new[i]=bmin[i];
											}
			else
			{
				theta_new[i]=theta_tilde[i];
			}


			//printf("theta_new[%d]=%f\n",i,theta_new[i] );

			theta_delta[i]=theta_new[i]-theta_i[i]; // calculate difference

			//printf("theta_delta[%d]=%f\n",i,theta_delta[i] );

			beta_theta_delta[i]=beta * theta_delta[i];
			y_new[i]=theta_new[i]+beta_theta_delta[i]; //update y

			//printf("y_new[%d]=%f\n",i,y_new[i] );

			to_fft[i]=y_new[i]-x[i];

			to_fft_cast[i]=(data_t)to_fft[i];

			to_fft_cplx_o[i] = cmpxData(to_fft_cast[i], tmp_im);

			//printf("to_fft_cplx_o[%d]= %2.12f + i %2.12f\n",i,(float)to_fft_cplx_o[i].real(),(float)to_fft_cplx_o[i].imag());


			theta_o[i]=theta_new[i];
			y_o[i]=y_new[i];
			//to_fft_cplx_o[i]=to_fft_cplx[i];

		}



}



void config_fft(
    config_t* config)
{
	//config->config_width=FFT_CONFIG_WIDTH;
	config->setDir(true);//direct FFT
	config->setSch(FFT_SCALING_FACTOR);
	/*switch(FFT_ARCH_CONF)
	{
		case 1:	//radix-4
			config->setSch(0x1AA);
			break;
		case 2:	//radix-2
			config->setSch(0x15555);
			break;
		case 3:	//pipelined
			config->setSch(0x1AA);
			break;
		case 4:	//radix-2 Lite
			config->setSch(0x15555);
			break;
	}*/
}


void config_ifft(
    config_t* config)
{
	//config->config_width=FFT_CONFIG_WIDTH;
	config->setDir(false); //Inverse FFT
	config->setSch(FFT_SCALING_FACTOR);
	/*switch(FFT_ARCH_CONF)
	{
		case 1:	//radix-4
			config->setSch(0x1AA);
			break;
		case 2:	//radix-2
			config->setSch(0x15555);
			break;
		case 3:	//pipelined
			config->setSch(0x1AA);
			break;
		case 4:	//radix-2 Lite
			config->setSch(0x15555);
			break;
	}*/
}

void clip_weight (
	cmpxDataout in1[FFT_LENGTH],
    data_t_large in2[FFT_LENGTH],
	cmpxData out[FFT_LENGTH]
)
{

    int i; 

    data_t_large zero = 0;

    data_t_large re[FFT_LENGTH], im[FFT_LENGTH];

   data_t_large in1_tempcheck_re[FFT_LENGTH];
   data_t_large in1_tempcheck_im[FFT_LENGTH];


    w_loop: for (i=0; i< FFT_LENGTH; i++)
          {

		#ifdef FLOAT_IMPLEMENTATION

		   if (in1[i].real() != in1[i].real())
			{
			   in1_tempcheck_re[i]=zero;
			}
			else
			{
				in1_tempcheck_re[i]=(data_t_large)in1[i].real();
			}

			if (in1[i].imag() != in1[i].imag())
			{
				in1_tempcheck_im[i]=zero;
			}
			else
			{
				in1_tempcheck_im[i]=(data_t_large)in1[i].imag();
			}

		   re[i]=in1_tempcheck_re[i]*in2[i];
		   im[i]=in1_tempcheck_im[i]*in2[i];

		#endif

		#ifdef FIX_IMPLEMENTATION

		   in1_tempcheck_re[i]=(data_t_large)in1[i].real()*in2[i];
		   in1_tempcheck_im[i]=(data_t_large)in1[i].imag()*in2[i];

		   re[i]=in1_tempcheck_re[i] << 9;
		   im[i]=in1_tempcheck_im[i] << 9;

		#endif

   	   out[i] = cmpxData((data_t)re[i], (data_t)im[i]);

   	//printf("out[%d]= %2.12f + i %2.12f\n",i,(float)re,(float)im);
   	//printf("out[%d]= %2.12f + i %2.12f\n",i,(float)out[i].real(),(float)out[i].imag());

          }
}

void clip_scale(
    status_t* 		status_in1,
    status_t* 		status_in2,
    cmpxDataout		in[FFT_LENGTH],
	data_t_large	out[FFT_LENGTH],
    bool* ovflo)
{
    int i;
    *ovflo = (status_in1->getOvflo() || status_in2->getOvflo()) & 0x1;

    data_t_large	out_int1[FFT_LENGTH];
    //data_t_large	out_int2[FFT_LENGTH];

    data_t_large zero=0;
    bool tmp;

    //scaling is required after FFT and IFFT
    scaling_loop: for (i=0; i< FFT_LENGTH; i++)
    {
    	out_int1[i]=(data_t_large)in[i].real();

    	//printf("out_ifft[%d]=%d\n",i,(int)out_int1[i]);

    	#ifdef FLOAT_IMPLEMENTATION
    		out[i]=out_int1[i]*over_FFT_LENGTH_data_t_elarge;
		#endif

		#ifdef FIX_IMPLEMENTATION
    		out[i]=out_int1[i];
		#endif


    	//printf("fft_ifft[%d]=%d\n",i,(int)out[i]);

    }
}


// one iteration: memory interface
void clip_iter(
    data_t_large  w[FFT_LENGTH],
    data_t_large  bmax[FFT_LENGTH],
	data_t_large  bmin[FFT_LENGTH],
	data_t_large  lipschitz,
	data_t_large  beta,
	data_t_large  x[FFT_LENGTH],

	//input vectors (change every iteration)
	data_t_large  	theta_i[FFT_LENGTH],
	data_t_large  	y_i[FFT_LENGTH],
	data_t_large 	from_fft_cplx_i[FFT_LENGTH],

	//output vectors (change every iteration),
	data_t_large  	theta_o[FFT_LENGTH],
	data_t_large  	y_o[FFT_LENGTH],
	data_t_large	from_fft_cplx_o[FFT_LENGTH],

    bool* ovflo)
{



#pragma HLS interface ap_fifo depth=1 port=ovflo
#pragma HLS dataflow


#ifdef FIX_IMPLEMENTATION
	cmpxData to_fft_cplx_o[FFT_LENGTH];//FFT input
	cmpxDataout xk1[FFT_LENGTH]; //FFT output
	cmpxData xn2[FFT_LENGTH]; //IFFT input
	cmpxDataout xk2[FFT_LENGTH]; //IFFT output

#endif

#ifdef FLOAT_IMPLEMENTATION
	cmpxData to_fft_cplx_o[FFT_LENGTH];
	cmpxDataout xk1[FFT_LENGTH];
	 cmpxData xn2[FFT_LENGTH];
	 cmpxDataout xk2[FFT_LENGTH];
	/*static cmpxData xk1[FFT_LENGTH];
    static cmpxData xn2[FFT_LENGTH];
    static cmpxData xk2[FFT_LENGTH];
    static complex<data_t> to_fft_cplx_o[FFT_LENGTH];*/
#endif


    status_t fft_status1;
    config_t fft_config1;
    status_t fft_status2;
    config_t fft_config2;

    int i;



	clip_pipe(bmax,bmin,lipschitz,beta,x,theta_i,y_i,from_fft_cplx_i,theta_o,y_o,to_fft_cplx_o);

	config_fft(&fft_config1);

	config_ifft(&fft_config2);


	// FFT IP
	hls::fft<config1>(to_fft_cplx_o, xk1, &fft_status1, &fft_config1);


	clip_weight(xk1, w, xn2);
	// IFFT IP
	hls::fft<config1>(xn2, xk2, &fft_status2, &fft_config2);

	clip_scale(&fft_status1, &fft_status2, xk2, from_fft_cplx_o, ovflo);


}


void foo	(	volatile data_t_memory *memory_inout,
				uint32_t byte_bmax_in_offset,
				uint32_t byte_bmin_in_offset,
				uint32_t byte_beta_in_offset,
				uint32_t byte_lipschitz_in_offset,
				uint32_t byte_x_in_offset,
				uint32_t byte_w_in_offset,
				uint32_t byte_num_iter_in_offset,
				uint32_t byte_results_out_offset,
				bool* ovflo)
{

	//ap_bus is the only valid nativeVivado HLSinterface for memory mapped master ports
	#pragma HLS INTERFACE ap_bus port=memory_inout depth=8388608 //used only for RTL simulation

	//Port memory_inout is assigned to an AXI4-master interface
	#pragma HLS RESOURCE variable=memory_inout core=AXI4M

	//Foo function return is assigned to an AXI4-slave interface named BUS_A
	#pragma HLS RESOURCE variable=return core=AXI4LiteS metadata="-bus_bundle BUS_A"

	//Port status is assigned to an AXI4-slave interface named BUS_A

	#pragma HLS INTERFACE ap_none register     port=byte_bmax_in_offset
	#pragma HLS RESOURCE core=AXI4LiteS    variable=byte_bmax_in_offset metadata="-bus_bundle BUS_A"

	#pragma HLS INTERFACE ap_none register     port=byte_bmin_in_offset
	#pragma HLS RESOURCE core=AXI4LiteS    variable=byte_bmin_in_offset metadata="-bus_bundle BUS_A"

	#pragma HLS INTERFACE ap_none register     port=byte_beta_in_offset
	#pragma HLS RESOURCE core=AXI4LiteS    variable=byte_beta_in_offset metadata="-bus_bundle BUS_A"

	#pragma HLS INTERFACE ap_none register     port=byte_lipschitz_in_offset
	#pragma HLS RESOURCE core=AXI4LiteS    variable=byte_lipschitz_in_offset metadata="-bus_bundle BUS_A"

	#pragma HLS INTERFACE ap_none register     port=byte_x_in_offset
	#pragma HLS RESOURCE core=AXI4LiteS    variable=byte_x_in_offset metadata="-bus_bundle BUS_A"

	#pragma HLS INTERFACE ap_none register     port=byte_w_in_offset
	#pragma HLS RESOURCE core=AXI4LiteS    variable=byte_w_in_offset metadata="-bus_bundle BUS_A"

	#pragma HLS INTERFACE ap_none register     port=byte_num_iter_in_offset
	#pragma HLS RESOURCE core=AXI4LiteS    variable=byte_num_iter_in_offset metadata="-bus_bundle BUS_A"

	#pragma HLS INTERFACE ap_none register     port=byte_results_out_offset
	#pragma HLS RESOURCE core=AXI4LiteS    variable=byte_results_out_offset metadata="-bus_bundle BUS_A"

	/*#ifndef __SYNTHESIS__
	//Any system calls which manage memory allocation within the system, for example malloc(), alloc() and free(), must be removed from the design code prior to synthesis. 

	data_t_interface *bmax_in;
	bmax_in = (data_t_interface *)malloc(N*sizeof (data_t_interface));
	data_t_interface *bmin_in;
	bmin_in = (data_t_interface *)malloc(N*sizeof (data_t_interface));
	data_t_interface *beta_in;
	beta_in = (data_t_interface *)malloc(N*sizeof (data_t_interface));
	data_t_interface *lipschitz_in;
	lipschitz_in = (data_t_interface *)malloc(1*sizeof (data_t_interface));
	data_t_interface *x_in;
	x_in = (data_t_interface *)malloc(N*sizeof (data_t_interface));
	data_t_interface *w_in;
	w_in = (data_t_interface *)malloc(N*sizeof (data_t_interface));
	data_t_memory *num_iter_in;
	num_iter_in = (data_t_memory *)malloc(1*sizeof (data_t_memory));
	data_t_interface *results_out;
	results_out = (data_t_interface *)malloc(N*sizeof (data_t_interface));

	data_t_large *bmax_in_int;
	bmax_in_int = (data_t_large *)malloc(N*sizeof (data_t_large));
	data_t_large *bmin_in_int;
	bmin_in_int = (data_t_large *)malloc(N*sizeof (data_t_large));
	data_t_large *beta_in_int;
	beta_in_int = (data_t_large *)malloc(N*sizeof (data_t_large));
	data_t_large *lipschitz_in_int;
	lipschitz_in_int = (data_t_large *)malloc(1*sizeof (data_t_large));
	data_t_large *x_in_int;
	x_in_int = (data_t_large *)malloc(N*sizeof (data_t_large));
	data_t_large *w_in_int;
	w_in_int = (data_t_large *)malloc(N*sizeof (data_t_large));
	data_t_large *results_out_int;
	results_out_int = (data_t_large *)malloc(N*sizeof (data_t_large));

	data_t_large  	theta_i[FFT_LENGTH];
	data_t_large  	y_i[FFT_LENGTH];
	data_t_large 	from_fft_cplx_i[FFT_LENGTH];
	data_t_large  	theta_o[FFT_LENGTH];
	data_t_large  	y_o[FFT_LENGTH];
	data_t_large	from_fft_cplx_o[FFT_LENGTH];
	data_t_large  	out_elaboration[FFT_LENGTH];

	data_t_large	x_int[FFT_LENGTH];
	data_t_large	w_int[FFT_LENGTH];
	data_t_large	lipschitz_int;
	data_t_large	beta_int[MAX_FG_ITERATIONS];
	data_t_large	bmax_int[FFT_LENGTH];
	data_t_large	bmin_int[FFT_LENGTH];

	

	#else*/
	//for synthesis

	data_t_interface  bmax_in[N];
	data_t_interface  bmin_in[N];
	data_t_interface  beta_in[N];
	data_t_interface  lipschitz_in[1];
	data_t_interface  x_in[N];
	data_t_interface  w_in[N];
	data_t_interface  results_out[N];
	data_t_memory num_iter_in[1];

	data_t_large  bmax_in_int[N];
	data_t_large  bmin_in_int[N];
	data_t_large  beta_in_int[N];
	data_t_large  lipschitz_in_int;
	data_t_large  x_in_int[N];
	data_t_large  w_in_int[N];
	data_t_large  results_out_int[N];
	
	data_t_large  	theta_i[FFT_LENGTH];
	data_t_large  	y_i[FFT_LENGTH];
	data_t_large 	from_fft_cplx_i[FFT_LENGTH];
	data_t_large  	theta_o[FFT_LENGTH];
	data_t_large  	y_o[FFT_LENGTH];
	data_t_large	from_fft_cplx_o[FFT_LENGTH];
	data_t_large  	out_elaboration[FFT_LENGTH];

	data_t_large	x_int[FFT_LENGTH];
	data_t_large	w_int[FFT_LENGTH];
	data_t_large	beta_int[MAX_FG_ITERATIONS];
	data_t_large	bmax_int[FFT_LENGTH];
	data_t_large	bmin_int[FFT_LENGTH];

	

	//#endif
	
	int num_iter_int;

	#ifdef FIX_IMPLEMENTATION
	///////////////////////////////////////
	//load input vectors from memory (DDR)

	memcpy(bmax_in,(const data_t_memory*)(memory_inout+byte_bmax_in_offset/4),N*sizeof(data_t_memory));
	memcpy(bmin_in,(const data_t_memory*)(memory_inout+byte_bmin_in_offset/4),N*sizeof(data_t_memory));
	memcpy(beta_in,(const data_t_memory*)(memory_inout+byte_beta_in_offset/4),N*sizeof(data_t_memory));
	memcpy(lipschitz_in,(const data_t_memory*)(memory_inout+byte_lipschitz_in_offset/4),1*sizeof(data_t_memory));
	memcpy(x_in,(const data_t_memory*)(memory_inout+byte_x_in_offset/4),N*sizeof(data_t_memory));
	memcpy(w_in,(const data_t_memory*)(memory_inout+byte_w_in_offset/4),N*sizeof(data_t_memory));
	memcpy(num_iter_in,(const data_t_memory*)(memory_inout+byte_num_iter_in_offset/4),sizeof(data_t_memory));


    //Initialisation: cast to the precision used for the algorithm
	input_cast_loop:for (int i=0; i< N; i++)
	{
		bmax_in_int[i]=(data_t_large)bmax_in[i];
		bmin_in_int[i]=(data_t_large)bmin_in[i];
		beta_in_int[i]=(data_t_large)beta_in[i];
		
		x_in_int[i]=(data_t_large)x_in[i];
		w_in_int[i]=(data_t_large)w_in[i];
	}
	
	lipschitz_in_int=(data_t_large)lipschitz_in[0];

	#endif

	#ifdef FLOAT_IMPLEMENTATION
	///////////////////////////////////////
	//load input vectors from memory (DDR)

	memcpy(bmax_in_int,(const data_t_memory*)(memory_inout+byte_bmax_in_offset/4),N*sizeof(data_t_memory));
	memcpy(bmin_in_int,(const data_t_memory*)(memory_inout+byte_bmin_in_offset/4),N*sizeof(data_t_memory));
	memcpy(beta_in_int,(const data_t_memory*)(memory_inout+byte_beta_in_offset/4),N*sizeof(data_t_memory));
	memcpy(lipschitz_in_int,(const data_t_memory*)(memory_inout+byte_lipschitz_in_offset/4),N*sizeof(data_t_memory));
	memcpy(x_in_int,(const data_t_memory*)(memory_inout+byte_x_in_offset/4),N*sizeof(data_t_memory));
	memcpy(w_in_int,(const data_t_memory*)(memory_inout+byte_w_in_offset/4),N*sizeof(data_t_memory));
	memcpy(num_iter_in_int,(const data_t_memory*)(memory_inout+byte_num_iter_in_offset/4),N*sizeof(data_t_memory));
	


	#endif

	
	///////////////////////////////////////
	//USER algorithm function (foo_user.cpp) call
	//Input vectors are:
	//bmax_in_int[N] -> data type is data_t_large
	//bmin_in_int[N] -> data type is data_t_large
	//beta_in_int[N] -> data type is data_t_large
	//lipschitz_in_int[N] -> data type is data_t_large
	//x_in_int[N] -> data type is data_t_large
	//w_in_int[N] -> data type is data_t_large
	//num_iter_in_int[N] -> data type is data_t_large
	//Output vectors are:
	//results_out_int[N] -> data type is data_t_large
	//Initialisation
	initialization_loop:for (int i=0; i< FFT_LENGTH; i++)
	{

		theta_i[i]=x_in_int[i];
		y_i[i]=x_in_int[i];
		from_fft_cplx_i[i]=0;
		bmin_int[i]=bmin_in_int[i];
		bmax_int[i]=bmax_in_int[i];
		w_int[i]=w_in_int[i];
		x_int[i]=x_in_int[i];

	}

	num_iter_int=(int)num_iter_in[0];


	initialization_loop2:for (int i=0; i< MAX_FG_ITERATIONS; i++)
	{
		beta_int[i]=beta_in_int[i];
	}

	FG_loop:for (int i=0; i< num_iter_int; i++)
	{

		//run one iteration
		clip_iter(w_int,bmax_int,bmin_int,lipschitz_in_int,beta_int[i],x_int,theta_i,y_i,from_fft_cplx_i,theta_o,y_o,from_fft_cplx_o,ovflo);


		update_loop:for (int i=0; i< FFT_LENGTH; i++)
		{

			theta_i[i]=theta_o[i];
			y_i[i]=y_o[i];
			from_fft_cplx_i[i]=from_fft_cplx_o[i];
			//theta_o[i]=x_int[i];

		}


	}



	#ifdef FIX_IMPLEMENTATION
	///////////////////////////////////////
	//store output vectors to memory (DDR)

	output_cast_loop: for(int i = 0; i < N; i++)
	{
		results_out[i]=(data_t_interface)theta_o[i];
	}

	//write results vector y_out to DDR
	memcpy((data_t_memory *)(memory_inout+byte_results_out_offset/4),results_out,N*sizeof(data_t_memory));

	#endif

	#ifdef FLOAT_IMPLEMENTATION
	///////////////////////////////////////
	//write results vector y_out to DDR
	memcpy((data_t_memory *)(memory_inout+byte_results_out_offset/4),theta_o,N*sizeof(data_t_memory));

	#endif


}
