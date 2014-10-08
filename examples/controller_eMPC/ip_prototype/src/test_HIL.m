%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This file is part of ICL SDK4FPGA.
%
%ICL SDK4FPGA -- A framework to optimal design, easy validate
%and fast prototype mathematical algorithms on FPGA based systems.
%Copyright (C) 2014 by Andrea Suardi, Imperial College London.
%Supported by the EPSRC Impact Acceleration grant number EP/K503733/1
%
%ICL SDK4FPGA is free software; you can redistribute it and/or
%modify it under the terms of the GNU Lesser General Public
%License as published by the Free Software Foundation; either
%version 3 of the License, or (at your option) any later version.
%
%ICL SDK4FPGA is distributed in the hope that it will help researchers and engineers
%to build their own mathematical algorithms into FPGA.
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
%It is the user's responsibility in assessing the correctness of the algorithm
%and software implementation before putting it to use in their own research
%or exploiting the results commercially.
%Lesser General Public License for more details.
%
%You should have received a copy of the GNU Lesser General Public
%License along with ICL SDK4FPGA; if not, write to the Free Software
%Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




clear all;
clc;
close all;


% Set the number of simulations to run
num_simulation=1000;



filename=strcat('eMPC_inverted_pendulum.mat');
load(filename);

nx=size(ctrl.sysStruct.B,1);
nu=size(ctrl.sysStruct.B,2);
G=ctrl.Gi;
F=ctrl.Fi;

A=(ctrl.sysStruct.A);
B=(ctrl.sysStruct.B);
C=(ctrl.sysStruct.C);
D=(ctrl.sysStruct.D);

fpga_x0=[-pi*2/3  0];
matlab_x0=[-pi*2/3  0];


for i=1:num_simulation


    num_simulation-i
    
    if (i>1)
   
        %Apply plant model
        fpga_x0 = A*fpga_x0' + B*fpga_u_out(1:nu);
        fpga_x0=fpga_x0';
        matlab_x0 = A*matlab_x0' + B*matlab_u_out(1:nu);
        matlab_x0=matlab_x0';
    end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%save fpga_x_in_log
	filename = strcat('../test_hil/results/fpga_x_in_log.dat');
	fid = fopen(filename, 'a+');
   
	for j=1:length(fpga_x0)
		fprintf(fid, '%2.18f,',fpga_x0(j));
	end
	fprintf(fid, '\n');

	fclose(fid);
    
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%save x_imatlab_x_in_logn_log
	filename = strcat('../test_hil/results/matlab_x_in_log.dat');
	fid = fopen(filename, 'a+');
   
	for j=1:length(matlab_x0)
		fprintf(fid, '%2.18f,',matlab_x0(j));
	end
	fprintf(fid, '\n');

	fclose(fid);


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% send the stimulus to the FPGA, execute the algorithm and read back the results
	% reset IP
	Packet_type=1; % 1 for reset, 2 for start, 3 for write to IP vector packet_internal_ID, 4 for read from IP vector packet_internal_ID of size packet_output_size
	packet_internal_ID=0;
	packet_output_size=1;
	data_to_send=1;
	FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);


	% send data to FPGA
	% send x_in
	Packet_type=3; % 1 for reset, 2 for start, 3 for write to IP vector packet_internal_ID, 4 for read from IP vector packet_internal_ID of size packet_output_size
	packet_internal_ID=0;
	packet_output_size=1;
	data_to_send=fpga_x0;
	FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);


	% start FPGA
	Packet_type=2; % 1 for reset, 2 for start, 3 for write to IP vector packet_internal_ID, 4 for read from IP vector packet_internal_ID of size packet_output_size
	packet_internal_ID=0;
	packet_output_size=1;
	data_to_send=0;
	FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);


	% read data from FPGA
	% read u_out
	Packet_type=4; % 1 for reset, 2 for start, 3 for write to IP vector packet_internal_ID, 4 for read from IP vector packet_internal_ID of size packet_output_size
	packet_internal_ID=0;
	packet_output_size=2;
	data_to_send=0;
	[output_FPGA, ~, ~] = FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);
	fpga_u_out=output_FPGA(1:nu);

	%save fpga_u_out
	filename = strcat('../test_hil/results/fpga_u_out_log.dat');
	fid = fopen(filename, 'a+');
   
	for j=1:length(fpga_u_out)
		fprintf(fid, '%2.18f,',fpga_u_out(j));
	end
	fprintf(fid, '\n');

	fclose(fid);


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% compute with Matlab and save in a file simulation results

	% Simulation results u_out
    [region, ~] = double_searchTree_point_location(ctrl,matlab_x0');
    tmp = double_control_law(F,G, matlab_x0', region);
    matlab_u_out=tmp(1:nu);
    

	%save u_out_log
	filename = strcat('../test_hil/results/matlab_u_out_log.dat');
	fid = fopen(filename, 'a+');
   
	for j=1:length(matlab_u_out)
		fprintf(fid, '%2.18f,',matlab_u_out(j));
	end
	fprintf(fid, '\n');

	fclose(fid);
    
    if abs(matlab_u_out-fpga_u_out)>1
        break;
    end

end
