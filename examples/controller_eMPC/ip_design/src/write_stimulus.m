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



function write_testbench(num_simulation,sim_type)


tmp_str=strcat('Writing stimulus files set ', num2str(num_simulation));
disp(tmp_str);



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

% x0=[-pi*2/3  0];
x0=[-0.472312121235472390  0.392640262630393310];


if (num_simulation>0)
	
   
    %% Apply plant model
	x0 = A*x0 + B*u_out(1:nu);
	

end




	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write x_in.dat to file
filename = strcat('x_in.dat');
fid = fopen(filename, 'w+');
   
for j=1:length(x0)
	fprintf(fid, '%2.18f\n',x0(j));
end

fclose(fid);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save x_in_log
filename = strcat('../', sim_type, '/results/x_in_log.dat');
fid = fopen(filename, 'a+');
   
for j=1:length(x0)
	fprintf(fid, '%2.18f,',x0(j));
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
