function out = mcse(y)
% Calculate the simple Monte Carlo Standard Error of MCMC chain.

out = std(y) / sqrt(ess(y));