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
num_simulation=500;

load LQR_example.mat
nx=size(sysd.a,1); %number of states
nu=size(sysd.b,2); %number of inputs
ny=size(sysd.c,1); %number of outputs


for i=1:num_simulation


    [num_simulation-i]
    
    if (i>1)
        x0_in=sysd.a*x0_in+sysd.b*fpga_u_out(1:nu);
    end
    
    
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%save x0_in_log
	filename = strcat('../test_hil/results/x0_in_log.dat');
	fid = fopen(filename, 'a+');
   
	for j=1:length(x0_in)
		fprintf(fid, '%2.18f,',x0_in(j));
	end
	fprintf(fid, '\n');

	fclose(fid);



	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%save x_ref_in_log
	filename = strcat('../test_hil/results/x_ref_in_log.dat');
	fid = fopen(filename, 'a+');
   
	for j=1:length(x_ref_in)
		fprintf(fid, '%2.18f,',x_ref_in(j));
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
	% send x0_in
	Packet_type=3; % 1 for reset, 2 for start, 3 for write to IP vector packet_internal_ID, 4 for read from IP vector packet_internal_ID of size packet_output_size
	packet_internal_ID=0;
	packet_output_size=1;
	data_to_send=x0_in;
	FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);

	% send x_ref_in
	Packet_type=3; % 1 for reset, 2 for start, 3 for write to IP vector packet_internal_ID, 4 for read from IP vector packet_internal_ID of size packet_output_size
	packet_internal_ID=1;
	packet_output_size=1;
	data_to_send=x_ref_in;
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
	packet_output_size=6;
	data_to_send=0;
	[output_FPGA, ~, ~] = FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);
	fpga_u_out=output_FPGA;

	%save u_out_log
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
    % compute control action 
    % (optimal gain matrix K0 has been computed using "dlqr" Matlab function)
    u_cmd=K0*(x0_in-x_ref_in);
    
    %saturation
    for i=1:length(u_cmd)
        if u_cmd(i)<u_min(i)
            u_cmd(i)=u_min(i);
        elseif u_cmd(i)>u_max(i)
            u_cmd(i)=u_max(i);
        end
    end
    
	matlab_u_out=u_cmd;

	%save u_out_log
	filename = strcat('../test_hil/results/matlab_u_out_log.dat');
	fid = fopen(filename, 'a+');
   
	for j=1:length(matlab_u_out)
		fprintf(fid, '%2.18f,',matlab_u_out(j));
	end
	fprintf(fid, '\n');

	fclose(fid);

end
