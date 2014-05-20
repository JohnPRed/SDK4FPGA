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


load FGM_example.mat
nx=size(A_d,1);
nu=size(B_d,2);

num_iter_in=ones(1,40)*num_iter;

%% preprocess
	%(algotihm's steps that will be implemented on the CPU)
	Fxr=[Fx,Fr];                            % This can be precomputed
	invH0 = inv(H);                         % This can be precomputed
	dualH0 = Aineq*invH0*Aineq';            % This can be precomputed
	sh = diag(1./sqrt(sum(abs(dualH0),2))); % This can be precomputed
	dualH = sh*dualH0*sh;                   % This can be precomputed
	premat_xout = -invH0*Aineq'*sh;         % This can be precomputed
	premat_xr = -invH0*Fxr;                 % This can be precomputed


if (num_simulation>0)
	load x0.dat
	load x_out.dat
	
	%% postprocess
    %(algotihm's instruction that will be implemented on the CPU)
    theta = premat_xout*x_out' + premat_xr*[x0;xref];
   
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
% write x0.dat to file
filename = strcat('x0.dat');
fid = fopen(filename, 'w+');
   
for j=1:length(x0)
	fprintf(fid, '%2.18f\n',x0(j));
end

fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save x0_log
filename = strcat('../', sim_type, '/results/x0_log.dat');
fid = fopen(filename, 'a+');
   
for j=1:length(x0)
	fprintf(fid, '%2.18f,',x0(j));
end
	fprintf(fid, '\n');

fclose(fid);




	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write x_in.dat to file
filename = strcat('x_in.dat');
fid = fopen(filename, 'w+');
   
for j=1:length(x_in)
	fprintf(fid, '%2.18f\n',x_in(j));
end

fclose(fid);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save x_in_log
filename = strcat('../', sim_type, '/results/x_in_log.dat');
fid = fopen(filename, 'a+');
   
for j=1:length(x_in)
	fprintf(fid, '%2.18f,',x_in(j));
end
	fprintf(fid, '\n');

fclose(fid);


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write num_iter_in.dat to file
filename = strcat('num_iter_in.dat');
fid = fopen(filename, 'w+');
   
for j=1:length(num_iter_in)
	fprintf(fid, '%2.18f\n',num_iter_in(j));
end

fclose(fid);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save num_iter_in_log
filename = strcat('../', sim_type, '/results/num_iter_in_log.dat');
fid = fopen(filename, 'a+');
   
for j=1:length(num_iter_in)
	fprintf(fid, '%2.18f,',num_iter_in(j));
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
