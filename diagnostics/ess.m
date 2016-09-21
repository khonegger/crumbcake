function out = ess(y)
% Compute the Estimated Sample Size (ESS) of MCMC chain.
% See: Kass, Carlin, Gelman, & Neal, 1998, p. 99.

N = length(y);      % total timeseries samples
acf = 1;            % initialize ACF value at 1
k = 1;              % initialize lag at 1

while acf(end) >= 0.05
    acf(k) = autocorr(y,k);
    k = k + 1;
end

out = N / (1 + 2*sum(acf));
