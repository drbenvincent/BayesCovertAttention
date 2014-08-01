%%  MCMCdetection.m
%
%%


function [AUC, FAR, HR] = MCMCyesno(mcmcparams, N, varT, varD, TRIALS)
% [AUC, FAR, HR] = MCMCyesno(2, 1, 4, 10000)



%% STEP 1: GENERATE SIMULATED DATASET (L,x)
% We will generate a simulated dataset by sampling from the model, which
% achieved simply by not providing it with any sensory observations (x).
% We ask the JAGS model to return samples of the trial type (L) and the
% corresponding sensory observations (x), and so we are sampling from the
% joint distribution $P(L,x|params)$.
%
% Later in step 2, the sensory observations are provided to the model, and
% is infers the trial type (L). Because we have the actual trial types
% (from this step 1) then we can compare the inferred trial type to the
% actual trial type to evaluate the detection performance of the model.


JAGSmodel = 'JAGSdetection.txt';


%%
% Define parameters and place observed parameter values into the structure
% |data|.
prob_present	= 0.5;
data.N			= N; % number of locations
data.T			= 1; % only 1 trial, but we sample many times
data.varT       = varT;
data.varD       = varD;
	
%%
% Construct a prior over display type
data.Dprior		= [prob_present.*(ones(data.N,1)/data.N) ; (1-prob_present)]';


%%
% Set parameters for JAGS
nchains  = 1;		% How Many Chains?
nburnin  = 1000;	% How Many Burn-in Samples?
nsamples = TRIALS;	% How Many Recorded Samples? THIS IS HOW MANY SIMULATED TRIALS WE WANT

%%
% Set initial values for latent variable in each chain
for i=1:nchains
	initial_param(i).D			= data.N+1;
end

%%
% Call JAGS to generate MCMC samples
[dataset, stats] = matjags( ...
    data, ... 
    fullfile(pwd, JAGSmodel), ...
    initial_param, ...
    'doparallel' , mcmcparams.doparallel, ...
    'nchains',  mcmcparams.generate.nchains,...
    'nburnin', mcmcparams.generate.nburnin,...
    'nsamples', mcmcparams.generate.nsamples, ...
    'thin', 1, ...
    'monitorparams', {'D','x'}, ...
    'savejagsoutput' , 1 , ...
    'verbosity' , 1 , ...
    'cleanup' , 1 , ...
    'rndseed',1,...
	'dic',0);                    



%% STEP 2: INFER THE TRIAL TYPE (L) GIVEN THE SENSORY OBSERVATIONS
% Step 1 has privided us with a simulated dataset of target locations (L)
% and corresponding noisy sensory observations (x) by sampling from the
% joint distribution $P(L,x|params)$. 
%
% In step 2 we are engaging in "parameter recovery" where we are seeing if
% the optimal observer model can accurately infer the target location if we
% only provide it with sensory observations. This amounts to calculating
% the posterior distribution $P(L|x,params)$ which we will calculate now.

tic
x = squeeze(dataset.x)';

% number of simulated trials we asked for in step 1
T = size(x,2);

% update the parameters structure
data.x		= x;
data.T		= T; 

% Defining some MCMC parameters for JAGS
nchains  = 2; % How Many Chains? just because I have 4 cores
nburnin  = 500; % How Many Burn-in Samples?
nsamples = 1000;  % How Many Recorded Samples?

% Set initial values for latent variable in each chain
clear initial_param
for i=1:nchains
	S.D					= randi(data.N+1, T,1); 
 	initial_param(i)	= S;
	%initial_param(i).theta		= rand(data.N,T)';
	%initial_param(i).theta		= rand(data.N,1);
	%initial_param(i).variance	=data.variance	;
end

%%
% Call JAGS to generate MCMC samples
[samples, stats, structArray] = matjags( ...
    data, ...							% Observed data   
    fullfile(pwd, JAGSmodel), ...		% File that contains model definition
    initial_param, ...					% Initial values for latent variables
    'doparallel' , 1, ...      % Parallelization flag
    'nchains', nchains,...              % Number of MCMC chains
    'nburnin', nburnin,...              % Number of burnin steps
    'nsamples', nsamples, ...           % Number of samples to extract
    'thin', 1, ...                      % Thinning parameter
    'monitorparams', {'D'}, ...     % List of latent variables to monitor
    'savejagsoutput' , 0 , ...          % Save command line output produced by JAGS?
    'verbosity' , 0 , ...               % 0=do not produce any output; 1=minimal text output; 2=maximum text output
    'cleanup' , 0,...% clean up of temporary files?
    'rndseed',1);                    


%%
% Convergence diagnostics. Displaying the MCMC chains graphicallly is less
% instructive for discreet variables (such as L), so instead we are just
% going to check that $\hat{R}<1.05$.
if max(stats.Rhat.D) > 1.05
    error('WARNING, Rhat > 1.05, indicates lack of chain convergence.')
end


%% STEP 3: Decision step
% From step 2, we have calculated the posterior distribution over L, for
% each trial, $P(L,x|params)$. If we were dealing with a real experimental
% participant, all we could observe would be their behavioural response,
% but because this is an optimal observer model we have direct access to
% their posterior distribution over target presence/absence. This can be used
% in order to generate ROC curves.
%
% The approach will be to extract the posterior probability of target
% presence for signal (target present) and noise (target absent) trials,
% and then use this to calculate an ROC curve by considering a large number
% of potential decision thresholds.
%
% First, create binary vectors to label the signal (target present) and noise
% (target absent) trials.
signal_trials	= dataset.D<=data.N;
noise_trials	= dataset.D==data.N+1;

% preallocate
Ppresent = zeros(T,1);
%%
% Calculate the decision variable for all trials. This is the posterior
% probability of the L indicating target presence, i.e. L={1,...,N} and not
% L=N+1 (indicating target absence).
for t=1:T
	% grab the MCMC samples of L for this trial, for all chains
	temp = vec( samples.D( [1:nchains] ,:,t) );
	
	% Calculate the distribution over D (for each trial) as generated by the
	% MCMC samples
	[Dfreq,n] = hist(temp,[1:data.N+1]);
	
	% Normalise into a probability disibution over L.
	Dprob=Dfreq./sum(Dfreq);
	
	% Calculate the decision variable... the posterior probability the target
	% is present, i.e. the probability mass corresponding to L={1,...,N}
	Ppresent(t) = sum( Dprob([1:N]) );
end


%% 
% Grab the decision variables for the signal and the noise trials
S = Ppresent(signal_trials);
N = Ppresent(noise_trials);
% Use that to calculate ROC curve with the function
% |ROC_calcHRandFAR_VECTORIZED|.
[HR, FAR, AUC]=ROC_calcHRandFAR_VECTORIZED(N,S);


%% 
% One can investigate the distributions of posterior probability of target
% present, for signal and noise trials by using the code below. This is
% commented out as it is only useful for checking and understanding the
% code.

% % plot the distributions of the decision variable (probability present) for
% % the absent (noise) and present (signal trials)
% clf
% subplot(1,2,1)
% hist_compare(S,N,20)
% legend('signal (present)' , 'noise (absent)')
% xlabel('P(present) the decision variable')
% axis square
% 
% % now plot ROC curve
% subplot(1,2,2)
% [HR, FAR, AUC]=ROC_calcHRandFAR_VECTORIZED(N,S);
% plot(FAR,HR)
% format_axis_ROC
% title(AUC)
% drawnow

return