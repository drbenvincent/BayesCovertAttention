%% SCRIPTcuedYesNo
%
%%

%function SCRIPTcuedDetection(run_type)
%% Preliminaries
clear, %close all; clc
% add paths to dependencies
addpath([cd '/funcs'])
addpath([cd '/funcs/export_fig'])
addpath([cd '/funcs/latex_fig'])
addpath([cd '/funcs/hline_vline'])
plot_formatting_setup
addpath([cd '/funcs/ColorBand'])
% are we doing a quick run, or a proper long run?
run_type = 'testing'; % ['testing'|'publication']
T1=clock;

%% Define parameters
% Select parameters to use based on if we are quick testing (faster
% computation times) or final runs (will take a while to compute).

switch run_type
    case{'testing'}
        TRIALS				= 500; % number of trials to simulate it any one run
        cue_validity_list	= linspace(0.1,0.9,5);
        variance_list		= 1./[4  1  0.25];
        
    case{'publication'}
        TRIALS				= 50000; % number of trials to simulate it any one run
        cue_validity_list	= linspace(0.001,1-0.001,9);
        variance_list		= 1./[4  1  0.25];
end

mcmcparams = define_mcmcparams(run_type, TRIALS);

%% Run predictions for set size N=2
figure(1), clf
N = 2;
cuedYesNo_job(mcmcparams, N, TRIALS, cue_validity_list, variance_list, 1)

%% Run predictions for set size N=4
figure(2), clf
N = 4;
cuedYesNo_job(mcmcparams, N, TRIALS, cue_validity_list, variance_list, 2)


%% time
T2=clock;
min_sec(etime(T2,T1));	
etime(T2,T1)/60 ;% time in mins

%% Export the figure 

% Automatic resizing to make figure appropriate for font size
% Download from here http://www.mathworks.com/matlabcentral/fileexchange/36439-resizing-matlab-plots-for-publication-purposes-latex
latex_fig(11, 7, 4)


codedir=cd;
try
	switch run_type
		case{'testing'}
			cd('../plots/testing')
		case{'publication'}
			cd('../plots')
	end
	% save as a .fig file
	hgsave('results_cued_yesno')
	% save as .png and .pdf files
	export_fig results_cued_yesno -png -pdf -m1
	cd(codedir)
catch
	cd(codedir)
end









