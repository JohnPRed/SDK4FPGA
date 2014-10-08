%% Inverted pendulum Explict MPC example design: make header (eMPC_data.h) file to be used for building FPGA hardware
function eMPC_controller_make_header

% Andrea Suardi [a.suardi@imperial.ac.uk]
% supports MPT 2.6.3 (http://control.ee.ethz.ch/~mpt/2/downloads/)


addpath('functions');

filename=strcat('eMPC_inverted_pendulum.mat');
load(filename);

FractionLength=12; %number of bits used to represent the fraction length

[min_depth, max_depth] = searchTree_analysis(ctrl);
tree=ctrl.details.searchTree;
[nodes, ~]=size(tree);


G=ctrl.Gi;
F=ctrl.Fi;
Nr = length(ctrl.Pn);% number of regions
nx=size(ctrl.sysStruct.B,1);
nu=size(ctrl.sysStruct.B,2);



xmax=[ctrl.sysStruct.xmax, ctrl.sysStruct.xmin];
[FIX_X1_IntegerLength,FIX_X2_IntegerLength,FIX_F_IntegerLength,FIX_G_IntegerLength,FIX_H_IntegerLength,FIX_K_IntegerLength] = FIX_eMPC_quantizer(ctrl,xmax);

IntegerLength=max([FIX_X1_IntegerLength,FIX_X2_IntegerLength,FIX_F_IntegerLength,FIX_G_IntegerLength,FIX_H_IntegerLength,FIX_K_IntegerLength]);



%%
fid = fopen('eMPC_data.h', 'w');

fprintf(fid, '#include <vector>\n');
fprintf(fid, '#include <iostream>\n');
fprintf(fid, '#include <stdio.h>\n');
fprintf(fid, '#include "math.h"\n');
fprintf(fid, '#include "ap_fixed.h"\n');
fprintf(fid, '#include <stdint.h>\n');
fprintf(fid, '#include <cstdlib>\n');
fprintf(fid, '#include <cstring>\n');
fprintf(fid, '#include <stdio.h>\n');
fprintf(fid, '#include <math.h>\n');
fprintf(fid, '#include <fstream>\n');
fprintf(fid, '#include <string>\n');
fprintf(fid, '#include <sstream>\n');
fprintf(fid, '#include <vector>\n');
fprintf(fid, '\n');
fprintf(fid, '\n');
fprintf(fid, '// Define FIX_IMPLEMENTATION to enable  fixed-point (up to 32 bits word length) arithmetic precision or \n');
fprintf(fid, '// FLOAT_IMPLEMENTATION to enable floating-point single arithmetic precision.\n');
fprintf(fid, '#define FIX_IMPLEMENTATION\n');
fprintf(fid, '\n');
fprintf(fid, '#define INTEGERLENGTH %d\n',IntegerLength);
fprintf(fid, '#define FRACTIONLENGTH %d\n',FractionLength);
fprintf(fid, '\n');
fprintf(fid, '\n');
fprintf(fid, '#define N %d\n',nx);
fprintf(fid, '#define M %d\n',nu);
fprintf(fid, '#define ST_NUM_REGIONS %d\n',Nr);
fprintf(fid, '#define ST_NUM_HYPERPLANES %d\n',nodes);
fprintf(fid, '#define ST_MAX_DEPTH %d\n',max_depth);
fprintf(fid, '\n');
fprintf(fid, '\n');
fprintf(fid, '#ifdef FIX_IMPLEMENTATION\n');
fprintf(fid, '	typedef ap_fixed<INTEGERLENGTH+FRACTIONLENGTH,INTEGERLENGTH,AP_TRN_ZERO,AP_SAT> data_t;\n');
fprintf(fid, '	typedef ap_fixed<32,32-FRACTIONLENGTH,AP_TRN_ZERO,AP_SAT> data_t_interface;\n');
fprintf(fid, '	typedef uint32_t data_t_memory;\n');
fprintf(fid, '#endif\n');
fprintf(fid, '\n');
fprintf(fid, '#ifdef FLOAT_IMPLEMENTATION\n');
fprintf(fid, '	typedef float data_t;\n');
fprintf(fid, '	typedef float data_t_interface;\n');
fprintf(fid, '	typedef float data_t_memory;\n');
fprintf(fid, '#endif\n');
fprintf(fid, '\n');
fprintf(fid, '\n');

% MPT_ST_H
fprintf(fid, '//row, column\n');
fprintf(fid, 'static data_t MPT_ST_H[ST_NUM_HYPERPLANES][N]={\n');
for i=1:nodes
    fprintf(fid, '{');
    for j=1:nx-1
        fprintf(fid, '%10.40f,',tree(i,j));
    end
    j=j+1;
    fprintf(fid, '%10.40f},\n',tree(i,j));
end
fprintf(fid, '};\n');
fprintf(fid, '\n');


% MPT_ST_ALPHA
fprintf(fid, '//row\n');
fprintf(fid, 'static data_t MPT_ST_ALPHA[ST_NUM_HYPERPLANES]={\n');
for j=1:nodes-1
    fprintf(fid, '%10.40f,',tree(j,nx+1));
end
j=j+1;
fprintf(fid, '%10.40f};\n',tree(j,nx+1));
fprintf(fid, '\n');

% MPT_ST_RIGHT
fprintf(fid, '//row\n');
fprintf(fid, 'static int MPT_ST_RIGHT[ST_NUM_HYPERPLANES]={\n');
for j=1:nodes-1
    if tree(j,nx+3)>0
        fprintf(fid, '%d,',tree(j,nx+3)-1);
    else
        fprintf(fid, '%d,',tree(j,nx+3)+1);
    end
end
j=j+1;
if tree(j,nx+3)>0
    fprintf(fid, '%d};\n',tree(j,nx+3)-1);
else
    fprintf(fid, '%d};\n',tree(j,nx+3)+1);
end
fprintf(fid, '\n');

% MPT_ST_LEFT
fprintf(fid, '//row\n');
fprintf(fid, 'static int MPT_ST_LEFT[ST_NUM_HYPERPLANES]={\n');
for j=1:nodes-1
    if tree(j,nx+2)>0
        fprintf(fid, '%d,',tree(j,nx+2)-1);
    else
        fprintf(fid, '%d,',tree(j,nx+2)+1);
    end
end
j=j+1;
if tree(j,nx+2)>0
    fprintf(fid, '%d};\n',tree(j,nx+2)-1);
else
    fprintf(fid, '%d};\n',tree(j,nx+2)+1);
end
fprintf(fid, '\n');


% MPT_F
fprintf(fid, '//row, column\n');
fprintf(fid, 'static data_t MPT_F[ST_NUM_REGIONS*M][N]={\n');
for i=1:Nr
    fprintf(fid, '{');
    F_tmp=cell2mat(F(i));
    for j1=1:size(F_tmp,1)
        for j2=1:nx-1
            fprintf(fid, '%10.40f,',F_tmp(j1,j2));
        end
        j2=j2+1;
        fprintf(fid, '%10.40f},\n',F_tmp(j1,j2));
    end
end
fprintf(fid, '};\n');
fprintf(fid, '\n');


% MPT_G
fprintf(fid, '//row\n');
fprintf(fid, 'static data_t MPT_G[ST_NUM_HYPERPLANES]={\n');
for i=1:Nr
    G_tmp=cell2mat(G(i));
        for j=1:size(G_tmp,1)
            if i<Nr
                fprintf(fid, '%10.40f,',G_tmp(j,1));
            else
               fprintf(fid, '%10.40f};\n',G_tmp(j,1));
            end
        end
end




fid = fclose(fid);


% end