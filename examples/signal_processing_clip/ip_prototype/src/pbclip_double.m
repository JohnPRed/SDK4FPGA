function theta_out = pbclip_double(x,bmax,bmix,w,L,beta,max_iter)

% PBCLIP - Perform perception-based clipping as proposed in [1].
%
%   Y = PBCLIP(X,T,W,L,DELTA,KMAX) clips the input audio frame  
%   (X) for a given clipping level (T) and returns the clipped audio 
%   signal (Y). The perceptual weights (W) are assumed to be pre-
%   computed, as well as the Lipschitz constant (L) of the gradient, 
%   and the per-iteration weights (DELTA) of the fast gradient method. 
%   KMAX is the fixed number of iterations of the fast gradient method.
%
%   Author:     Bruno Defraene
%               Electrical Engineering Department
%               KU Leuven, Belgium
%
%   Contact:    bruno.defraene@esat.kuleuven.be
%
%   References:
%    [1]    Bruno Defraene, Toon van Waterschoot, Hans Joachim Ferreau, Moritz
%           Diehl, and Marc Moonen, "Real-time perception-based clipping of 
%           audio signals using convex optimization", IEEE Transactions on 
%           Audio, Speech, and Language Processing, vol. 20, nr. 10, December 
%           2012, pp. 2657-2671
% 
%   Copyright (c) 2009--2013 by Bruno Defraene


% Define frame length
N = length(x);

% Define per-sample upper and lower clipping bounds
% Uvec = ones(1,N)*T;
% Lvec = -ones(1,N)*T;

% Initialize variables
y = x;
theta = x;

fft_ifft=zeros(1,N);

% Initialize iteration counter
k = 1;

% Iterative projected gradient method
while k<=max_iter 
    
    
    % Compute gradient 2
    Grad = fft_ifft*L; %L=1/lipschitzConstants
    
    % Perform gradient step
    theta_tilde = y-Grad;

    % Project onto clipping constraints
    theta_new = max(min(theta_tilde,bmax),bmix);

    % Compute weighted sum of previous iterates
    beta_theta_delta = beta(k)*(theta_new-theta);
    y_new = theta_new + beta_theta_delta;

    %compute vector to send to fft in the nect iteration
    to_fft=y_new-x;
    
    % Store last iterate
    theta = theta_new;
    y= y_new;
    
    % Compute gradient 1
%     fft_ifft=fft(to_fft,N).*w;
    fft_ifft=(ifft(fft(to_fft,N).*w,N));

    % Increment iteration counter
    k = k+1;

end

theta_out=double(theta);

end

    
    
