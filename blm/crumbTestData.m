function [data, model_specs] = crumbTestData(n_samples, censor_int, family, betas, gammas, nu)
%CRUMBTESTDATA Generate fake data for testing CRMBCK model.
%   [DATA, MODEL_SPECS] = CRUMBTESTDATA(N_SAMPLES, CENSOR_INT, FAMILY, BETAS, GAMMAS, NU)
%   generates DATA, an N_SAMPLES by 3 matrix of observations simulating
%   control and treatment conditions, sampled from the distributions
%   defined by other arguments.
% 
%   N_SAMPLES is the desired number of simulated data points.  Samples will
%   be asigned to the virtual "treatment" group with a probability of 0.5.
% 
%   CENSOR_INT is the interval over which censoring should occur.  For
%   example, an interval of [0 1] will set any simulated values >1 to
%   exactly one, and any values <0 will be set to exactly zero.  If no
%   censoring is desired (default), pass the function an empty set: [].
% 
%   FAMILY is a string specifying model family. Valid distributions are:
% 
%       'normal'   - normal distribution (default)
%       't'        - Student's t distribution
%       'binomial' - binomial distribution            **not yet implemented
% 
%   BETAS is a two element array containing the "true" beta coefficients -
%   the baseline mean and the effect of treatment on the mean - from which
%   simulated points are drawn: [BASELINE TREATMENT].  For example, the
%   array [0.5 -0.1] specifies the baseline mean to be 0.5 and the
%   treatment effect is expected to reduce the baseline by 0.1, i.e. the
%   expected mean is 0.5 for control samples and 0.4 for treatment samples.
% 
%   GAMMAS is the variance equivalent of BETAS: [BASELINE_VAR
%   TREATMENT_VAR]. Default values are [0.05 0.01].
% 
%   NU (optional) is the degrees of freedom parameter for specifying a
%   t-distribution.  Value must be > 2. Default value for nu is 5, if 't'
%   is specified as FAMILY.
% 
% 
%   DATA is an N_SAMPLES by 3 matrix of simulated data, where each row is
%   an observation.  The first column is an array of ones (for fitting the
%   intercept), the second column indicates virtual "treatment" condition,
%   and the third column is the (censored) response variable.
% 
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

%{
      To do:
                1. Add binomial simulation capability.  Will require a bit of
                argument retooling.  Probably a good task for inputParser.
%}


% ---------------------------------------------------------
% Parse arguments and set model defaults

if nargin < 5
    gammas = [0.05 0.01];
end

if nargin < 4
    betas = [0.5 -0.1];
end

if nargin < 3
    family = 'norm';
end

if nargin < 2
	censor_int = [];
end

if nargin < 1
    n_samples = 1e3;
end

if nargin < 6 && strcmpi(family,'t')
    nu = 5;
end


% ---------------------------------------------------------
% Set flag for data censoring
if ~isempty(censor_int)
    do_censor = 1;
else
    do_censor = 0;
end


% ---------------------------------------------------------------
% Compute "true" underlying parameter values for each sample, 
% based on virtual treatment condition and specified coefficients

% Randomly assign to treatment condition with probability 0.5
treatment = [ones(n_samples,1) rand(n_samples,1)>0.5];


% Make vectors giving the total mean and variance for each sample,
% according to the treatment condition of each
x1 = treatment * betas';  %total mean
x2 = treatment * gammas'; %total variance (additive)


% -----------------------------------------------------------
% Generate fake data by sampling from specified distributions

switch family
    
    
    case {'norm','normal'}
        
        outcome = random('norm', x1, sqrt(x2));
        
        
    case 't'
        
        outcome = random('tlocationscale', x1, ...
                         sqrt( x2 * ((nu - 2) / nu) ), nu);
        
end


if do_censor
    outcome(outcome < censor_int(1)) = censor_int(1);
    outcome(outcome > censor_int(2)) = censor_int(2);
    model_specs.censor = censor_int;
end

% -----------------------------------------------------------
% Format model_specs struct
data = [treatment outcome];
model_specs.coeffs = [betas; gammas];
model_specs.family = family;
if strcmpi(family,'t'), model_specs.shape = nu; end