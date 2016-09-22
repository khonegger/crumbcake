function log_likelihood = bayesLL(data, model_specs)
%BAYESLL Compute log likelihood of data given a specified model.
%   LOG_LIKELIHOOD = BAYESLL(DATA, MODEL_SPECS) returns the 
%   log likelihood of DATA, under a model specified by MODEL_SPECS 
%   structure.
%
%   DATA is an m by n+1 matrix of observed values, where m is the number of
%   observations and n is the number of factors to include in the model.
%   The last column of DATA should be the dependent (outcome) variable. To
%   include an intercept term in the model, append a vector of 1's to the
%   first column. To include an interaction term, include the product of
%   the two factors as its own column. For example, the DATA matrix for a
%   model with the form 'y ~ 1 + x1 + x2 + x1*x2' should have 5 columns.
%   Each of the first 4 columns will correspond to one pair (beta and
%   gamma) of model coefficients for: the intercept, variable x1, variable
%   x2, and the x1*x2 interaction, respectively. Column 5 contains the
%   outcome (predicted) variable, y.
%
%   MODEL_SPECS is a structure containing the fields:
% 
%   'coeffs' - A 2 by n array of model coefficients. First row contains
%              beta coefficients (mean) and second row contains gamma
%              coefficients (dispersion).
% 
%   'family' - String specifying model family. Valid distributions are:
%   
%              'normal'   - normal distribution (default)
%              't'        - Student's t distribution (location-scale form)
%              'binomial' - binomial distribution (not yet implemented)
% 
%   'shape'  - Scalar "nu" deg. of freedom parameter. Required only for t
%             distribution. Ignored otherwise.
% 
%   'censor' - Vector (optional) specifying the interval over which data
%              censoring is expected. 'Censor' is a 2 element vector
%              specifying the left and right data boundaries, e.g. [0,1].
%              If empty, defaults to [-Inf Inf] with no censoring assumed.
% 
%  'form'   - ** This is not implemented yet! **                           - KH160908
%             String (optional) specifying form of the regression model
%             according to standard R-style notation, e.g.:
%                 'y ~ 1 + x1 + x2 + x1*x2'
%             When 'form' is set, variables not included in the string
%             will not be included in the model. If intercept is desired,
%             '1' must be entered as a term in the model.
%
%
%     Kyle Honegger, Harvard University
%     h------r@fas.harvard.edu
% 
%     Version: v0.1
%     Last modified: Sept 22, 2016
% 
%     Revision history:
%     16/09/XX:   v0.1 completed
%     --

%{
  To do:
            1.  Implement binomial model
%}


% -----------------------------------------     -KH160922 too much overhead
% Check inputs and set defaults, if needed       move to invoking function

if ~isfield(model_specs,'coeffs')
    % Model coefficients are absolutely needed
    error('No model coeffecients specified')
end

if ~isfield(model_specs,'family')
    % Defaults to 'normal'
    model_specs.family = 'normal';
end

if ~isfield(model_specs,'censor')
    % Defaults to [-Inf Inf]
    model_specs.censor = [-Inf Inf];
end
% -----------------------------------------



% Placeholder for future variable: zero if not specified,
% otherwise handle to function for calculating additional
% source of variance, eg distance traveled.
additional_var = 0;




%Set up environment for specified model Note, DATA and MODEL_SPECS are 
%shared across helper fcns 
% -----------------------------------------

predictors = data(:,1:end-1);

outcome = data(:,end);

model_env = set_model_environment();

% -----------------------------------------



% Calculate the log likelihood of the data
% given the specified model
% -----------------------------------------

% Explicitly disallow variance <= 0
if any( ~isreal(model_env.get_sigma(predictors, model_specs.coeffs(2,:))) )   

    % Return infinitesimally small value if variance < 0 
    log_likelihood = realmin;

else
    
    log_likelihood = model_env.pdf( ...
                     model_env.get_mu(   predictors, model_specs.coeffs(1,:)), ...
                     model_env.get_sigma(predictors, model_specs.coeffs(2,:)));

end

% -----------------------------------------







%{
HELPER FUNCTIONS
---------------------------------------------
Note, using OUT as the argout name for all of the helper functions limits
the scope of the outputs to each helper, and ensures that there will be
no interference between the helper outputs and other variables in the
stack.  DO NOT change output variable names.
%}


% Sets environment parameters according to specified model
    function out = set_model_environment
        
        switch lower(model_specs.family)
            
            case {'norm','normal'}

                out.pdf       = set_pdf('normal');
                out.get_mu    = @(x,b) x * b';
                out.inv_link  = @(g) sqrt(g);
                out.get_sigma = @(x,g) out.inv_link( x * g' + additional_var);


            case 't'

                out.pdf       = set_pdf('t');
                out.get_mu    = @(x,b) x * b';
                out.inv_link  = @(g,nu) sqrt( (g * (nu - 2) ) / nu);
                out.get_sigma = @(x,g) out.inv_link( (x * g') , model_specs.shape);


            case {'bino','binomial'}
                
                out.pdf = set_pdf('binomial');
                out.get_mu = [];
                out.inv_link = [];
                out.get_sigma = [];


            otherwise
                
                error(['Invalid model FAMILY specified - options are ' ...
                        '''normal'', ''t'', or ''binomial'''])
                
        end
        
    end



% ---------------------------------------------
% Return handle to the probability model
    function out = set_pdf(model_type)
        
        switch model_type
            
            case 'normal'
                
                cens_id = identity_fcn(outcome); %Censoring indicator
                
                out = @(mu_total, sigma_total) ...
                    nansum( [                                           ...
                                                                        ...
                    ( (cens_id.^2 - cens_id) / 2) .* ...
                    log( normcdf( (model_specs.censor(1) - mu_total) ./ sigma_total ) ); ...
                                                                        ...
                    (1 - cens_id.^2) .* ...
                    log( normpdf( (outcome - mu_total) ./ sigma_total ) ./sigma_total ); ...
                                                                        ...
                    ( (cens_id + cens_id.^2) / 2) .* ...
                    log( 1 - normcdf( (model_specs.censor(2) - mu_total) ./ sigma_total ) ) ...
                                                                        ...
                                ] );

                            
            case 't'
                
                cens_id = identity_fcn(outcome); %Censoring indicator
                
                out = @(mu_total, sigma_total) ...
                    nansum( [                                           ...
                                                                        ...
                    ( (cens_id.^2 - cens_id) / 2) .* ...
                    log( tcdf( (model_specs.censor(1) - mu_total) ./ sigma_total, model_specs.shape ) ); ...
                                                                        ...
                    (1 - cens_id.^2) .* ...
                    log( tpdf( (outcome - mu_total) ./ sigma_total, model_specs.shape ) ./sigma_total ); ...
                                                                        ...
                    ( (cens_id + cens_id.^2) / 2) .* ...
                    log( 1 - tcdf( (model_specs.censor(2) - mu_total) ./ sigma_total, model_specs.shape ) ) ...
                                                                        ...
                                ] );
                
                
            case 'binomial'
                
                error('BINOMIAL FAMILY DOES NOT WORK YET!')
                
                % out = @(b) [];
        end
        
    end


% ---------------------------------------------
% Compute the identity function - indicate censored data
    function out = identity_fcn(y)
        
        y_lowerlim = model_specs.censor(1);
        y_upperlim = model_specs.censor(2);
        
        out = zeros(size(y));
        
        out(y <= y_lowerlim) = -1;
        out(y >= y_upperlim) = 1;
        
    end



end

