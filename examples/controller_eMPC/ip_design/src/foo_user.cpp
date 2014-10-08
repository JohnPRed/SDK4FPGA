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
				data_t u_out_int[N])
{

	int i =0 ;
	int j =0 ;
	int row_addr =0 ;
	int row_addr_next_right =0 ;
	int row_addr_next_left =0 ;
	bool flag_break = 0;

	data_t ztemp_mult = 0;
	data_t ztemp_add = 0;
	data_t z =0;

	int row_addr_F =0 ;
	int base_row_addr_F=0;

	data_t ftemp_mult = 0;
	data_t ftemp_add = 0;


	row_addr=0;
	row_addr_next_right=0;
	row_addr_next_left =0 ;
	flag_break = 0;
	


	loop_row_H:	for(i = 0; i < ST_MAX_DEPTH; i++)
	{

		printf("row_addr is %d @ iteration %d\n",row_addr+1,i+1);

		ztemp_add = 0;
		
		if (flag_break == 0)
		{
			loop_dotproduct_H:	for(j = 0; j < N; j++)
				{
					ztemp_mult= MPT_ST_H[row_addr][j]*x_in_int[j];
					ztemp_add += ztemp_mult;
				}

			z = ztemp_add - MPT_ST_ALPHA[row_addr];


			row_addr_next_right=MPT_ST_RIGHT[row_addr];
			row_addr_next_left=MPT_ST_LEFT[row_addr];

			if (z < 0)
			{
				row_addr = row_addr_next_right;
				if (row_addr_next_right <= 0)
					flag_break=1;
			}
			else
			{
				row_addr = row_addr_next_left;
				if (row_addr_next_left <= 0)
					flag_break=1;
			}

		}
		//printf("z is %f @ iteration %d\n",z,i+1);
		
	}
	
	
	base_row_addr_F=row_addr*(-M);
	printf("base_row_addr_F is %d\n",base_row_addr_F);
	
	loop_row_F:	for(i = 0; i < M; i++)
	{

		ftemp_add = 0;
		row_addr_F=base_row_addr_F+i;

		loop_dotproduct_F:	for(j = 0; j < N; j++)
			{
				ftemp_mult= MPT_F[row_addr_F][j]*x_in_int[j];
				ftemp_add += ftemp_mult;
			}

		u_out_int[i] = ftemp_add + MPT_G[row_addr_F];
	}






}
