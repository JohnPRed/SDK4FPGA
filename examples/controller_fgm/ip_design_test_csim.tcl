# ########################################################################################
# This file is part of ICL SDK4FPGA.

# ICL SDK4FPGA -- A framework to optimal design, easy validate
# and fast prototype mathematical algorithms on FPGA based systems.
# Copyright (C) 2014 by Andrea Suardi, Imperial College London.
# Supported by the EPSRC Impact Acceleration grant number EP/K503733/1

# ICL SDK4FPGA is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 3 of the License, or (at your option) any later version.

# ICL SDK4FPGA is distributed in the hope that it will help researchers and engineers
# to build their own mathematical algorithms into FPGA.
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# It is the user's responsibility in assessing the correctness of the algorithm
# and software implementation before putting it to use in their own research
# or exploiting the results commercially.
# Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public
# License along with ICL SDK4FPGA; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
# ########################################################################################



# FPGA ip design test csim Vivado_HLS project
#  Suardi Andrea [a.suardi@imperial.ac.uk]
#  May - 2014

# Required tools:
# Vivado_HLS 2014.1
# Matlab

#to execute the script:
# 1) set configuration parameters in "configuration_parameters.tcl"
# 2) run Vivado HLS Command Prompt
# 2) type: "vivado_hls -f ip_design_test_csim.tcl" (without "")



# ####################################################################################################################
# #################################################################################################################### 
#  PROCEDURES
# #################################################################################################################### 
# #################################################################################################################### 


# ############################# 
# procedure used to pass arguments to a tcl script (source: http://wiki.tcl.tk/10025)
proc src {file args} {
  set argv $::argv
  set argc $::argc
  set ::argv $args
  set ::argc [llength $args]
  set code [catch {uplevel [list source $file]} return]
  set ::argv $argv
  set ::argc $argc
  return -code $code $return
}


# ############################# 
# Procedure used to build and run Vivado HLS c-simulation
proc csim {input_vectors project_name FPGA_name fclk} {

	# Create a Vivado HLS project
	cd ip_design/test_csim/prj
	open_project -reset $project_name
	set_top foo

	# Add design files.
	# NOTE: add here below other files made by the user
	set filename [format "../../src/foo_data.h"] 
	add_files $filename
	unset filename
	set filename [format "../../src/foo_user.cpp"] 
	add_files $filename
	unset filename
	set filename [format "../../src/foo.cpp"] 
	add_files $filename
	unset filename

	# Add testbench files
	set filename [format "../../src/foo_test.cpp"] 
	add_files -tb $filename
	unset filename
	foreach i $input_vectors {
		append tmp_name "../../src/" $i "_in.dat"
		set filename [format $tmp_name] 
		add_files -tb $filename
		unset filename
		unset tmp_name
	}

	# compute circuit clock period in ns
	set time [ expr 1000/$fclk]

	# Configure the design
	open_solution -reset "solution1"
	set_part $FPGA_name
	create_clock -period $time -name default
	# Configure implementation directives to build an optimized FPGA circuit
	append directives_destination_path $project_name "/solution1/"
	file copy -force  ../../src/directives.tcl $directives_destination_path
	append directives_destination_name "./" $project_name "/solution1/directives.tcl"
	source $directives_destination_name

	# Build and run design simulation
	csim_design -clean

	# close Vivado HLS project
	close_solution
	close_project
	cd ..
	cd ..
	cd ..
}


# ####################################################################################################################
# #################################################################################################################### 
#  C-SIMULATION
# #################################################################################################################### 
# #################################################################################################################### 

set sim_type "'test_csim'"

# #############################   
# Load configuration parameters
set file "configuration_parameters.tcl"
src $file

# #############################  
# clear previous csim results
file delete -force ip_design/test_csim/results
file mkdir ip_design/test_csim/results


# #############################    
# Update foo_data.h header file
#~ set file "make_template/make_foo_data_h.tcl"
#~ src $file $max_vector_length $float_fix $bits_word_integer_length $bits_word_fraction_length
#~ unset file

# #############################  
# simulation loop
for {set i 0} {$i < $num_simulation} {incr i} {

	# #############################  
	# Call Matlab to make *.dat files which will be loaded by the c-simulation (funeval_test.cpp)

	cd ip_design/src
	file delete -force _locked
	 
	# Call Matlab function write_testbench.m to generate the *.dat files used by foo_test.cpp
	set status [ catch { exec $MatlabPath --nospash -nodesktop -r write_stimulus($i,$sim_type)} output ]

	# Wait until the Matlab has finished
	while {true} {
		if { [file exists _locked] == 1} {  
			after 1000
			break
		}
	}

	
	cd ..
	cd ..


	# ############################# 
	# build and run c-simulation. Results will be stored in validation.results
	csim $input_vectors $project_name $FPGA_name $fclk
	
	
	# ############################# 
	# Run simulation in Matlab

	cd ip_design/src	
	file delete -force _locked
	

	# Call Matlab function read_testbench.m
	set status [ catch { exec $MatlabPath --nospash -nodesktop -r read_results($i,$sim_type)} output ]

	# Wait until the Matlab has finished
	while {true} {
		if { [file exists _locked] == 1} {  
			after 1000	
			break
		}
	} 

	cd ..
	cd ..
	
}







exit



