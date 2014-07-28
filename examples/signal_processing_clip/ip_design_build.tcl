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



#  FPGA ip design build Vivado_HLS project
#  Suardi Andrea [a.suardi@imperial.ac.uk]
#  June - 2014

# Required tools:
# Vivado_HLS 2014.2
# Matlab

#to execute the script:
# 1) set configuration parameters in "configuration_parameters.tcl"
# 2) run Vivado HLS Command Prompt
# 2) type: "vivado_hls -f ip_design_build.tcl" (without "")


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


# ####################################################################################################################
# #################################################################################################################### 
#  BUILD
# #################################################################################################################### 
# #################################################################################################################### 


# ############################# 
# #############################   
# Load configuration parameters

set file "configuration_parameters.tcl"
src $file

set file "make_template/make_foo_data_h.tcl"
src $file $max_vector_length $float_fix $bits_word_integer_length $bits_word_fraction_length $fft_arch
unset file




# ############################# 
# ############################# 
# Run Vivado HLS

# Add design files.
# NOTE: add here below other files made by the user
cd ip_design/build/prj
open_project -reset $project_name
set_top foo

# Add design files
set filename [format "../../src/foo_data.h"] 
add_files $filename
unset filename
set filename [format "../../src/clip_data.h"] 
add_files $filename
unset filename
set filename [format "../../src/foo.cpp"] 
add_files $filename
unset filename

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

config_dataflow -default_channel fifo -fifo_depth 512

# Run design implementation
csynth_design
export_design -format ip_catalog -description "Template IP generated by Andrea Suardi a.suardi@imperial.ac.uk" -vendor "icl.ac.uk" -library "hls" -version "1.0"

# Export synthesis report
append path_report $project_name "/solution1/syn/report/foo_csynth.rpt"
append path_report_final "../reports/" $project_name

file mkdir $path_report_final
file copy -force $path_report $path_report_final

unset path_report
append path_report $project_name "/solution1/syn/report/foo_clip_iter_csynth.rpt"
file copy -force $path_report $path_report_final

# close Vivado HLS project
close_solution
close_project


unset project_name 

				

exit


