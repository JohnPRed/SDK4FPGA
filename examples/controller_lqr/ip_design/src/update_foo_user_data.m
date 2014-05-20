

%load example data
load LQR_example.mat

nx=size(sysd.a,1); %number of states
nu=size(sysd.b,2); %number of inputs
ny=size(sysd.c,1); %number of outputs






%% make update_foo_user_data.txt
% Contains the staic variable declaration used by foo_user.cpp
fid = fopen('update_foo_user_data.txt', 'w');


fprintf(fid, '\n');
fprintf(fid, 'const unsigned nx =%d;\n',nx);
fprintf(fid, 'const unsigned nu =%d;\n',nu);



fprintf(fid, '\n');
fprintf(fid, '\n');

% K0
fprintf(fid, '//row, column\n');
fprintf(fid, 'static data_t K0[nu][nx]={\n');
for i=1:size(K0,1)
    fprintf(fid, '{');
    for j=1:size(K0,2)-1
        fprintf(fid, '%10.40f,',K0(i,j));
    end
    j=j+1;
    fprintf(fid, '%10.40f},\n',K0(i,j));
end
fprintf(fid, '};\n');
fprintf(fid, '\n');



% u_min
fprintf(fid, '//column\n');
fprintf(fid, 'static data_t u_min[nu]={\n');
for j=1:length(u_min)-1
    fprintf(fid, '%10.40f,',u_min(j));
end
j=j+1;
fprintf(fid, '%10.40f};\n',u_min(j));
fprintf(fid, '\n');

% u_max
fprintf(fid, '//column\n');
fprintf(fid, 'static data_t u_max[nu]={\n');
for j=1:length(u_max)-1
    fprintf(fid, '%10.40f,',u_max(j));
end
j=j+1;
fprintf(fid, '%10.40f};\n',u_max(j));
fprintf(fid, '\n');




fid = fclose(fid);



