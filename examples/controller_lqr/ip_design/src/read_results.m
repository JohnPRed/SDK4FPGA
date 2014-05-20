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



function read_results(num_simulation,sim_type)


tmp_str=strcat('Reading simulation result set  ', num2str(num_simulation));
disp(tmp_str);

load LQR_example.mat
nx=size(sysd.a,1); %number of states
nu=size(sysd.b,2); %number of inputs
ny=size(sysd.c,1); %number of outputs


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read random stimulus vector x0_in.
load x0_in.dat;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read random stimulus vector x_ref_in.
load x_ref_in.dat;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read simulation results u_out.
load u_out.dat;

	%save u_out_log
	filename = strcat('../', sim_type, '/results/fpga_u_out_log.dat');
	fid = fopen(filename, 'a+');
   
	for j=1:length(u_out)
		fprintf(fid, '%2.18f,',u_out(j));
	end
	fprintf(fid, '\n');

	fclose(fid);



	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% compute with Matlab and save in a file simulation results u_out


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
	
   

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%save u_in_log
	filename = strcat('../', sim_type, '/results/matlab_u_out_log.dat');
	fid = fopen(filename, 'a+');
   
	for j=1:length(matlab_u_out)
		fprintf(fid, '%2.18f,',matlab_u_out(j));
	end
	fprintf(fid, '\n');

	fclose(fid);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%write a dummy file to tell tcl script to continue with the execution

filename = strcat('_locked');
fid = fopen(filename, 'w');
fprintf(fid, 'locked write\n');
fclose(fid);

quit;

end
