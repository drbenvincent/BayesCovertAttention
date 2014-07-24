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

%function SCRIPTLocalisation(run_type)
%% Preliminaries
clear, close all; clc
% add paths to dependencies
addpath([cd '/funcs'])
addpath([cd '/funcs/export_fig'])
addpath([cd '/funcs/latex_fig'])
addpath([cd '/funcs/hline_vline'])
addpath([cd '/funcs/ColorBand'])
plot_formatting_setup
% are we doing a quick run, or a proper long run?
run_type = 'testing'; % ['testing'|'publication']
T1=clock;

%% Define parameters
% Select parameters to use based on if we are quick testing (faster
% computation times) or final runs (will take a while to compute).

switch run_type
	case{'testing'}
		TRIALS				= 500; % number of trials to simulate it any one run
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

% save as a .fig file
codedir=cd;
switch run_type
	case{'testing'}
		cd('../plots/testing')
	case{'publication'}
		cd('../plots')
end
hgsave('results_localisation')
cd(codedir)

% % set figure size/location on screen
% set(gcf,'Units','pixels',...
%     'OuterPosition',[0 0 1024 500])

%%
% If you download <http://www.mathworks.co.uk/matlabcentral/fileexchange/23629-exportfig export_fig.m>
% from Mathworks File Exchange, then the following command can be used for 
% publication quality figure export:
figure(1)
% Automatic resizing to make figure appropriate for font size
% Download from here http://www.mathworks.com/matlabcentral/fileexchange/36439-resizing-matlab-plots-for-publication-purposes-latex
latex_fig(11, 7, 4)

switch run_type
	case{'testing'}
		cd('../plots/testing')
	case{'publication'}
		cd('../plots')
end
export_fig results_localisation -png -pdf -m1
cd(codedir)

%return










