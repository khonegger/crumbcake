function acf = autocorr(y,K)
% Compute autocorrelation of timeseries, y, at lag values K.  K can be a
% vector of positive integers, or a single scalar.
%
%     Kyle Honegger, Harvard University
%     h------r@fas.harvard.edu
% 
%     Version: v1.0
%     Last modified: Sept 22, 2016
% 
%     Revision history:
%     16/09/22:   v1.0 completed
%     --


if nargin < 2
    K = 1:20;       % lag values at which to compute ACF
end

T = length(y);      % total timeseries length
mu_y = mean(y);     % timeseries mean
var_y = var(y);     % timeseries variance

acf = [];

for k = K
    
    tmp = [];
    
    for t = 1:(T-k)
        
        tmp(t) = ( y(t) - mu_y ) * ( y(t+k) - mu_y );
        
    end

    acf(end+1) = sum(tmp)/(T-1);
    
end

acf = acf/var_y; % normalize coefficients to 1
