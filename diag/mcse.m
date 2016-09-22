function mcstderr = mcse(blm)
%MCSE Calculate the simple Monte Carlo Standard Error of MCMC chain.
%   MCSTDERR = MCSE(BLM) returns the MCSE of the chain in Bayesian linear
%   model object, BLM.
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


mcstderr = std(blm.coeffs) / sqrt(ess(blm));