%% SCRIPTcuedYesNo
%
%%

function SCRIPTcuedYesNo(opts)
% SCRIPTcuedYesNo(100, 'testing')
% SCRIPTcuedYesNo(50000, 'publication')

%% Preliminaries
%clear,
%close all;
figure(4), clf
clc
set(0,'DefaultFigureWindowStyle','normal') % 'docked' or 'normal'

% add paths to dependencies
addpath([cd '/funcs'])
addpath([cd '/funcs/export_fig'])
addpath([cd '/funcs/latex_fig'])
addpath([cd '/funcs/hline_vline'])
plot_formatting_setup
addpath([cd '/funcs/ColorBand'])
%addpath([cd '/funcs/bordertext'])
addpath([cd '/funcs/bens_helper_functions'])
% are we doing a quick run, or a proper long run?
%run_type = 'testing'; % ['testing'|'publication']
T1=clock;

%% Define parameters

% Experiment 1
n=1;
expt(n).TRIALS          = opts.trials;
expt(n).set_size_list	= 2; % FIXED, single value
expt(n).dp_list			= [1 2];
expt(n).variance_list	= (1./expt(n).dp_list).^2;
%expt(n).variance_list   = 1./[4 1 0.25];
%expt(n).dp_list			= 1./sqrt(expt(n).variance_list);
expt(n).cue_validity_list= linspace(0.1,0.9,9);
%expt(n).run_type		= run_type;

% Experiment 2
n=2;
expt(n).TRIALS          = opts.trials;
expt(n).cue_validity_list    = 0.7; % FIXED, single value
expt(n).set_size_list   = [2 6];
expt(n).dp_list			= linspace(0.1,5,10);
expt(n).variance_list	= (1./expt(n).dp_list).^2;
%expt(n).variance_list   = [0.0625 0.125 0.25 0.5 1 2 4 8];
%expt(n).dp_list			= 1./sqrt(expt(n).variance_list);
%expt(n).run_type		= run_type;

% Experiment 3
n=3;
expt(n).TRIALS          = opts.trials;
expt(n).cue_validity_list = [0.5 0.7];
expt(n).set_size_list   = [2:1:9];
expt(n).variance_list	= 1; % FIXED, single value
expt(n).dp_list			= 1./sqrt(expt(n).variance_list);
%expt(n).run_type		= run_type;






%% RUN EXPERIMENTS

expt(1).results = EXPT1( expt(1) , opts);
expt(2).results = EXPT2( expt(2) , opts);
expt(3).results = EXPT3( expt(3) , opts);






%% time
T2=clock;
min_sec(etime(T2,T1));
etime(T2,T1)/60 ;% time in mins

% %% Save the output
% codedir=cd;
% cd('../output')
% fname=sprintf('cuedYesNo');
% save(fname,'expt')
% display('results saved')
% cd(codedir)

%% Export the figure

% Automatic resizing to make figure appropriate for font size
%latex_fig(11, 7, 4)

codedir=cd;
switch opts.evalMethod
	case{'MCMC'}
		cd('../plots/MCMC')
	case{'nonMCMC'}
		cd('../plots/nonMCMC')
end

% save as figures
figure(4), latex_fig(10, 8, 2)
export_fig results_cued_yesno -png -pdf -m1
hgsave('results_cued_yesno')

figure(1), latex_fig(10, 8, 2)
export_fig results_cued_yesnoEXPT1 -png -pdf -m1
hgsave('results_cued_yesnoEXPT1')

figure(2), latex_fig(10, 8, 2)
export_fig results_cued_yesnoEXPT2 -png -pdf -m1
hgsave('results_cued_yesnoEXPT2')

figure(3), latex_fig(10, 8, 2)
export_fig results_cued_yesnoEXPT3 -png -pdf -m1
hgsave('results_cued_yesnoEXPT3')

cd(codedir)

end





function results = EXPT1(expt, opts)
%% EXPERIMENT 1

results = doParameterSweep(expt, opts);

figure(1), clf
plotExperimentResults(expt, results, 'cue_validity_list', 'cue validity')

figure(4), subplot(1,3,1)
hold on,% set(gca, 'ColorOrder', ColorSet);
plot( expt.cue_validity_list.*100 ,...
	results.validHR-results.invalidHR,...
	'.-', 'LineWidth', 2, 'MarkerSize', 20)
%ylim([0 1])
xlabel('cue validity')
ylabel('cuing effect (HR_{valid}-HR_{invalid})')

% text for fixed parameter
fixed = sprintf('N = %d', expt.set_size_list);
%bordertext('topleft', fixed);
add_text_to_figure('TL',fixed, 15)

