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


//Define the maximum number of FG iteration allowed in FPGA.
//In practice it is used to allocate a memory of MAX_FG_ITERATIONS words for storing the "beta"
#define MAX_FG_ITERATIONS 100


const unsigned N=512; //input and output vector length


#ifdef FIX_IMPLEMENTATION
	typedef ap_fixed<INTEGERLENGTH+FRACTIONLENGTH,INTEGERLENGTH,AP_TRN_ZERO,AP_SAT> data_t_large;
	typedef ap_fixed<32,32-FRACTIONLENGTH,AP_TRN_ZERO,AP_SAT> data_t_interface;
	typedef uint32_t data_t_memory;
#endif

#ifdef FLOAT_IMPLEMENTATION
	typedef float data_t_large;
	typedef float data_t_interface;
	typedef float data_t_memory;
#endif


#ifdef FIX_IMPLEMENTATION

const unsigned FFT_INPUT_WIDTH    = (((FRACTIONLENGTH+1)<=16) && ((FRACTIONLENGTH+1)>8))  ? 16 :  (((FRACTIONLENGTH+1)<=24) && ((FRACTIONLENGTH+1)>16))  ? 24 :   ((FRACTIONLENGTH+1)==8)  ? 8 : 32;


	const unsigned FFT_NFFT_MAX             = 9; 	//@- log2(maximum transform length): 3-16
	const unsigned  FFT_LENGTH               = 512; //@- Transform length
	const unsigned FFT_FREQUENCY            = 200;
	const unsigned FFT_CHANNELS             = 1;
	const unsigned FFT_ARCH                 = FFT_ARCH_CONF;	//@- Architecture: 1=radix-4, 2=radix-2, 3=pipelined, 4=radix-2 Lite
	const bool FFT_HAS_NFFT             = 0;	//@- Run-time configurable transform length: 0=no, 1=yes
	const bool FFT_USE_FLT_PT           = 0;	//@- Input and output data format: 0=fixed-point, 1=single-precision floating point
	//const unsigned FFT_INPUT_WIDTH          = (((FRACTIONLENGTH+1)<=16) && ((FRACTIONLENGTH+1)>8))  ? 16 : 24;	//@- Input data width: 8-34 bits (32 if C_USE_FLT_PT = 1)
	const unsigned FFT_OUTPUT_WIDTH         = FFT_INPUT_WIDTH;
	const unsigned FFT_TWIDDLE_WIDTH        = FFT_INPUT_WIDTH;	//@- Twiddle factor width: 8-34 bits (24-25 if C_USE_FLT_PT = 1)
	const unsigned FFT_SCALING_OPTIONS		=0; //- 0=scaled, 1=unscaled, 2=block floating point	
	const unsigned FFT_SCALING_FACTOR		=((FFT_ARCH_CONF==1) || (FFT_ARCH_CONF==3))  ? 0x1AA : 0x15555; //-scaling factor
	const unsigned FFT_HAS_ROUNDING         = 0;	//@- Type of data rounding: 0=truncation, 1=convergent rounding
	const unsigned FFT_OUTPUT_ORDER         = 1;	//@- Output ordering: 0=bit_reversed_order, 1=natural_order
	const unsigned FFT_STAGES_BLOCK_RAM     = 4;
	const bool FFT_OVFLO                = 1;
	const unsigned FFT_CONFIG_WIDTH = ((FFT_ARCH_CONF==1) || (FFT_ARCH_CONF==3))  ? 16 : 24;
	const unsigned FFT_STATUS_WIDTH         = 8;
	const unsigned FFT_COMPLEX_MULT_TYPE	=1; 	//@- use_luts = 0, use_mults_resources=1, use_mults_performance=2, use_xtremedsp_slices=3
	const unsigned FFT_BATTERLY_TYPE		=0; 	//@- use_luts = 0, use_mults_resources=1, use_mults_performance=2, use_xtremedsp_slices=3
	const bool FFT_MEM_OPTIONS_HYBRID	=0; 	//@- false=0. true=1
	const unsigned FFT_MEM_DATA				=0; 	//@- block_ram = 0, distributed_ram=1
	const unsigned FFT_MEM_PHASE_FACTORS	=0; 	//@- block_ram = 0, distributed_ram=1
	const unsigned FFT_MEM_REORDER			=0; 	//@- block_ram = 0, distributed_ram=1
#endif

