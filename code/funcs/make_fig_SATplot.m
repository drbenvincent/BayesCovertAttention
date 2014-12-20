% make_fig_SATplot


close all; clc
% add paths to dependencies
addpath([cd '/funcs'])
addpath([cd '/funcs/export_fig'])
addpath([cd '/funcs/latex_fig'])
%addpath([cd '/funcs/ColorBand'])
%addpath([cd '/funcs/hline_vline'])
%addpath([cd '/funcs/bordertext'])
addpath([cd '/funcs/bens_helper_functions'])
%addpath([cd '/funcs/legendflex'])
plot_formatting_setup

%%

clf

delay = 0.5;
t = linspace(0,2,100);

% cumulative gamma function http://en.wikipedia.org/wiki/Gamma_distribution
SAT = @(t) 0.5 + gamcdf(((t*10)-delay),7,1) * 0.45;

plot(t,SAT(t),'k-')
axis tight
ylim([0.5 1])
set(gca,'YTick',[0.5:0.1:1],...
	'XTick',[0:0.25:2])
xlabel('response time (s)')
ylabel('performance')

hold on
t=1.75; plot([0 t t],[SAT(t) SAT(t) 0],'k-','LineWidth',1)
t=1.3; plot([0 t t],[SAT(t) SAT(t) 0],'k-','LineWidth',1)
box off


%% Export the figure 
latex_fig(20, 7,4)

codedir=cd;
cd('/Users/benvincent/Desktop')
hgsave('fig_SATplot')
export_fig fig_SATplot -png -pdf -m1
cd(codedir)