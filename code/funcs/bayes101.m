% bayes101.m

addpath([cd '/funcs'])
addpath([cd '/funcs/export_fig'])
addpath([cd '/funcs/latex_fig'])
addpath([cd '/funcs/hline_vline'])
addpath([cd '/funcs/bens_helper_functions'])

%% Prep for plotting
plot_formatting_setup
rows = 2;
cols = 2;
close all
%figure(1), clf, colormap(gray)

%% Define parameters, priors etc
hypothesis_space=[0 1]; % possible values for W (display type)
prior = [0.5 0.5]; % prior over states of the world
sigma = 1; % standard deviation of observation noise



%% STEP 1: Forward generative step
% First we would decide the state of the world:
% if rand>prior(1), W=0, else, W=1, end
% but for this example we will go with W=1
W=1;
% Second we would sample from the likelihood:
% x = normrnd(W,sigma,1)
% but for this example we assume we observed a value of x=1.2
x=1.2;


%% STEP 2: Inference steps
likelihood = normpdf(x, hypothesis_space, sigma)
posterior = (likelihood.*prior) ./ sum(likelihood.*prior)











%% PLOTTING

% PRIOR -------------------------------------------------------------------
axis_prior = subplot(rows,cols,2);

bar(hypothesis_space,prior)
title('Prior','fontweight','bold')
xlabel('hypothesis space')
ylabel('P(W)')


% LIKELIHOOD --------------------------------------------------------------
sl=subplot(rows,cols,3);
hold on
X=linspace(-5,5.5,100);

xlim([0-4 0+4])
% distractor
d(1)=plot(X,normpdf(X,0,1));
a=get(gca,'XLim');
d(2)=plot([a(1) x x],[likelihood(1) likelihood(1) 0],'-');
set(d,'Color',[0.5 0.5 0.5])

% target
t(1)=plot(X,normpdf(X,1,1));
a=get(gca,'XLim');
t(2)=plot([a(1) x x],[likelihood(2) likelihood(2) 0],'-');
set(t,'Color','k')
xlabel('x')
ylabel('P(x|W)')
set(sl, 'YTick',[],...
    'XTick',-4:1:4)
title('Likelihood','fontweight','bold')
%a=get(gca,'YLim'); 
ylim([0 0.6])
legend([d(1),t(1)],...
	'P(x=1.2|W=0) = N(1.2;0,1)',...
	'P(x=1.2|W=1) = N(1.2;1,1)')
legend boxoff
xlabel('data space (x)')
set(gca,'PlotBoxAspectRatio',[1.5 1 1])


% POSTERIOR --------------------------------------------------------------- 
axis_posterior = subplot(rows,cols,4);
bar(hypothesis_space,posterior)
title('Posterior','fontweight','bold')
xlabel('hypothesis space')
ylabel('P(W|x=1.2)')


% Format axes for bar prior/posterior charts
set([axis_prior, axis_posterior],...
	'XTickLabel',{'W=0','W=1'},...
    'YTick', [0:0.25:1],...
	'box', 'off',...
	'XLim', [-0.5 1.5],...
	'YLim', [0 1],...
	'PlotBoxAspectRatio',[1.5 1 1])


% Export the figure -------------------------------------------------------
latex_fig(14, 7,6)

% codedir=cd;
% cd('/Users/benvincent/Desktop')
% hgsave('bayes101')
% export_fig bayes101 -pdf -m1
% cd(codedir)
