%%  MCMCcuedYesNo.m
%
%%

function [AUC, AUC_valid_present, AUC_invalid_present] = MCMCcuedYesNo(mcmcparams, N, variance, cue_validity, TRIALS)
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
params.uniformdist      = ones(N,1)./N; % uniform distribution
% % create uninformative prior for dirichlet distribution
% params.dirchprior = ones(N,1);

% for generating the data, we specify the distribution from which L is sampled from
%params.pdist			= ones(N,1)./N;
% create uninformative prior for dirichlet distribution
% params.dirchprior 		= ones(N,1);

%%
% % MCMC parameters for JAGS
% nchains  = 1;       % WE WANT ONE CHAIN
% nburnin  = 1000;    % How Many Burn-in Samples?
% nsamples = TRIALS;  % How many simulated truals we want

% Set initial values for latent variable in each chain
for i=1:mcmcparams.generate.nchains
    %initial_param(i).L			= randi(params.N);
    
    % The guess initial parameter value for L cannot equal a location who's
    % spatial prior is equal to zero, otherwise we get an error message
    % from JAGS.
    
    initial_param(i).D = round( ( rand*(N-1)) +1);
    
    % 	done=0;
    %  	while done~=1
    % 		tempLocation = round( ( rand*(N-1)) +1);
    %  		if params.v(tempLocation) ~=0
    %  			initial_param(i).L = tempLocation;
    %  			done=1;
    % 		end
    %  	end
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
    'monitorparams', {'c','D','x'}, ...
    'savejagsoutput' , 0 , ...
    'verbosity' , 0 , ...
    'cleanup' , 1 ,...
    'rndseed',1,...
    'dic',0);


clear initial_param


%%
% grab true locations from the dataset made in step 1
true_location = squeeze(dataset.D);









%% STEP 2: INFER THE TRIAL TYPE GIVEN THE SENSORY OBSERVATIONS
% Now do inference on ALL the generated data

% now we MAY OR MAY NOT want to remove knowledge that L is sampled from a uniform distribution over each location (pdist=[1/N ... 1/N])
%params = rmfield(params, 'pdist')

%%
% update some of the parameters
params.x		= squeeze(dataset.x)';
params.T		= TRIALS;
params.c		= squeeze(dataset.c)';

%%
% % Defining some MCMC parameters for JAGS
% nchains  = 2; % How Many Chains?
% nburnin  = 1000; % How Many Burn-in Samples?
% nsamples = 2000;  % How Many Recorded Samples?

% Set initial values for latent variable in each chain
% for i=1:mcmcparams.infer.nchains
% 	initial_param(i).L			= randi(params.N, TRIALS,1);
% end

for i=1:mcmcparams.infer.nchains
    initial_param(i).D			= randi(params.N, TRIALS,1);
end
    
% for i=1:mcmcparams.infer.nchains
%     initial_param(i)=0;
%     %initial_param(i).L			= randi(params.N, TRIALS,1);
% %     for t=1:TRIALS
% %         for n=1:N
% %             initial_param(i).x(n,t) = [];
% %         end
% %         
% %         % 		%initial_param(i).L(t) = round( ( rand*(N-1)) +1);
% %         %
% %         % 		% We need the initial parameter guess for L to NOT be in a location
% %         % 		% where the target cannot be. For example, if the cue validity is
% %         % 		% zero and the cue is observed in location 1, then we need the
% %         % 		% initial guess of L to be anything other than 1.
% %         %
% %         % 		% L
% %         % 		done=0;
% %         % 		while done~=1
% %         % % 			% calculate cue distribution
% %         % % 			cue_dist=ones(N,1)* (1-cue_validity)/(N-1);
% %         % % 			cue_dist(params.c(t)) = cue_validity;
% %         %
% %         % 			tempLocation = round( (rand*(params.N-1)) +1);
% %         % 			if cue_dist(tempLocation) ~=0
% %         % 				initial_param(i).L(t) = tempLocation;
% %         % 				done=1;
% %         % 			end
% %         % 		end
% %         % %
% %         % % 		% c
% %         % % 		done=0;
% %         % % 		while done~=1
% %         % % 			tempLocation = round( (rand*(params.N-1)) +1);
% %         % % 			if params.pdist(tempLocation) ~=1
% %         % % 				initial_param(i).c(t) = tempLocation;
% %         % % 				done=1;
% %         % % 			end
% %         % % 		end
% %         %
% %         % 		%initial_param(i).L(t) = round( (rand*(params.N-1)) +1);
% %         
% %     end
% end

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
    'verbosity' , 0 , ...
    'cleanup' , 1 ,...
    'rndseed',1);
%min_sec(toc);


% %%
% % Extract the MCMC samples and use them to calculate the performance
% % (proportion correct, |PC|).
% 
% for t=1:TRIALS
%     D(t)		= mode( vec(samples.D(:,:,t)) );
% end
% 
% % Examine the performance of the optimal observer
% Ncorrect = sum( D==true_location );
% [PC, PCI] = binofit(Ncorrect,TRIALS);


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
%%
% Calculate the decision variable for all trials. This is the posterior
% probability of the L indicating target presence, i.e. L={1,...,N} and not
% L=N+1 (indicating target absence).
tic
for t=1:params.T
	% grab the MCMC samples of L for this trial, for all chains
	temp = vec( samples.D( [1:mcmcparams.infer.nchains] ,:,t) );
	
	% Calculate the distribution over D (for each trial) as generated by the
	% MCMC samples
	[Dfreq,n] = hist(temp,[1:params.N+1]);
	
	% Normalise into a probability disibution over L.
	Dprob=Dfreq./sum(Dfreq);
	
	% Calculate the decision variable... the posterior probability the target
	% is present, i.e. the probability mass corresponding to L={1,...,N}
	Ppresent(t) = sum( Dprob([1:N]) );
end
toc

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


return