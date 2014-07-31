%% SCRIPTLocalisation
% This script calculates the predictions for N-AFC localisation.
% All of these experimental results are a by-product of conducting inference
% about the state of the world (display type, $L$) given noisy sensory
% observations $x$, and knowledge of the causal structure of the detection
% task (see graphical model below) and the internal observation uncertainty
% associated with targets ($\sigma^2_T$) and distractors ($\sigma^2_D$).
%
% <<BGMLocalisation.png>>
%
%%

function SCRIPTLocalisation(run_type)
% SCRIPTLocalisation('testing')
%

%% Preliminaries
close all; clc
% add paths to dependencies
addpath([cd '/funcs'])
addpath([cd '/funcs/export_fig'])
addpath([cd '/funcs/latex_fig'])
addpath([cd '/funcs/hline_vline'])
addpath([cd '/funcs/ColorBand'])
plot_formatting_setup
% are we doing a quick run, or a proper long run?
%run_type = 'testing'; % ['testing'|'publication']
T1=clock;

%% Define parameters
% Select parameters to use based on if we are quick testing (faster
% computation times) or final runs (will take a while to compute).

switch run_type
	case{'testing'}
		TRIALS				= 100; % number of trials to simulate it any one run
		sp_list             = linspace(0,1,5);
		variance_list		= 1./[4  1  0.25];
		
	case{'publication'}
		TRIALS				= 50000; % number of trials to simulate it any one run
		sp_list	= linspace(0,1,9);
		variance_list		= 1./[4  1  0.25];
end

mcmcparams = define_mcmcparams(run_type, TRIALS);

%% Run predictions for set size N=2
N = 2;
localisation_job(mcmcparams, N, TRIALS, sp_list, variance_list, 1)

%% Run predictions for set size N=4
N = 4;
localisation_job(mcmcparams, N, TRIALS, sp_list, variance_list, 2)


%% time
T2=clock;
min_sec(etime(T2,T1));
etime(T2,T1)/60 ;% time in mins

%% Export the figure

latex_fig(11, 7, 4)

codedir=cd;
switch run_type
	case{'testing'}
		cd('../plots/testing')
	case{'publication'}
		cd('../plots')
end

% save as a .fig file
hgsave('results_localisation')

% save as a .pdf and png file
export_fig results_localisation -png -pdf -m1

cd(codedir)

end




%% Sub-function: predictions for a given set size, |N|

function localisation_job(mcmcparams, N, TRIALS, sp_list, variance_list, subfig)

dprime				= 1./variance_list;

%%
% Loop over a range of cue validities and $d'$ values and compute the
% proportion correct (|PC|) with the function |MCMClocalisation.m|.
jobcount = 1;
for v=1:numel(variance_list)
	variance = variance_list(v);
	
	for s = 1:numel(sp_list)
		sp = sp_list(s);
		
		fprintf('job %d of %d: %s\n', jobcount,...
			numel(variance_list)*numel(sp_list), datestr(now) )
		
		% create the spatial prior distribution
		spdist = [sp , ones(1,N-1).*(1-sp)./(N-1)];
		% run the main MCMClocalisation code with these parameters
		PC(s,v) = MCMClocalisation(mcmcparams,N, spdist, variance, TRIALS);
		
		jobcount = jobcount + 1;
	end
end

%%
% Plot the results

figure(1)

ColorSet = ColorBand(numel(variance_list)); % define line colours

subplot(1,2,subfig)
hold all
set(gca, 'ColorOrder', ColorSet);
plot( sp_list.*100 , PC, '.-',...
	'LineWidth', 10,...
	'MarkerSize', 50)
hline(1/N)

% formatting
set(gca,'PlotBoxAspectRatio',[1 1 1],...
	'box', 'off',...
	'xlim', [0 100],...
	'ylim', [0 1],...
	'XTick',[0:25:100],...
	'YTick',[0:0.25:1])
xlabel('expectation (%)')
ylabel('proportion correct')
title(['set size = ' num2str(N)],'FontSize',16)
% legend
h = legend(num2str(dprime'),...
	'location','SouthEast');
legend boxoff
% v = get(h,'title');
% set(v,'string','\sigma^2');

axis square

drawnow


end





