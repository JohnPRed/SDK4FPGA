%% Inverted pendulum Explict MPC example design: build controller
function eMPC_controller_build

% Andrea Suardi [a.suardi@imperial.ac.uk]
% supports MPT 2.6.3 (http://control.ee.ethz.ch/~mpt/2/downloads/)

addpath('functions');

Tcon=0.4; %Prediction horizon [s]
fs=10; %sampling frequency [Hz]


N=ceil(Tcon*fs); %simulation steps


% compute NOT robust controller in double precion (NO noise)

noise_store_min(:,1)=[-eps;-eps]; %noise initialization
noise_store_max(:,1)=[eps;eps]; %noise initialization
noise=[noise_store_min(:,1), noise_store_max(:,1)]; %noise

% build controller
[expc,ctrl,yinf,OS] = inverted_pendulum(fs,N,noise);

% save controller
filename=strcat('eMPC_inverted_pendulum.mat');
save(filename, 'expc', 'ctrl','yinf','OS','FractionLength','fs','Tcon','N');

end