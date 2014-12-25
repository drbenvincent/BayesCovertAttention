%% SCRIPTcuedLocalisation
% This script calculates the predictions for cued N-AFC localisation.
% All of these experimental results are a by-product of conducting inference
% about the state of the world (display type, $L$) given noisy sensory
% observations $x$, and knowledge of the causal structure of the detection
% task (see graphical model below) and the internal observation uncertainty
% associated with targets ($\sigma^2_T$) and distractors ($\sigma^2_D$).
%
% <<BGMcuedLocalisation.png>>
%
%%

function SCRIPTcuedLocalisation(opts)
% SCRIPTcuedLocalisation('testing')

%% Preliminaries
% add paths to dependencies
addpath([cd '/funcs'])
addpath([cd '/funcs/export_fig'])
addpath([cd '/funcs/latex_fig'])
addpath([cd '/funcs/hline_vline'])
addpath([cd '/funcs/ColorBand'])
addpath([cd '/funcs/bordertext'])
addpath([cd '/funcs/bens_helper_functions'])
% are we doing a quick run, or a proper long run?
%run_type = 'testing'; % ['testing'|'publication']
T1=clock;

%% Define parameters
% Select parameters to use based on if we are quick testing (faster
% computation times) or final runs (will take a while to compute).

% switch run_type
%     case{'testing'}
%         TRIALS				= 100; % number of trials to simulate it any one run
%         cue_validity_list	= linspace(0.001,1-0.001,5);
%         variance_list		= 1./[4  1  0.25];
%         
%     case{'publication'}
%         TRIALS				= 50000; % number of trials to simulate it any one run
%         cue_validity_list	= linspace(0.001,1-0.001,9);
%         variance_list		= 1./[4  1  0.25];
% end

cue_validity_list	= linspace(0.001,1-0.001,9);
variance_list		= 1./[4  1  0.25];

%mcmcparams = define_mcmcparams(run_type, TRIALS);

%% Run predictions for set size N=2
N = 2;
cuedlocalisation_job(opts, N, cue_validity_list, variance_list, 1)

%% Run predictions for set size N=4
N = 4;
cuedlocalisation_job(opts, N, cue_validity_list, variance_list, 2)


%% time
T2=clock;
min_sec(etime(T2,T1));	
etime(T2,T1)/60 ;% time in mins

%% Export the figure 

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
hgsave('results_cued_localisation')
export_fig results_cued_localisation -png -pdf -m1
cd(codedir)



end




%% Sub-function: predictions for a given set size, |N|

function cuedlocalisation_job(opts, N, cue_validity_list, variance_list, subfig)

dprime				= 1./sqrt(variance_list);

%%
% Loop over a range of cue validities and $d'$ values and compute the
% proportion correct (|PC|) with the function |MCMClocalisation.m|.
jobcount = 1;
for v=1:numel(variance_list)
	variance = variance_list(v);
	
	for cv = 1:numel(cue_validity_list)
		cue_validity = cue_validity_list(cv);
		
		fprintf('job %d of %d: %s\n', jobcount,...
			numel(variance_list)*numel(cue_validity_list), datestr(now) )
		% run the main MCMClocalisation code with these parameters
		
		
		switch opts.evalMethod
			case{'MCMC'}
				PC(cv,v) = evaluateCuedLocalisationMCMC(opts, N, variance, cue_validity);

			case{'nonMCMC'}
				sigma=sqrt(variance);
				PC(cv,v) = evaluateCuedLocalisation(N, sigma, opts.trials, cue_validity);

		end
			
		jobcount = jobcount + 1;
	end
end

%%
% Plot the results
figure(1)
subplot(1,2,subfig)

plot( cue_validity_list.*100 , PC, '.-k',...
    'LineWidth', 2, 'MarkerSize', 20)
hline(1/N)
axis square

set(gca,'XTick',[0:25:100],...
	'ylim', [0 1],...
	'XTick',[0:25:100])

title(['set size = ' num2str(N)],'FontSize',16)
xlabel('expectation (%)')
ylabel('percent correct')

drawnow

end







