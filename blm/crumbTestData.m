function [data, model_specs] = crumbTestData(n_samples, censor_int, family, betas, gammas, nu)
% Generate simple test set for Bayesian heteroscedastic regression model
% using variable and an intercept

if nargin < 5
    gammas = [0.05 0.01];
end

if nargin < 4
    betas = [0.5 0.1];
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


%{

% Distribution family to draw from
family = 't';
nu_real = 500;

% Number of samples
n_samples = 5e3;

% Set target coeffs
betas = [0.5 0];   % mean effects
g_real = [0.05 0.01]; % variance effects (additive)

%}

% Should data be censored?
if ~isempty(censor_int), do_censor = 1; end

% Generate data
switch family
    
    
    case {'norm','normal'}
        
        treatment = [ones(n_samples,1) random('bino',1,0.5*ones(n_samples,1))];
        
        x1 = treatment * betas';
        x2 = treatment * gammas';
        
        outcome = random('norm', x1, sqrt(x2));
        
        
    case 't'
        
        treatment = [ones(n_samples,1) random('bino',1,0.5*ones(n_samples,1))];
        
        x1 = treatment * betas';
        x2 = treatment * gammas';
        
        outcome = random('tlocationscale', x1, ...
                         sqrt( x2 * ((nu_real-2) / nu) ), nu);
        
end

if do_censor
    outcome(outcome < censor_int(1)) = 0;
    outcome(outcome > censor_int(2)) = 1;
    model_specs.censor = censor_int;
end


% Format model_specs struct
data = [treatment outcome];
model_specs.coeffs = [betas; gammas];
model_specs.family = family;

if nargin < 6 && strcmpi(family,'t')
    model_specs.shape = nu;
end