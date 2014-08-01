%% SCRIPTdetection
% This script calculates the predictions for a number of attentional
% effects for the yes/no detection task.
% All of these experimental results are a by-product of conducting inference
% about the state of the world (display type, $L$) given noisy sensory
% observations $x$, and knowledge of the causal structure of the detection
% task (see graphical model below) and the internal observation uncertainty
% associated with targets ($\sigma^2_T$) and distractors ($\sigma^2_D$).
%
% <<BGMdetection.png>>
%
%%


function SCRIPTyesno(run_type)
% SCRIPTyesno('testing')

%% Preliminaries
close all; clc
% add paths to dependencies
addpath([cd '/funcs'])
addpath([cd '/funcs/export_fig'])
addpath([cd '/funcs/latex_fig'])
addpath([cd '/funcs/ColorBand'])
plot_formatting_setup
% are we doing a quick run, or a proper long run?
% run_type = 'testing'; % ['testing'|'publication']
T1=clock;

%% Define parameters
% Select parameters to use based on if we are quick testing (faster
% computation times) or final runs (will take a while to compute).

switch run_type
    case{'testing'}
        TRIALS              = 100;
        list_of_variances   = 1./[4 1 0.25];
        dprime              = 1./list_of_variances;
        size_sizes          = [2 4 8];
        external_noise_variance_list = [0.5 1 2 4 8];
    case{'publication'}
        TRIALS              = 5000;
        %list_of_variances   = 1./[8 4 2 1 0.5 0.25 0.125];
		list_of_variances   = 1./[4 1 0.25];
        dprime              = 1./list_of_variances;
        size_sizes          = [2 4 8 16];
        external_noise_variance_list = [0.5 1 2 4 8];
end





%% EXPERIMENT 1
% Calculate ROC curves over a range of different internal noise levels
N = 2;
for n=1:numel(list_of_variances)
	% Grab the parameter value we are looking at
	variance				= list_of_variances(n);
	% Run the main MCMCyesno code given these parameter values
	fprintf('job %d of %d: %s\n', n, numel(list_of_variances), datestr(now) )
	[~, FAR(:,n), HR(:,n)]	= MCMCyesno(mcmcparams, N, variance,variance);
end

%%
% Plot the results

ColorSet = ColorBand(numel(list_of_variances)); % define line colours

figure(1)
subplot(1,3,1)
hold all 
set(gca, 'ColorOrder', ColorSet); 
plot(FAR,HR)
format_axis_ROC
legend('4, 1', '1, 4')
legend(num2str(dprime'),...
	'location','SouthEast')
legend boxoff
title('Target/Distracter similarity','FontSize',16)






%% EXPERIMENT 2
% Calculate AUC for a range of set sizes and internal noise levels

%%
% preallocate matrix for AUC values
AUC=zeros(numel(size_sizes),numel(list_of_variances));
%%
% loop over the parameters, and run the MCMC detection code
job =1;
jobs = numel(size_sizes) * numel(list_of_variances);
for s=1:numel(size_sizes)
	for v=1:numel(list_of_variances)
        fprintf('job %d of %d: %s\n', job, jobs, datestr(now) )
		% pull out the parameters we are dealing with now
		N					= size_sizes(s);
		variance			= list_of_variances(v);
		[AUC(s,v), ~, ~]	= MCMCyesno(mcmcparams, N, variance, variance);
        job=job+1;
	end
end

%%
% Plot the results
figure(1)
subplot(1,3,2)
hold all 
set(gca, 'ColorOrder', ColorSet); 
plot(size_sizes,AUC,'.-',...
    'MarkerSize', 30)
axis square

title('Set size effects','FontSize',16)
xlabel('set size')
ylabel('AUC')

axis([1 max(size_sizes) 0.5 1])
set(gca,'XTick',size_sizes)

legend(num2str(dprime'),...
	'location','NorthEast')
legend boxoff







%% EXPERIMENT 3
% Search asymmetry

N=4;
% Define variance of item A and B
varA = 4;
varB = 1;

%%
% Search for A amongst B
varTarget       = varA; 
varDistracter   = varB;
[AB_AUC, AB_FAR, AB_HR] = MCMCyesno(mcmcparams, N, varTarget, varDistracter);

%%
% Search for B amongst A
varTarget       = varB; 
varDistracter   = varA;
[BA_AUC, BA_FAR, BA_HR] = MCMCyesno(mcmcparams, N, varTarget, varDistracter);

%%
% Plot the results
figure(1)
subplot(1,3,3)
title('Search asymmetry','FontSize',16)
plot(AB_FAR,AB_HR,'k')
hold on
plot(BA_FAR,BA_HR,'k:')
format_axis_ROC
legend('\sigma^2_T = 4, \sigma^2_D = 1',...
    '\sigma^2_T = 1, \sigma^2_D = 4',...
    'location','SouthEast')
legend boxoff





%% report time taken doing job
T2=clock;
min_sec(etime(T2,T1));




%% Export the figure 

% Automatic resizing to make figure appropriate for font size
latex_fig(11, 7, 4)

% save as a .fig file
codedir=cd;
switch run_type
	case{'testing'}
		cd('../plots/testing')
	case{'publication'}
		cd('../plots')
end

% save as a .fig file
hgsave('results_detection')

% save as a .pdf and png file
export_fig results_detection -png -pdf -m1

cd(codedir)

return
