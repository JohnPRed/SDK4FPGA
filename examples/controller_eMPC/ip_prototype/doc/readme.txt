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






The PL template has been customized to support an algortihm with the following input and output vectors:

Name			| Direction		| Number of data | Data representation

x			 	| Input         | 2			|data type "data_t" is fixed-point: 8 bits integer length, 8 bits fraction length
u			 	| Output		| 2			|data type "data_t" is fixed-point: 8 bits integer length, 8 bits fraction length



Input and output vectors has been mapped to external DDR memory at the following adresses:

Name			| Base address in Byte

x			 	| 0x02000000
u			 	| 0x02000008

The external DDR memory is shared memory between the CPU embedded into the FPGA and the Algortihm implemented into the FPGa programmable logic (PL).



To send input vectors from the host (Matlab) to the FPGA call matlab function "FPGAclientMATLAB" in "test_HIL.m" using the following parameters:

Input vector name		| Packet type 	|	Packet internal ID 	| Data to send	| Packet output size
x			 			| 3				| 0						| data vector	| 0



To read output vectors from the FPGA to the host (Matlab) call matlab function "FPGAclientMATLAB" in "test_HIL.m" using the following parameters:

Output vector name		| Packet type 	|	Packet internal ID 	| Data to send	| Packet output size
u			 			| 4				| 0						| 0				| vector length
