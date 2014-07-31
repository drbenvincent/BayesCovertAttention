%% SCRIPTcuedYesNo
%
%%

function SCRIPTcuedYesNoHR(run_type)
% SCRIPTcuedYesNoHR('testing')
% SCRIPTcuedYesNoHR('publication')

%% Preliminaries
%clear,
close all; clc
set(0,'DefaultFigureWindowStyle','normal') % 'docked' or 'normal'

% add paths to dependencies
addpath([cd '/funcs'])
addpath([cd '/funcs/export_fig'])
addpath([cd '/funcs/latex_fig'])
addpath([cd '/funcs/hline_vline'])
plot_formatting_setup
addpath([cd '/funcs/ColorBand'])
% are we doing a quick run, or a proper long run?
%run_type = 'testing'; % ['testing'|'publication']
T1=clock;

%% Define parameters
% Select parameters to use based on if we are quick testing (faster
% computation times) or final runs (will take a while to compute).
N_testing_trials = 2000;
T_publication_trials = 5000;
switch run_type
    case{'testing'}
        % Experiment 1
		n=1;
        expt(n).TRIALS          = N_testing_trials; 
        expt(n).N               = 2; % FIXED
        expt(n).variance_list   = 1./[4 1 0.25];
        expt(n).cue_validity_list= linspace(0.1,0.9,5);
		expt(n).run_type		= run_type;
  
        % Experiment 2
		n=2;
        expt(n).TRIALS          = N_testing_trials; 
		expt(n).cue_validity    = 0.7; % FIXED
        expt(n).set_size_list   = [2 8];
        expt(n).variance_list   = [0.5:0.5:10];
		expt(n).run_type		= run_type;
		
		% Experiment 3
		n=3;
        expt(n).TRIALS          = N_testing_trials; 
		expt(n).cue_validity_list = [0.5 0.7]; 
        expt(n).set_size_list   = [2:1:9];
        expt(n).variance		= 1; % FIXED
		expt(n).run_type		= run_type;
    case{'publication'}
                % Experiment 1
		n=1;
        expt(n).TRIALS          = T_publication_trials; 
        expt(n).N               = 2; % FIXED
        expt(n).variance_list   = 1./[4 1 0.25];
        expt(n).cue_validity_list= linspace(0.1,0.9,5);
		expt(n).run_type		= run_type;
  
        % Experiment 2
		n=2;
        expt(n).TRIALS          = T_publication_trials; 
		expt(n).cue_validity    = 0.7; % FIXED
        expt(n).set_size_list   = [2 8];
        expt(n).variance_list   = [0.1:0.2:10];
		expt(n).run_type		= run_type;
		
		% Experiment 3
		n=3;
        expt(n).TRIALS          = T_publication_trials; 
		expt(n).cue_validity_list = [0.5 0.7]; 
        expt(n).set_size_list   = [2:1:9];
        expt(n).variance		= 1; % FIXED
		expt(n).run_type		= run_type;
end



%% SANITY CHECK

% First, make sure the model is actually doing something sensible. 





%% RUN EXPERIMENTS

EXPT1( expt(1) )
EXPT2( expt(2) )
EXPT3( expt(3) )






%% time
T2=clock;
min_sec(etime(T2,T1));
etime(T2,T1)/60 ;% time in mins

%% Export the figure

% Automatic resizing to make figure appropriate for font size
%latex_fig(11, 7, 4)

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
	figure(4), latex_fig(11, 8, 3), export_fig results_cued_yesno -png -pdf -m1
	figure(1), latex_fig(11, 8, 3), export_fig results_cued_yesnoEXPT1 -png -pdf -m1
	figure(2), latex_fig(11, 8, 3), export_fig results_cued_yesnoEXPT2 -png -pdf -m1
	figure(3), latex_fig(11, 8, 3), export_fig results_cued_yesnoEXPT3 -png -pdf -m1
	cd(codedir)
catch
	cd(codedir)
end

return





function EXPT1(expt)
%% EXPERIMENT 1

mcmcparams = define_mcmcparams(expt.run_type, expt.TRIALS);

jobcount = 1;
for v=1:numel(expt.variance_list)
    variance = expt.variance_list(v);
    for cv = 1:numel(expt.cue_validity_list)
        cue_validity = expt.cue_validity_list(cv);
        
        fprintf('job %d of %d: %s\n', jobcount,...
            numel(expt.variance_list)*numel(expt.cue_validity_list), datestr(now) )
        % run the main MCMC code with these parameters
        [AUC(cv,v), AUC_valid_present(cv,v), AUC_invalid_present(cv,v),...
			validHR(cv,v), invalidHR(cv,v)]=...
            MCMCcuedYesNo(mcmcparams, expt.N, variance, cue_validity, expt.TRIALS);
        jobcount = jobcount + 1;
    end
end

% plot output
ColorSet = ColorBand(numel(expt.variance_list)); % define line colours

figure(1), clf

