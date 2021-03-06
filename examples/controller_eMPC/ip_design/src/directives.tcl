# ##############################################################################################
#This file is part of ICL SDK4FPGA.
#
#ICL SDK4FPGA -- A framework to optimal design, easy validate
#and fast prototype mathematical algorithms on FPGA based systems.
#Copyright (C) 2014 by Andrea Suardi, Imperial College London.
#Supported by the EPSRC Impact Acceleration grant number EP/K503733/1
#
#ICL SDK4FPGA is free software; you can redistribute it and/or
#modify it under the terms of the GNU Lesser General Public
#License as published by the Free Software Foundation; either
#version 3 of the License, or (at your option) any later version.
#
#ICL SDK4FPGA is distributed in the hope that it will help researchers and engineers
#to build their own mathematical algorithms into FPGA.
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#It is the user's responsibility in assessing the correctness of the algorithm
#and software implementation before putting it to use in their own research
#or exploiting the results commercially.
#Lesser General Public License for more details.
#
#You should have received a copy of the GNU Lesser General Public
#License along with ICL SDK4FPGA; if not, write to the Free Software
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
# ##############################################################################################



# ############################# 
# Directives used by Vivado HLS

# pipeline the for loop named "input_cast_loop" in foo.cpp
set_directive_pipeline "foo/input_cast_loop"
# pipeline the for loop named "output_cast_loop" in foo.cpp
set_directive_pipeline "foo/output_cast_loop"

# pipeline the for loop named "alg" in foo_user.cpp
set_directive_pipeline "foo_user/alg"
