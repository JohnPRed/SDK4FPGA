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

load FGM_example.mat
nx=size(A_d,1);
nu=size(B_d,2);

Fxr=[Fx,Fr];                            % This can be precomputed
invH0 = inv(H);                         % This can be precomputed
dualH0 = Aineq*invH0*Aineq';            % This can be precomputed
sh = diag(1./sqrt(sum(abs(dualH0),2))); % This can be precomputed
dualH = sh*dualH0*sh;                   % This can be precomputed
premat_xout = -invH0*Aineq'*sh;         % This can be precomputed
premat_xr = -invH0*Fxr;                 % This can be precomputed


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read random stimulus vector x_in.
load x_in.dat;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read random stimulus vector num_iter_in.
load num_iter_in.dat;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read simulation results x_out.
load x_out.dat;

	%save x_out_log
	filename = strcat('../', sim_type, '/results/fpga_x_out_log.dat');
	fid = fopen(filename, 'a+');
   
	for j=1:length(x_out)
		fprintf(fid, '%2.18f,',x_out(j));
	end
	fprintf(fid, '\n');

	fclose(fid);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute with Matlab and save in a file simulation results x_out


  %initialization
    x = zeros(size(dualH,1),1);
    y = x;


    %% process
    %(algotihm's steps that will be implemented on the FPGA)
    for k2=1:num_iter_in(1)

        k2
        
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



	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%save x_in_log
	filename = strcat('../', sim_type, '/results/matlab_x_out_log.dat');
	fid = fopen(filename, 'a+');
   
	for j=1:length(matlab_x_out)
		fprintf(fid, '%2.18f,',matlab_x_out(j));
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