subplot(1,2,1)
hold on, set(gca, 'ColorOrder', ColorSet);
plot( expt.cue_validity_list.*100 , validHR, '.-', 'LineWidth', 2, 'MarkerSize', 20)
%ylim([0.5 1])
xlabel('cue validity')
title('valid/present')

subplot(1,2,2)
hold on, set(gca, 'ColorOrder', ColorSet);
plot( expt.cue_validity_list.*100 , invalidHR, '.-', 'LineWidth', 2, 'MarkerSize', 20)
%ylim([0.5 1])
xlabel('cue validity')
title('invalid/present')

drawnow

figure(4), subplot(1,3,1)
hold on, set(gca, 'ColorOrder', ColorSet);
plot( expt.cue_validity_list.*100 , validHR-invalidHR, '.-', 'LineWidth', 2, 'MarkerSize', 20)
%ylim([0 1])
xlabel('cue validity')
ylabel('cuing effect')
title('fixed set size')

legend(num2str(expt.variance_list'))

drawnow

return





function EXPT2(expt)
%% EXPERIMENT 2

mcmcparams = define_mcmcparams(expt.run_type, expt.TRIALS);

jobcount = 1;
for v=1:numel(expt.variance_list)
    variance = expt.variance_list(v);
    for ss = 1:numel(expt.set_size_list)
        set_size = expt.set_size_list(ss);
        fprintf('job %d of %d: %s\n', jobcount,...
            numel(expt.variance_list)*numel(expt.set_size_list), datestr(now) )
        % run the main MCMC code with these parameters
        [AUC(ss,v), AUC_valid_present(ss,v), AUC_invalid_present(ss,v),...
			validHR(ss,v), invalidHR(ss,v)]=...
            MCMCcuedYesNo(mcmcparams, set_size, variance, expt.cue_validity, expt.TRIALS);
        jobcount = jobcount + 1;
    end
end

% plot output
ColorSet = ColorBand(numel(expt.set_size_list)); % define line colours

figure(2), clf

subplot(1,2,1)
hold on, set(gca, 'ColorOrder', ColorSet);
plot( expt.variance_list , validHR, '.-', 'LineWidth', 2, 'MarkerSize', 20)
%ylim([0.5 1])
xlabel('variance')
title('valid/present')

subplot(1,2,1)
hold on, set(gca, 'ColorOrder', ColorSet);
plot( expt.variance_list , invalidHR, '.-', 'LineWidth', 2, 'MarkerSize', 20)
%ylim([0.5 1])
xlabel('variance')
title('invalid/present')

drawnow

figure(4), subplot(1,3,2)
hold on, set(gca, 'ColorOrder', ColorSet);
dprime = 1./expt.variance_list
plot( expt.variance_list , validHR-invalidHR, '.-', 'LineWidth', 2, 'MarkerSize', 20)
%ylim([0 1])
xlabel('noise variance')
ylabel('cuing effect')
title('fixed cue validity')

legend(num2str(expt.set_size_list'))

drawnow

return













function EXPT3(expt)
%% EXPERIMENT 3

mcmcparams = define_mcmcparams(expt.run_type, expt.TRIALS);

jobcount = 1;
for ss=1:numel(expt.set_size_list)
    N = expt.set_size_list(ss);
    for cv = 1:numel(expt.cue_validity_list)
        cue_validity = expt.cue_validity_list(cv);
        
        fprintf('job %d of %d: %s\n', jobcount,...
            numel(expt.set_size_list)*numel(expt.cue_validity_list), datestr(now) )
        % run the main MCMC code with these parameters
        [AUC(cv,ss), AUC_valid_present(cv,ss), AUC_invalid_present(cv,ss),...
			validHR(cv,ss), invalidHR(cv,ss)]=...
            MCMCcuedYesNo(mcmcparams, N, expt.variance, cue_validity, expt.TRIALS);
        jobcount = jobcount + 1;
    end
end

% plot output
ColorSet = ColorBand(numel(expt.cue_validity_list)); % define line colours

figure(3), clf

subplot(1,2,1)
hold on, set(gca, 'ColorOrder', ColorSet);
plot( expt.set_size_list , validHR, '.-', 'LineWidth', 2, 'MarkerSize', 20)
%ylim([0.5 1])
xlabel('set size')
title('valid/present')

subplot(1,2,2)
hold on, set(gca, 'ColorOrder', ColorSet);
plot( expt.set_size_list , invalidHR, '.-', 'LineWidth', 2, 'MarkerSize', 20)
%ylim([0.5 1])
xlabel('set size')
title('invalid/present')
drawnow

figure(4), subplot(1,3,3)
hold on, set(gca, 'ColorOrder', ColorSet);
plot( expt.set_size_list , validHR-invalidHR, '.-', 'LineWidth', 2, 'MarkerSize', 20)
%ylim([0 1])
xlabel('set size')
ylabel('cuing effect')
title('variance fixed')

legend(num2str(expt.cue_validity_list'))

drawnow

return






