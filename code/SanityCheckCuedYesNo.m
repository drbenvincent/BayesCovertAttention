function SanityCheckCuedYesNo

run_type	='testing'
TRIALS		= 1000;

mcmcparams = define_mcmcparams(run_type, TRIALS)

%% Set size N=2

N=4
variance=1
cue_validity=0.8 % uninformative cue 


[AUC, AUC_valid_present, AUC_invalid_present, ...
	validHR, invalidHR] = internalMCMCcuedYesNo(mcmcparams, N, variance, cue_validity, TRIALS)


validHR
invalidHR

AUC

AUC_valid_present

AUC_invalid_present

return







function [AUC, AUC_valid_present, AUC_invalid_present, ...
	validHR, invalidHR] = internalMCMCcuedYesNo(mcmcparams, N, variance, cue_validity, TRIALS)
%  N=4; variance = 1; cue_validity=0.5; TRIALS =1000;

%% Preliminaries
JAGSmodel = 'JAGScueddetection.txt';

%% STEP 1: GENERATE SIMULATED DATASET
% Place observed variables into the structure |params| to pass to JAGS
params.N 				= N;
params.T                = 1;% simulate 1 trial, but generate many MCMC samples, see below
params.v                = cue_validity;
params.varT         = variance;
params.varD         = variance;
params.uniformdist      = ones(N,1)./N; % uniform distribution, for cue location

%%
% Set initial values for latent variable in each chain

for i=1:mcmcparams.generate.nchains
    initial_param(i).D = round( ( rand*(N-1)) +1);
end

%%
% Calling JAGS to generate simulated data
%fprintf( 'Running JAGS...\n' );
%tic
[dataset, stats, structArray] = matjags( ...
    params, ...
    fullfile(pwd, JAGSmodel), ...
    initial_param, ...
    'doparallel' , mcmcparams.doparallel, ...
    'nchains', mcmcparams.generate.nchains,...
    'nburnin', mcmcparams.generate.nburnin,...
    'nsamples', mcmcparams.generate.nsamples, ...
    'thin', 1, ...
    'monitorparams', {'c','D','x','Dprior'}, ...
    'savejagsoutput' , 0 , ...
    'verbosity' , 1 , ...
    'cleanup' , 1 ,...
    'rndseed',1,...
    'dic',0);


clear initial_param

%%
% sanity check here ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

x		= squeeze(dataset.x)';
T		= TRIALS;
C		= squeeze(dataset.c)';
Dprior	= squeeze(dataset.Dprior);
D		= squeeze(dataset.D)';
clc
% 1. do the priors over display types sum to 1 on every trial?
if sum( sum(Dprior,2) ~=1 ) > 0
	display('TEST1: FAIL')
	display('possibility... the numbers are EXACTLY equal to 1, but very close')
else
	display('TEST1: Passed')
end

% 2. what is the actual occurence of each display type?
[n,~]=hist(D,[1:N+1]); p=n./sum(n);
fprintf('TEST2: relative occurence of each display type:')
display(p)

% 3. did the proportion of present/valid trials match the cue
% validity*prevelance
display('TEST3: ')
fprintf('cue should equal the display type on (v*prevelance)=%2.2f\n',...
	cue_validity*0.5)
fprintf('actual was %2.2f\n', sum(C==D)./TRIALS)

% 3. the distribution of cues should be uniform
display('TEST4: distribution of cued should be uniform ')
[n,~]=hist(C,[1:N]); p=n./sum(n);
display(p)

% 4. test the mean and variance of the stimuli x
 % check mean and variance of ALL observations on target absent trials
 tempx=vec(x(:,D==N+1));
 mean(tempx)
 var(tempx)
 % check mean and variance of TARGETS on present trials
 present = D<N+1;
 tloc = D(present);
targetx=[];
 for t=1:T
	 % skip criteria
	 if D(t)==N+1, continue, end
	 
	 targetx = [targetx x(D(t),t)];
 end
  mean(targetx)
  var(targetx)
  
pause
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~








