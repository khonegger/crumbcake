function blm = crmbck(data, model_specs, n_steps)
%CRMBCK Fit Bayesian censored heteroscedastic linear model.
%   BLM = fitBayesLM(data, model_specs, var_labels) returns BLM, a
%   structure containing a Bayesian linear model object

%{
  DATA is an m by n+1 matrix of observed values, where m is the number of
  observations and n is the number of factors to include in the model. The
  last column of DATA should be the dependent (outcome) variable. To
  include an intercept term in the model, append a vector of 1's to the
  first column. To include an interaction term, include the product of the
  two factors as its own column. For example, the DATA matrix for a model
  with the form 'y ~ 1 + x1 + x2 + x1*x2' should have 5 columns. Each of
  the first 4 columns will correspond to one pair (beta and gamma) of model
  coefficients for: the intercept, variable x1, variable x2, and the x1*x2
  interaction, respectively. Column 5 contains the outcome (predicted)
  variable, y.


  MODEL_SPECS is a structure containing the fields:

   'coeffs' - A 2 by n array of model coefficients. First row contains
              beta coefficients (mean) and second row contains gamma
              coefficients (dispersion).

   'family' - String specifying model family. Valid distributions are:

              'normal'   - normal distribution (default)
              't'        - Student's t distribution (location-scale form)
              'binomial' - binomial distribution

   'shape'  - Scalar "nu" deg. of freedom parameter. Required only for t
              distribution. Ignored otherwise.

   'censor' - Vector (optional) specifying the interval over which data
              censoring is expected. 'Censor' is a 2 element vector
              specifying the left and right data boundaries, e.g. [0,1].
              If empty, defaults to [-Inf Inf] with no censoring assumed.

   'form'   - ** This is not implemented yet! **                           - KH160908A
              String (optional) specifying form of the regression model
              according to standard R-style notation, e.g.:
                  'y ~ 1 + x1 + x2 + x1*x2'
              When 'form' is set, variables not included in the string
              will not be included in the model. If intercept is desired,
              '1' must be entered as a term in the model.


  VAR_LABELS (optional) is a cell array containing a label for each
  variable.  Right now, this does nothing, but will eventually allow
  arbitrary column assignment of predictors, intercept, and outcome.


  Kyle Honegger, Harvard University
  h------r@fas.harvard.edu

  Version: v0.1
  Last modified: Sept 21, 2016

  Revision history:
  16/09/XX:   v0.1 completed
  --


  To do:
            1.  Implement binomial model
            2.  Function for making priors: {flat, mean, etc.}
            3.  Change t structure to take a static nu, or fit as parameter
            4.  Recast blm structure to model class
            5.  Implement input parsing
            6.  Make it possible to estimate model type as a parameter


%}

        
                
% ---------------------------------------------------------
% Remove 'shape' field if is not needed
if isfield(model_specs,'shape') && ~strcmpi(model_specs.family,'t')
    model_specs = rmfield(model_specs, 'shape');
end



% ---------------------------------------------------------
% Set model fitting parameters
if nargin < 3
    blm.n_steps = 1e4; % Number of steps through MCMC
else
    blm.n_steps = n_steps;
end

blm.slice_width = 1; % Width of slices
blm.init = 50*ones(1, 2*(size(data,2)-1)); % Initial coefficient values

if isfield(model_specs,'shape'), blm.init = [blm.init 400]; end

% Scale up coefficients to improve slice sampling precision
blm.scaling_factor = 100;


% Set priors (move to own fcn)
blm.priors = 0;

% Run slicesample to sample from the Posterior
blm.coeffs = slicesample(blm.init, blm.n_steps, ...
                    'logpdf', @bayesHelper, ...
                    'Width', blm.slice_width) / blm.scaling_factor;

                




                
% ---------------------------------------------------------
% Make pseudo-methods that can be called on output struct

% Function handle to predict outcome given predictor values
blm.eval = @(x) x * median(blm.coeffs)';
                
% Function handle to plot full MCMC chain
blm.plot = @(varargin) plot(blm.coeffs);

% Function handle to scatterplot matrix
blm.splom = @() splom(blm.coeffs);


% ---------------------------------------------------------
% Wrapper to censored log likelihood function

    function out = bayesHelper(b)
        
        % Update shape parameter, if appropriate
        if isfield(model_specs,'shape')
            model_specs.shape = b(end) / blm.scaling_factor; % rescale output
            b(end) = [];
        end
        
        % Reshape and rescale coefficients
        model_specs.coeffs = [b( 1:(length(b)/2) ); ...
                              b( ((length(b)/2)+1):end)] ...
                              / blm.scaling_factor; % rescale output
        
        out = bayesLL(data, model_specs) + blm.priors;
    end

end