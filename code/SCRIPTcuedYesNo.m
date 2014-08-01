%% SCRIPTcuedYesNo
%
%%

function SCRIPTcuedYesNo(run_type)
% SCRIPTcuedYesNo('testing')
% SCRIPTcuedYesNo('publication')

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
addpath([cd '/funcs/bordertext'])
% are we doing a quick run, or a proper long run?
%run_type = 'testing'; % ['testing'|'publication']
T1=clock;

%% Define parameters
% Select parameters to use based on if we are quick testing (faster
% computation times) or final runs (will take a while to compute).
N_testing_trials		= 1000;
T_publication_trials	= 2000;
switch run_type
	case{'testing'}
		% Experiment 1
		n=1;
		expt(n).TRIALS          = N_testing_trials;
		expt(n).set_size_list	= 2; % FIXED, single value
		expt(n).dp_list			= [1 2];
		expt(n).variance_list	= (1./expt(n).dp_list).^2;
		%expt(n).variance_list   = 1./[4 1 0.25];
		%expt(n).dp_list			= 1./sqrt(expt(n).variance_list);
		expt(n).cue_validity_list= linspace(0.1,0.9,9);
		expt(n).run_type		= run_type;
		
		% Experiment 2
		n=2;
		expt(n).TRIALS          = N_testing_trials;
		expt(n).cue_validity_list    = 0.7; % FIXED, single value
		expt(n).set_size_list   = [2 6];
		expt(n).dp_list			= linspace(0.1,5,20);
		expt(n).variance_list	= (1./expt(n).dp_list).^2;
		%expt(n).variance_list   = [0.0625 0.125 0.25 0.5 1 2 4 8];
		%expt(n).dp_list			= 1./sqrt(expt(n).variance_list);
		expt(n).run_type		= run_type;
		
		% Experiment 3
		n=3;
		expt(n).TRIALS          = N_testing_trials;
		expt(n).cue_validity_list = [0.5 0.7];
		expt(n).set_size_list   = [2:1:9];
		expt(n).variance_list	= 1; % FIXED, single value
		expt(n).dp_list			= 1./sqrt(expt(n).variance_list);
		expt(n).run_type		= run_type;
	case{'publication'}
		%                 % Experiment 1
		% 		n=1;
		%         expt(n).TRIALS          = T_publication_trials;
		%         expt(n).N               = 2; % FIXED
		%         expt(n).variance_list   = 1./[4 1 0.25];
		%         expt(n).cue_validity_list= linspace(0.1,0.9,5);
		% 		expt(n).run_type		= run_type;
		%
		%         % Experiment 2
		% 		n=2;
		%         expt(n).TRIALS          = T_publication_trials;
		% 		expt(n).cue_validity    = 0.7; % FIXED
		%         expt(n).set_size_list   = [2 8];
		%         expt(n).variance_list   = [0.1:0.2:10];
		% 		expt(n).run_type		= run_type;
		%
		% 		% Experiment 3
		% 		n=3;
		%         expt(n).TRIALS          = T_publication_trials;
		% 		expt(n).cue_validity_list = [0.5 0.7];
		%         expt(n).set_size_list   = [2:1:9];
		%         expt(n).variance		= 1; % FIXED
		% 		expt(n).run_type		= run_type;
end





%% RUN EXPERIMENTS

expt(1).results = EXPT1( expt(1) );
expt(2).results = EXPT2( expt(2) );
expt(3).results = EXPT3( expt(3) );






%% time
T2=clock;
min_sec(etime(T2,T1));
etime(T2,T1)/60 ;% time in mins

%% Save the output
codedir=cd;
cd('../output')
fname=sprintf('cuedYesNo');
save(fname,'expt')
display('results saved')
cd(codedir)

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
	figure(4), latex_fig(10, 8, 3), export_fig results_cued_yesno -png  -m1
	figure(1), latex_fig(10, 8, 4), export_fig results_cued_yesnoEXPT1 -png -m1
	figure(2), latex_fig(10, 8, 4), export_fig results_cued_yesnoEXPT2 -png -m1
	figure(3), latex_fig(10, 8, 4), export_fig results_cued_yesnoEXPT3 -png -m1
	cd(codedir)
catch
	cd(codedir)
end

end





function results = EXPT1(expt)
%% EXPERIMENT 1

results = doParameterSweep(expt);

figure(1), clf
plotExperimentResults(expt, results, 'cue_validity_list', 'cue validity')

