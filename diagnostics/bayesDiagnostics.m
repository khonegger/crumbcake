function bayesDiagnostics(data_in)

f = figure('Color','w');


subplot(2,2,1)

plot(data_in)
box off

title('MCMC chain')
xlabel('iteration')
ylabel('\theta_i')



subplot(2,2,2)
title('autocorrelation / ESS')

hold on
for i=1:size(data_in,2)
    plot(autocorr(data_in(:,i),1:500))
    labs{i} = sprintf('ESS = %0.0f',ess(data_in(:,i)));
end

line(xlim, [0.05 0.05],'Color','k','LineStyle','--')
xlabel('lag')
ylabel('autocorrelation')

l = legend(labs);
set(l,'Box','off')