#ifdef FLOAT_IMPLEMENTATION
	const unsigned FFT_NFFT_MAX             = 9; 	//@- log2(maximum transform length): 3-16
	const unsigned  FFT_LENGTH               = 512; //@- Transform length
	const unsigned FFT_FREQUENCY            = 200;
	const unsigned FFT_CHANNELS             = 1;
	const unsigned FFT_ARCH                 = 3;	//@- Architecture: 1=radix-4, 2=radix-2, 3=pipelined, 4=radix-2 Lite
	const bool FFT_HAS_NFFT             = 0;	//@- Run-time configurable transform length: 0=no, 1=yes
	const bool FFT_USE_FLT_PT           = 1;	//@- Input and output data format: 0=fixed-point, 1=single-precision floating point
	const unsigned FFT_INPUT_WIDTH          = 32;	//@- Input data width: 8-34 bits (32 if C_USE_FLT_PT = 1)
	const unsigned FFT_OUTPUT_WIDTH         = FFT_INPUT_WIDTH;
	const unsigned FFT_TWIDDLE_WIDTH        = 24;	//@- Twiddle factor width: 8-34 bits (24-25 if C_USE_FLT_PT = 1)
	const unsigned FFT_SCALING_OPTIONS		=1; //- 0=scaled, 1=unscaled, 2=block floating point
	const unsigned FFT_SCALING_FACTOR		=((FFT_ARCH_CONF==1) || (FFT_ARCH_CONF==3))  ? 0x1AA : 0x15555; //-scaling factor
	const unsigned FFT_HAS_ROUNDING         = 0;	//@- Type of data rounding: 0=truncation, 1=convergent rounding
	const unsigned FFT_OUTPUT_ORDER         = 1;	//@- Output ordering: 0=bit_reversed_order, 1=natural_order
	const unsigned FFT_STAGES_BLOCK_RAM     = 4;
	const bool FFT_OVFLO                = 1;
	const unsigned FFT_CONFIG_WIDTH = ((FFT_ARCH_CONF==1) || (FFT_ARCH_CONF==3))  ? 16 : 24;
	const unsigned FFT_STATUS_WIDTH         = 8;
	const unsigned FFT_COMPLEX_MULT_TYPE	=1; 	//@- use_luts = 0, use_mults_resources=1, use_mults_performance=2, use_xtremedsp_slices=3
	const unsigned FFT_BATTERLY_TYPE		=0; 	//@- use_luts = 0, use_mults_resources=1, use_mults_performance=2, use_xtremedsp_slices=3
	const bool FFT_MEM_OPTIONS_HYBRID	=0; 	//@- flase=0. true=1
	const unsigned FFT_MEM_DATA				=0; 	//@- block_ram = 0, distributed_ram=1
	const unsigned FFT_MEM_PHASE_FACTORS	=0; 	//@- block_ram = 0, distributed_ram=1
	const unsigned FFT_MEM_REORDER			=0; 	//@- block_ram = 0, distributed_ram=1
#endif


#include <complex>
using namespace std;


struct config1 : hls::ip_fft::params_t {

    static const unsigned input_width = FFT_INPUT_WIDTH;
    static const unsigned output_width = FFT_OUTPUT_WIDTH;
    static const unsigned status_width = FFT_STATUS_WIDTH;
    static const unsigned config_width = FFT_CONFIG_WIDTH;
    static const unsigned max_nfft = FFT_NFFT_MAX;
	
	static const unsigned data_format = FFT_USE_FLT_PT;

    static const bool has_nfft = FFT_HAS_NFFT;
    static const unsigned  channels = FFT_CHANNELS;
    static const unsigned arch_opt = FFT_ARCH;
    static const unsigned phase_factor_width = FFT_TWIDDLE_WIDTH;
    static const unsigned ordering_opt = FFT_OUTPUT_ORDER;
    static const bool ovflo = FFT_OVFLO;
    static const unsigned scaling_opt = FFT_SCALING_OPTIONS;
    static const unsigned rounding_opt = FFT_HAS_ROUNDING;
    static const unsigned mem_data = FFT_MEM_DATA;
    static const unsigned mem_phase_factors = FFT_MEM_PHASE_FACTORS;
    static const unsigned mem_reorder = FFT_MEM_REORDER;
    static const unsigned stages_block_ram = (FFT_NFFT_MAX < 10) ? 0 : (FFT_NFFT_MAX - 9);
    static const bool mem_hybrid = FFT_MEM_OPTIONS_HYBRID;
    static const unsigned complex_mult_type = FFT_COMPLEX_MULT_TYPE;
    static const unsigned butterfly_type = FFT_BATTERLY_TYPE;

};

typedef hls::ip_fft::config_t<config1> config_t;
typedef hls::ip_fft::status_t<config1> status_t;


#ifdef FIX_IMPLEMENTATION

	typedef ap_fixed<(config1::input_width%8) ? (config1::input_width/8+1)*8 : config1::input_width, 1> data_t;
	typedef ap_fixed<(config1::output_width%8) ? (config1::output_width/8+1)*8 : config1::output_width,
            ((config1::output_width%8) ? (config1::output_width/8+1)*8 : config1::output_width)-config1::input_width+1> data_out_t;
	typedef ap_fixed<FRACTIONLENGTH+10,10,AP_TRN, AP_SAT> data_t_elarge;
#endif

#ifdef FLOAT_IMPLEMENTATION
	typedef float data_t;
	typedef float data_out_t;
	typedef float data_t_elarge;
#endif

/*
typedef ap_fixed<FRACTIONLENGTH+1,1,AP_TRN, AP_SAT> data_t;
typedef ap_fixed<FRACTIONLENGTH+1,1,AP_TRN, AP_SAT> data_in_t;
typedef ap_fixed<FRACTIONLENGTH+1,1,AP_TRN, AP_SAT> data_out_t;
typedef ap_fixed<FRACTIONLENGTH+10,10,AP_TRN, AP_SAT> data_t_elarge;*/


typedef std::complex<data_t> cmpxData;
typedef std::complex<data_out_t> cmpxDataout;


//const data_t_elarge  FFT_LENGTH_data_t_elarge = 512;

const data_t_elarge  over_FFT_LENGTH_data_t_elarge = 0.0019531; // 1/512