figure(4), subplot(1,3,1)
hold on,% set(gca, 'ColorOrder', ColorSet);
plot( expt.cue_validity_list.*100 ,...
	results.validHR-results.invalidHR,...
	'.-', 'LineWidth', 2, 'MarkerSize', 20)
%ylim([0 1])
xlabel('cue validity')
ylabel('cuing effect')

% text for fixed parameter
fixed = sprintf('N = %d', expt.set_size_list);
bordertext('topleft', fixed);

legend(num2str(expt.variance_list'))
legend('Location','NorthEast')

drawnow

end

function results = EXPT2(expt)
%% EXPERIMENT 2

results = doParameterSweep(expt);

figure(2), clf
%plotExperimentResults(expt, results, 'variance_list', '\sigma ^2')
plotExperimentResults(expt, results, 'dp_list', 'd''')

figure(4), subplot(1,3,2)
hold on, %set(gca, 'ColorOrder', ColorSet);

plot( expt.dp_list , results.validHR-results.invalidHR,...
	'.-', 'LineWidth', 2, 'MarkerSize', 20)
%ylim([0 1])
xlabel('noise variance')
ylabel('cuing effect')

% text for fixed parameter
fixed = sprintf('v = %d', expt.cue_validity_list);
bordertext('topleft', fixed);

legend(num2str(expt.set_size_list'))
legend('Location','NorthEast')

drawnow

end

function results = EXPT3(expt)
%% EXPERIMENT 3

results = doParameterSweep(expt);

figure(3), clf
plotExperimentResults(expt, results, 'set_size_list', 'N')

figure(4), subplot(1,3,3)
hold on, %set(gca, 'ColorOrder', ColorSet);
plot( expt.set_size_list , results.validHR-results.invalidHR,...
	'.-', 'LineWidth', 2, 'MarkerSize', 20)
%ylim([0 1])
xlabel('set size')
ylabel('cuing effect')

% text for fixed parameter
fixed = sprintf('variance = %1.1f', expt.variance_list);
bordertext('topleft', fixed);

legend(num2str(expt.cue_validity_list'))
legend('Location','NorthEast')

drawnow

end


function results=doParameterSweep(expt)

tic

mcmcparams	= define_mcmcparams(expt.run_type, expt.TRIALS);
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
			
			fprintf('job %d of %d: %s\n', jobCount, nJobs)
			
			% run the main MCMC code with these parameters
			[AUC(n,cv,v), AUC_valid_present(n,cv,v), AUC_invalid_present(n,cv,v),...
				validHR(n,cv,v), invalidHR(n,cv,v)]=...
				MCMCcuedYesNo(mcmcparams, N, variance, cue_validity, expt.TRIALS);
			
			jobCount = jobCount + 1;
		end
	end
end

% return results
results.AUC					= squeeze(AUC);
results.AUC_valid_present	= squeeze(AUC_valid_present);
results.AUC_invalid_present = squeeze(AUC_invalid_present);
results.validHR				= squeeze(validHR);
results.invalidHR			= squeeze(invalidHR);

min_sec(toc);
end


function plotExperimentResults(expt, results, xVariable, xlabeltext)
%
% = getfield(expt, xVariable);
x = expt.(xVariable); % <-- use of dynamic field name

% plot output for AUC ~~~~~~~~~~~~~~~~~~~
subplot(2,3,1)
plotStuff(x, results.AUC_valid_present, xlabeltext, 'AUC', 'valid')

subplot(2,3,2)
plotStuff(x, results.AUC_invalid_present, xlabeltext, 'AUC', 'invalid')

subplot(2,3,3)
plotStuff(x, results.AUC_valid_present - results.AUC_invalid_present,...
	xlabeltext, 'AUC', 'cueing benefit')

% plot output for hit rates ~~~~~~~~~~~~~~~~~~~
subplot(2,3,4)
plotStuff(x, results.validHR, xlabeltext, 'HR', 'valid')

subplot(2,3,5)
plotStuff(x, results.invalidHR, xlabeltext, 'HR', 'invalid')

subplot(2,3,6)
plotStuff(x, results.validHR-results.invalidHR,...
	xlabeltext, 'HR', 'cueing benefit HR')

drawnow

	function plotStuff(x, y, xlabeltext, ylabeltext, titleText)
		hold all, %set(gca, 'ColorOrder', ColorSet);
		plot( x , y, '.-',...
			'LineWidth', 2, 'MarkerSize', 20)
		xlabel(xlabeltext), ylabel(ylabeltext)
		title(titleText)
		
		% append info
		dt = datestr(now,'yyyy mmm dd, HH:MM AM');
		bordertext('figurebottomright', [mfilename ' ' dt]);
	end

end

