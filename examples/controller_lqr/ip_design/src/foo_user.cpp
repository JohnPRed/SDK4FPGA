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

//////////////////////////////////////////////
// ADD contents of update_foo_user_data.txt

const unsigned nx =6;
const unsigned nu =3;


//row, column
static data_t K0[nu][nx]={
{-0.9812238359676559400000000000000000000000,-0.0000000000000000000000000000000000000000,0.0469790021990090160000000000000000000000,-55.6042404299846280000000000000000000000000,-0.0000000000000000000000000000000000000000,-0.0213817968260723300000000000000000000000},
{-0.0000000000000000000000000000000000000000,-0.9812053585479187900000000000000000000000,-0.0000000000000000000000000000000000000000,-0.0000000000000000000000000000000000000000,-55.6041804872796210000000000000000000000000,-0.0000000000000000000000000000000000000000},
{-0.0469787260330969190000000000000000000000,-0.0000000000000000000000000000000000000000,-0.9846289259123153200000000000000000000000,0.0259034454610759560000000000000000000000,-0.0000000000000000000000000000000000000000,-55.6986907583232520000000000000000000000000},
};

//column
static data_t u_min[nu]={
-64.0000000000000000000000000000000000000000,-64.0000000000000000000000000000000000000000,-64.0000000000000000000000000000000000000000};

//column
static data_t u_max[nu]={
64.0000000000000000000000000000000000000000,64.0000000000000000000000000000000000000000,64.0000000000000000000000000000000000000000};

//////////////////////////////////////////////

void foo_user(  data_t x0_in_int[N],
				data_t x_ref_in_int[N],
				data_t u_out_int[N])
{

	
	data_t  x_in_diff;
	data_t  u_tmp_temp_mult;
	data_t u_tmp_temp_add;
	data_t u_tmp[nu];
	
	///////////////////////////////////////
	//LQR algorithm :
	nu_loop: for(int i = 0; i < nu; i++)
	{

		u_tmp_temp_add = 0;
		

		nx_loop: for(int j = 0; j <nx; j++)
			{
				x_in_diff=x0_in_int[j]-x_ref_in_int[j];
				u_tmp_temp_mult = K0[i][j] * x_in_diff;
				u_tmp_temp_add += u_tmp_temp_mult;

			}

		u_tmp[i] = u_tmp_temp_add;

		//saturation
		if (u_tmp[i]>u_max[i])
			u_out_int[i]=u_max[i];
		else if (u_tmp[i]<u_min[i])
			u_out_int[i]=u_min[i];
		else
			u_out_int[i]=u_tmp[i];

	}





}
