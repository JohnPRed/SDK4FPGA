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



function write_testbench(num_simulation,sim_type,offset,num_iter)

num_simulation=num_simulation+1;

tmp_str=strcat('Writing stimulus files set ', num2str(num_simulation));
disp(tmp_str);


load Input_output_data_F1.mat

x_in=inputFrames(num_simulation+offset,:);
bmax_in=ones(1,512)*thresholds(num_simulation+offset);
bmin_in=-ones(1,512)*thresholds(num_simulation+offset);
w_in=weights(num_simulation+offset,:);
lipschitz_in=ones(1,512)*(1/lipschitzConstants(num_simulation+offset));
beta_in=rand(1,512)*0;
beta_in(1,1:size(deltas,2))=deltas(num_simulation+offset,:);
num_iter_in=num_iter*ones(1,512);







	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write bmax_in.dat to file
filename = strcat('bmax_in.dat');
fid = fopen(filename, 'w+');
   
for j=1:length(bmax_in)
	fprintf(fid, '%2.18f\n',bmax_in(j));
end

fclose(fid);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save bmax_in_log
filename = strcat('../', sim_type, '/results/bmax_in_log.dat');
fid = fopen(filename, 'a+');
   
for j=1:length(bmax_in)
	fprintf(fid, '%2.18f,',bmax_in(j));
end
	fprintf(fid, '\n');

fclose(fid);


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write bmin_in.dat to file
filename = strcat('bmin_in.dat');
fid = fopen(filename, 'w+');
   
for j=1:length(bmin_in)
	fprintf(fid, '%2.18f\n',bmin_in(j));
end

fclose(fid);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save bmin_in_log
filename = strcat('../', sim_type, '/results/bmin_in_log.dat');
fid = fopen(filename, 'a+');
   
for j=1:length(bmin_in)
	fprintf(fid, '%2.18f,',bmin_in(j));
end
	fprintf(fid, '\n');

fclose(fid);


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write beta_in.dat to file
filename = strcat('beta_in.dat');
fid = fopen(filename, 'w+');
   
for j=1:length(beta_in)
	fprintf(fid, '%2.18f\n',beta_in(j));
end

fclose(fid);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save beta_in_log
filename = strcat('../', sim_type, '/results/beta_in_log.dat');
fid = fopen(filename, 'a+');
   
for j=1:length(beta_in)
	fprintf(fid, '%2.18f,',beta_in(j));
end
	fprintf(fid, '\n');

fclose(fid);


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write lipschitz_in.dat to file
filename = strcat('lipschitz_in.dat');
fid = fopen(filename, 'w+');
   
for j=1:length(lipschitz_in)
	fprintf(fid, '%2.18f\n',lipschitz_in(j));
end

fclose(fid);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save lipschitz_in_log
filename = strcat('../', sim_type, '/results/lipschitz_in_log.dat');
fid = fopen(filename, 'a+');
   
for j=1:length(lipschitz_in)
	fprintf(fid, '%2.18f,',lipschitz_in(j));
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
% write w_in.dat to file
filename = strcat('w_in.dat');
fid = fopen(filename, 'w+');
   
for j=1:length(w_in)
	fprintf(fid, '%2.18f\n',w_in(j));
end

fclose(fid);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save w_in_log
filename = strcat('../', sim_type, '/results/w_in_log.dat');
fid = fopen(filename, 'a+');
   
for j=1:length(w_in)
	fprintf(fid, '%2.18f,',w_in(j));
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
