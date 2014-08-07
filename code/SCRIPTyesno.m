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


function SCRIPTyesno(opts)
% SCRIPTyesno('testing')

% opts.evalMethod	= 'MCMC';		opts.run_type='testing';
% %opts.evalMethod		= 'nonMCMC';
% opts.trials			= 100;

%% Preliminaries
close all; clc
% add paths to dependencies
addpath([cd '/funcs'])
addpath([cd '/funcs/export_fig'])
addpath([cd '/funcs/latex_fig'])
addpath([cd '/funcs/ColorBand'])
addpath([cd '/funcs/hline_vline'])
%addpath([cd '/funcs/bordertext'])
addpath([cd '/funcs/bens_helper_functions'])
plot_formatting_setup
% are we doing a quick run, or a proper long run?
% run_type = 'testing'; % ['testing'|'publication']


%%
T1=clock;

experiment1(opts)
experiment2(opts)
experiment3(opts)

% report time taken doing job
T2=clock;
min_sec(etime(T2,T1));


%% Export the figure
display('Saving')

% Automatic resizing to make figure appropriate for font size
latex_fig(11, 7, 4)

% save as a .fig file
codedir=cd;
switch opts.evalMethod
	case{'MCMC'}
		cd('../plots/MCMC')
	case{'nonMCMC'}
		cd('../plots/nonMCMC')
end

% save as a .fig file
hgsave('results_detection')

% save as a .pdf and png file
export_fig results_detection -png -pdf -m1

cd(codedir)

return








function experiment1(opts)
%% EXPERIMENT 1
display('Experiment 1')
% Calculate ROC curves over a range of different internal noise levels
N				= 2;
variance_list	= [0.25 1 4];
sigma_list		= sqrt(variance_list);
dprime_list		= 1./(sqrt(variance_list));
prev=0.5;
for n=1:numel(variance_list)
	
	fprintf('job %d of %d: %s\n', n, numel(variance_list), datestr(now) )
	
	variance				= variance_list(n);
	
	switch opts.evalMethod
		case{'MCMC'}
			[~, FAR(:,n), HR(:,n)]	= evaluateYesNoMCMC(opts, N, variance,variance);
		case{'nonMCMC'}
			[PC(n), HR(:,n), FAR(:,n), AUC(n)] = ...
				evaluateYesNo(opts, N, variance, variance, prev);
	end
end

%
% Plot the results

ColorSet = ColorBand(numel(variance_list)); % define line colours

figure(1)
subplot(1,3,1)
hold all
set(gca, 'ColorOrder', ColorSet);
plot(FAR,HR)
format_axis_ROC
legend('4, 1', '1, 4')
legend(num2str(dprime_list'),...
	'location','SouthEast')
legend boxoff
title('Target/Distracter similarity','FontSize',16)
return




function experiment2(opts)
%% EXPERIMENT 2
display('Experiment 2')
% Calculate AUC for a range of set sizes and internal noise levels

size_sizes		= [2 4 8 16];
variance_list	= [0.25 1 4];
sigma_list		= sqrt(variance_list);
dprime_list		= 1./(sqrt(variance_list));
prev=0.5;

%%
% preallocate matrix for AUC values
AUC=zeros(numel(size_sizes),numel(variance_list));
%%
% loop over the parameters, and run the MCMC detection code
job =1;
jobs = numel(size_sizes) * numel(variance_list);
for s=1:numel(size_sizes)
	for v=1:numel(variance_list)
		fprintf('job %d of %d: %s\n', job, jobs, datestr(now) )
		% pull out the parameters we are dealing with now
		N					= size_sizes(s);
		variance			= variance_list(v);
		%[AUC(s,v), ~, ~]	= evaluateYesNoMCMC(mcmcparams, N, variance, variance);
		
		switch opts.evalMethod
			case{'MCMC'}
				
				[AUC(s,v), ~, ~]	= evaluateYesNoMCMC(opts, N, variance,variance);
				
			case{'nonMCMC'}
				
				[~, ~, ~, AUC(s,v)] = ...
					evaluateYesNo(opts, N, variance, variance, prev);
				
		end
		job=job+1;
	end
end
%%
% Plot the results

ColorSet = ColorBand(numel(variance_list)); % define line colours
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

legend(num2str(dprime_list'),...
	'location','NorthEast')
legend boxoff
return





function experiment3(opts)
%% EXPERIMENT 3
display('Experiment 3')
% Search asymmetry

N=2;
prev=0.5;
% Define variance of item A and B
varA = 4;
varB = 1;

%%

% Search for A amongst B
varTarget       = varA;
varDistracter   = varB;
switch opts.evalMethod
	case{'MCMC'}
		[~, AB_FAR, AB_HR]	= evaluateYesNoMCMC(opts, N, varTarget,varDistracter);
	case{'nonMCMC'}
		[~, AB_HR, AB_FAR, ~] = ...
			evaluateYesNo(opts, N, varTarget, varDistracter, prev);
end

%%
% Search for B amongst A
varTarget       = varB;
varDistracter   = varA;
switch opts.evalMethod
	case{'MCMC'}
		[~, BA_FAR, BA_HR]	= evaluateYesNoMCMC(opts, N, varTarget, varDistracter);
	case{'nonMCMC'}
		[~, BA_HR, BA_FAR, ~] = ...
			evaluateYesNo(opts, N, varTarget, varDistracter, prev);
end

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
return

