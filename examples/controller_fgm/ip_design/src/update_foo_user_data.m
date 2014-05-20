
%load example data
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


xrlvec=[x0;xref;1];
xr=[x0;xref];
b=Bineq0 + Bineq*x0;
FTxrl_int=[Aineq*invH0*Fxr, b];
FTxrl = (sh*[Aineq*invH0*Fxr, b])';
f = FTxrl'*xrlvec; %this will be passed to the FPGA




%% make update_foo_user_data.txt
% Contains the staic variable declaration used by foo_user.cpp
fid = fopen('update_foo_user_data.txt', 'w');




fprintf(fid, '\n');
fprintf(fid, '\n');

% dualH
fprintf(fid, '//row, column\n');
fprintf(fid, 'static data_t dualH[N][N]={\n');
for i=1:size(dualH,1)
    fprintf(fid, '{');
    for j=1:size(dualH,2)-1
        fprintf(fid, '%10.40f,',dualH(i,j));
    end
    j=j+1;
    fprintf(fid, '%10.40f},\n',dualH(i,j));
end
fprintf(fid, '};\n');
fprintf(fid, '\n');



% b_min
fprintf(fid, '//column\n');
fprintf(fid, 'static data_t b_min[N]={\n');
for j=1:length(bmin)-1
    fprintf(fid, '%10.40f,',bmin(j));
end
j=j+1;
fprintf(fid, '%10.40f};\n',bmin(j));
fprintf(fid, '\n');

% b_max
fprintf(fid, '//column\n');
fprintf(fid, 'static data_t b_max[N]={\n');
for j=1:length(bmax)-1
    fprintf(fid, '%10.40f,',bmax(j));
end
j=j+1;
fprintf(fid, '%10.40f};\n',bmax(j));
fprintf(fid, '\n');

% beta_iter
fprintf(fid, '//column\n');
fprintf(fid, 'static data_t beta_iter[%d]={\n',length(beta_iter));
for j=1:length(beta_iter)-1
    fprintf(fid, '%10.40f,',beta_iter(j));
end
j=j+1;
fprintf(fid, '%10.40f};\n',beta_iter(j));
fprintf(fid, '\n');



fid = fclose(fid);