legend(num2str(expt.variance_list'))
legend('Location','NorthEast')

drawnow

end

function results = EXPT2(expt, opts)
%% EXPERIMENT 2

results = doParameterSweep(expt, opts);

figure(2), clf
%plotExperimentResults(expt, results, 'variance_list', '\sigma ^2')
plotExperimentResults(expt, results, 'dp_list', 'd''')

figure(4), subplot(1,3,2)
hold on, %set(gca, 'ColorOrder', ColorSet);

plot( expt.dp_list , results.validHR-results.invalidHR,...
	'.-', 'LineWidth', 2, 'MarkerSize', 20)
%ylim([0 1])
xlabel('noise variance')
ylabel('cuing effect (HR_{valid}-HR_{invalid})')

% text for fixed parameter
fixed = sprintf('v = %1.1f', expt.cue_validity_list)
add_text_to_figure('TL',fixed, 15)

legend(num2str(expt.set_size_list'))
legend('Location','NorthEast')

drawnow

end

function results = EXPT3(expt, opts)
%% EXPERIMENT 3

results = doParameterSweep(expt, opts);

figure(3), clf
plotExperimentResults(expt, results, 'set_size_list', 'N')

figure(4), subplot(1,3,3)
hold on, %set(gca, 'ColorOrder', ColorSet);
plot( expt.set_size_list , results.validHR-results.invalidHR,...
	'.-', 'LineWidth', 2, 'MarkerSize', 20)
%ylim([0 1])
xlabel('set size')
ylabel('cuing effect (HR_{valid}-HR_{invalid})')

% text for fixed parameter
fixed = sprintf('variance = %1.1f', expt.variance_list);
add_text_to_figure('TL',fixed, 15)

legend(num2str(expt.cue_validity_list'))
legend('Location','NorthEast')

drawnow

end


function results=doParameterSweep(expt, opts)

tic

jobCount	= 1;
nJobs		= numel(expt.variance_list)*...
	numel(expt.cue_validity_list)*...
	numel(expt.set_size_list);
% start parameter sweep
for n=1:numel(expt.set_size_list)
	N = expt.set_size_list(n);
	
	for v=1:numel(expt.variance_list)
		variance = expt.variance_list(v);
		
		for cv = 1:numel(expt.cue_validity_list)
			cue_validity = expt.cue_validity_list(cv);
			
			fprintf('job %d of %d: \n', jobCount, nJobs)
			
			switch opts.evalMethod
				case{'MCMC'}
					[invalidHR(n,cv,v), validHR(n,cv,v)]	= ...
						evaluateCuedYesNoMCMC(opts, N, variance,cue_validity);
				case{'nonMCMC'}
					sigmaT=sqrt(variance);
					sigmaD=sqrt(variance);
					[~, ~, ~, ~, validHR(n,cv,v), invalidHR(n,cv,v)] = ...
						evaluateCuedYesNo(opts, N, sigmaT, sigmaD, cue_validity);
			end
			
			jobCount = jobCount + 1;
		end
	end
end

% return results
% results.AUC					= squeeze(AUC);
% results.AUC_valid_present	= squeeze(AUC_valid_present);
% results.AUC_invalid_present = squeeze(AUC_invalid_present);
results.validHR				= squeeze(validHR);
results.invalidHR			= squeeze(invalidHR);

min_sec(toc);
end


function plotExperimentResults(expt, results, xVariable, xlabeltext)
%
% = getfield(expt, xVariable);
x = expt.(xVariable); % <-- use of dynamic field name

% % plot output for AUC ~~~~~~~~~~~~~~~~~~~
% subplot(2,3,1)
% plotStuff(x, results.AUC_valid_present, xlabeltext, 'AUC', 'valid')
%
% subplot(2,3,2)
% plotStuff(x, results.AUC_invalid_present, xlabeltext, 'AUC', 'invalid')
%
% subplot(2,3,3)
% plotStuff(x, results.AUC_valid_present - results.AUC_invalid_present,...
% 	xlabeltext, 'AUC', 'cueing benefit')

% plot output for hit rates ~~~~~~~~~~~~~~~~~~~
subplot(1,3,1)
plotStuff(x, results.validHR, xlabeltext, 'HR', 'valid-cue trials')

subplot(1,3,2)
plotStuff(x, results.invalidHR, xlabeltext, 'HR', 'invalid-cue trials')

subplot(1,3,3)
plotStuff(x, results.validHR-results.invalidHR,...
	xlabeltext, 'cuing effect (HR_{valid}-HR_{invalid})', '')

drawnow

	function plotStuff(x, y, xlabeltext, ylabeltext, titleText)
		hold all, %set(gca, 'ColorOrder', ColorSet);
		plot( x , y, '.-',...
			'LineWidth', 2, 'MarkerSize', 20)
		xlabel(xlabeltext), ylabel(ylabeltext)
		title(titleText)
		axis square
		
% 		% append info
% 		dt = datestr(now,'yyyy mmm dd, HH:MM AM');
% 		bordertext('figurebottomright', [mfilename ' ' dt]);
	end

end