%%
% grab true locations from the dataset made in step 1
true_location = squeeze(dataset.D);









%% STEP 2: INFER THE TRIAL TYPE GIVEN THE SENSORY OBSERVATIONS
% Now do inference on ALL the generated data


%%
% update some of the parameters
params.x		= squeeze(dataset.x)';
params.T		= TRIALS;
params.c		= squeeze(dataset.c)';

%%
% Set initial values for latent variable in each chain
for i=1:mcmcparams.infer.nchains
    initial_param(i).D			= randi(params.N+1, TRIALS,1);
end
 
%%
% Calling JAGS to sample
%fprintf( 'Running JAGS...\n' );
%tic
[samples, stats, structArray] = matjags( ...
    params, ...
    fullfile(pwd, JAGSmodel), ...
    initial_param, ...
    'doparallel' , mcmcparams.doparallel, ...
    'nchains', mcmcparams.infer.nchains,...
    'nburnin', mcmcparams.infer.nburnin,...
    'nsamples', mcmcparams.infer.nsamples, ...
    'thin', 1, ...
    'monitorparams', {'D'}, ...
    'savejagsoutput' , 0 , ...
    'verbosity' , 1 , ...
    'cleanup' , 1 ,...
    'rndseed',1);



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
present_trials	= dataset.D<=params.N;
absent_trials	= dataset.D==params.N+1;

valid_present_trials = dataset.D==dataset.c;
invalid_present_trials = dataset.D~=dataset.c;

% preallocate
Ppresent = zeros(params.T,1);
response = zeros(params.T,1);
%%
% Calculate the decision variable for all trials. This is the posterior
% probability of the L indicating target presence, i.e. L={1,...,N} and not
% L=N+1 (indicating target absence).
tic
parfor t=1:params.T
	% grab the MCMC samples of L for this trial, for all chains
	%temp = vec( samples.D( [1:mcmcparams.infer.nchains] ,:,t) );
	temp = vec( samples.D(:,:,t) );
	
	% Calculate the distribution over D (for each trial) as generated by the
	% MCMC samples
	[Dfreq,n] = hist(temp,[1:params.N+1]);
	
	% Normalise into a probability disibution over L.
	Dprob=Dfreq./sum(Dfreq);
	
	% Calculate the decision variable... the posterior probability the target
	% is present, i.e. the probability mass corresponding to L={1,...,N}
	Ppresent(t) = sum( Dprob([1:N]) );
	
	% What is the response of an unbiased observer?
	if Ppresent(t)>=0.5
		response(t)=1;
	else
		response(t)=0;
	end
end
toc

%% Calculate the valid hit rate, and invalid hit rate
NvalidPresent = sum(valid_present_trials);
NinvalidPresent = sum(invalid_present_trials);
all_hits	= present_trials' == response;
validHR		= sum(all_hits(valid_present_trials)) / NvalidPresent;
invalidHR	= sum(all_hits(invalid_present_trials)) / NinvalidPresent; 

%% 
% Grab the decision variables for the signal and the noise trials
S = Ppresent(present_trials);
N = Ppresent(absent_trials);
% Use that to calculate ROC curve with the function
% |ROC_calcHRandFAR_VECTORIZED|.
[HR, FAR, AUC]=ROC_calcHRandFAR_VECTORIZED(N,S);

% Grab the decision variables for the signal and the noise trials
VP = Ppresent(valid_present_trials);
IP = Ppresent(invalid_present_trials);
% Use that to calculate ROC curve with the function
% |ROC_calcHRandFAR_VECTORIZED|.
[HR, FAR, AUC_valid_present]=ROC_calcHRandFAR_VECTORIZED(N,VP);
[HR, FAR, AUC_invalid_present]=ROC_calcHRandFAR_VECTORIZED(N,IP);

figure(5), clf
subplot(1,2,1), hist_compare(N,VP,50)
xlabel('P(present)')
title('valid')

subplot(1,2,2), hist_compare(N,IP,50)
xlabel('decision variable, P(present)')
title('invalid')
drawnow


return