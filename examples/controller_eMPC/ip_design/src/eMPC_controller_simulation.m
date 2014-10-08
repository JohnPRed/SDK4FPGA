%% Inverted pendulum Explict MPC example design: closed loop simulation
function eMPC_controller_simulation

% Andrea Suardi [a.suardi@imperial.ac.uk]
% supports MPT 2.6.3 (http://control.ee.ethz.ch/~mpt/2/downloads/)

addpath('functions');

filename=strcat('eMPC_inverted_pendulum.mat');
load(filename);

Tsim=20;%simulation time [s]

FractionLength=12; %number of bits used to represent the fraction length

 %point location
FIX_X1_FractionLength=FractionLength;
FIX_H_FractionLength=FractionLength;
FIX_K_FractionLength=FractionLength;
%function evaluation
FIX_X2_FractionLength=FractionLength;
FIX_F_FractionLength=FractionLength;
FIX_G_FractionLength=FractionLength;


constraint=pi/8;
x0=[-pi*2/3  0];

u=0;

close all



%simulation double precision NOT robust
[DOUBLE_J_cl,DOUBLE_feasible,DOUBLE_xstore,DOUBLE_ustore,DOUBLE_ystore,DOUBLE_regionstore]=double_simulation_explicit_controller(ctrl,Tsim,x0);


%simulation fixed-point NOT robust
xmax=[ctrl.sysStruct.xmax, ctrl.sysStruct.xmin];
[FIX_X1_IntegerLength,FIX_X2_IntegerLength,FIX_F_IntegerLength,FIX_G_IntegerLength,FIX_H_IntegerLength,FIX_K_IntegerLength] = FIX_eMPC_quantizer(ctrl,xmax);

bits=[FIX_X1_IntegerLength,FIX_X2_IntegerLength,FIX_F_IntegerLength,FIX_G_IntegerLength,FIX_H_IntegerLength,FIX_K_IntegerLength]+[FIX_X1_FractionLength,FIX_X2_FractionLength,FIX_F_FractionLength,FIX_G_FractionLength,FIX_H_FractionLength,FIX_K_FractionLength];		
[FIX_J_cl,FIX_feasible,FIX_xstore,FIX_ustore,FIX_ystore,FIX_regionstore]=FIX_simulation_explicit_controller(ctrl,Tsim,bits,FIX_X1_FractionLength,FIX_H_FractionLength,FIX_K_FractionLength,FIX_X2_FractionLength,FIX_F_FractionLength,FIX_G_FractionLength,x0);
  
 
figure
hold on
plot(FIX_xstore(1,:)','b')
hold on
plot(DOUBLE_xstore(1,:)','--b')
legend('Fixed-point','Double')
title('state(1)')
    
figure
hold on
plot(FIX_xstore(2,:)','b')
hold on
plot(DOUBLE_xstore(2,:)','--b')
legend('Fixed-point','Double')
title('state(2)')


figure
hold on
plot(FIX_ustore(1,:)','b')
hold on
plot(DOUBLE_ustore(1,:)','--b')
hold on
legend('Fixed-point','Double')
title('input(1)')

