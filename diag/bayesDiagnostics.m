function bayesDiagnostics(blm)
%BAYESDIAGNOSTICS Plot diagnostics for MCMC chain.
%   BAYESDIAGNOSTICS(BLM) creates a plot of various diagnostic
%   visualizations for MCMC chain in BLM Bayes linear model object.
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


f = figure('Color','w');


subplot(1,2,1)

blm.plot()
box off
try prettifyPlot(gcf); end

title('MCMC chain')
xlabel('iteration')
ylabel('\theta_i')



subplot(1,2,2)
title('autocorrelation / ESS')

hold on
for i=1:size(blm.coeffs,2)
    plot(autocorr(blm.coeffs(:,i),1:500))
    labs{i} = sprintf('ESS = %0.0f',ess(blm.coeffs(:,i)));
end

line(xlim, [0.05 0.05],'Color','k','LineStyle','--')
xlabel('lag')
ylabel('autocorrelation')

l = legend(labs);
set(l,'Box','off')
try prettifyPlot(gcf); end
