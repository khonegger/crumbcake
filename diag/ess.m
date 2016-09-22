function n_est = ess(y)
%ESS Calculate the Estimated Sample Size (ESS) of MCMC chain
%   N_EST = ESS(Y) calculates the ESS of MCMC chain, Y.
%   See: Kass, Carlin, Gelman, & Neal, 1998, p. 99.
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

N = length(y);   % total timeseries samples
acf = 1;         % initialize ACF value at 1
k = 1;           % initialize lag at 1

while acf(end) >= 0.05
    acf(k) = autocorr(y,k);
    k = k + 1;
end

n_est = N / (1 + 2*sum(acf));
