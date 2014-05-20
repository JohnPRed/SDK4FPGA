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
num_simulation=3000;


load FGM_example.mat
nx=size(A_d,1);
nu=size(B_d,2);

num_iter_in=ones(1,40)*num_iter;



for i=1:num_simulation
    
    [num_simulation-i]

	%% preprocess
	%(algotihm's steps that will be implemented on the CPU)
	Fxr=[Fx,Fr];                            % This can be precomputed
	invH0 = inv(H);                         % This can be precomputed
	dualH0 = Aineq*invH0*Aineq';            % This can be precomputed
	sh = diag(1./sqrt(sum(abs(dualH0),2))); % This can be precomputed
	dualH = sh*dualH0*sh;                   % This can be precomputed
	premat_xout = -invH0*Aineq'*sh;         % This can be precomputed
	premat_xr = -invH0*Fxr;                 % This can be precomputed


	if (i>1)

		x_out=fpga_x_out;
		
		%% postprocess
		%(algotihm's instruction that will be implemented on the CPU)
		theta = premat_xout*x_out + premat_xr*[x0;xref];
	   
		%% Apply plant model
		u_out = theta(1:nu);
		x0 = A_d*x0 + B_d*u_out;
		

	end
	
	xrlvec=[x0;xref;1];
	xr=[x0;xref];
	b=Bineq0 + Bineq*x0;
	FTxrl_int=[Aineq*invH0*Fxr, b];
	FTxrl = (sh*FTxrl_int)';
	x_in = FTxrl'*xrlvec; %this will be passed to the FPGA

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%save x0_log
	filename = strcat('../test_hil/results/x0_log.dat');
	fid = fopen(filename, 'a+');
	   
	for j=1:length(x0)
		fprintf(fid, '%2.18f,',x0(j));
	end
		fprintf(fid, '\n');

	fclose(fid);


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%save x_in_log
	filename = strcat('../test_hil/results/x_in_log.dat');
	fid = fopen(filename, 'a+');
   
	for j=1:length(x_in)
		fprintf(fid, '%2.18f,',x_in(j));
	end
	fprintf(fid, '\n');

	fclose(fid);




	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%save num_iter_in_log
	filename = strcat('../test_hil/results/num_iter_in_log.dat');
	fid = fopen(filename, 'a+');
   
	for j=1:length(num_iter_in)
		fprintf(fid, '%2.18f,',num_iter_in(j));
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
	data_to_send=x_in;
	FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);

	% send num_iter_in
	Packet_type=3; % 1 for reset, 2 for start, 3 for write to IP vector packet_internal_ID, 4 for read from IP vector packet_internal_ID of size packet_output_size
	packet_internal_ID=1;
	packet_output_size=1;
	data_to_send=num_iter_in;
	FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);


	% start FPGA
	Packet_type=2; % 1 for reset, 2 for start, 3 for write to IP vector packet_internal_ID, 4 for read from IP vector packet_internal_ID of size packet_output_size
	packet_internal_ID=0;
	packet_output_size=1;
	data_to_send=0;
	FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);


	% read data from FPGA
	% read x_out
	Packet_type=4; % 1 for reset, 2 for start, 3 for write to IP vector packet_internal_ID, 4 for read from IP vector packet_internal_ID of size packet_output_size
	packet_internal_ID=0;
	packet_output_size=40;
	data_to_send=0;
	[output_FPGA, ~, ~] = FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);
	fpga_x_out=output_FPGA;

	%save x_out_log
	filename = strcat('../test_hil/results/fpga_x_out_log.dat');
	fid = fopen(filename, 'a+');
   
	for j=1:length(fpga_x_out)
		fprintf(fid, '%2.18f,',fpga_x_out(j));
	end
	fprintf(fid, '\n');

	fclose(fid);


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% compute with Matlab and save in a file simulation results

	% Simulation results x_out
	%initialization
    x = zeros(size(dualH,1),1);
    y = x;


    %% process
    %(algotihm's steps that will be implemented on the FPGA)
    for k2=1:num_iter_in(1)
        
        % Cache previous value of x
        xprev = x;

        % Calculate gradient
        gradJ = dualH*y+x_in;

        % Update x (from preconditioning, the value "L" is zero)
        xtilde = y - gradJ;

        % Project onto feasible region
        for k3 = 1:size(x,1)
            x(k3) = xtilde(k3);
            if xtilde(k3) > bmax(k3)
                x(k3) = bmax(k3); 
            end
            if xtilde(k3) < bmin(k3)
                x(k3) = bmin(k3);
            end
        end


        % Calculate difference between x and xprev
        xdiff = x-xprev;


        % Update y
        y = x+beta_iter(k2)*xdiff;


    end

    matlab_x_out = x; %this will be read from the FPGA

	%save x_out_log
	filename = strcat('../test_hil/results/matlab_x_out_log.dat');
	fid = fopen(filename, 'a+');
   
	for j=1:length(matlab_x_out)
		fprintf(fid, '%2.18f,',matlab_x_out(j));
	end
	fprintf(fid, '\n');

	fclose(fid);

end
