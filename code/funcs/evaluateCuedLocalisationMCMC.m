%%  MCMCcuedYesNo.m
%
%%

function [PC] = evaluateCuedLocalisationMCMC(opts, N, variance, cue_validity)
%  N=4; variance = 1; cue_validity=0.5; TRIALS =1000;

%% Preliminaries
JAGSmodel = 'JAGScuedlocalisation.txt';
mcmcparams	= define_mcmcparams(opts);

%% STEP 1: GENERATE SIMULATED DATASET
% Place observed variables into the structure |params| to pass to JAGS
params.N 				= N;
params.T                = 1;% simulate 1 trial, but generate many MCMC samples, see below
params.v                = cue_validity;
params.variance         = variance;
params.uniformdist      = ones(N,1)./N; % uniform distribution


%%
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
params.T		= opts.trials;
params.c		= squeeze(dataset.c)';

%%
% % Defining some MCMC parameters for JAGS

for i=1:mcmcparams.infer.nchains
    initial_param(i).D			= randi(params.N, opts.trials, 1);
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
    'verbosity' , 0 , ...
    'cleanup' , 1 ,...
    'rndseed',1);

%%
% Extract the MCMC samples and use them to calculate the performance
% (proportion correct, |PC|).

for t=1:opts.trials
    D(t)		= mode( vec(samples.D(:,:,t)) );
end

% Examine the performance of the optimal observer
Ncorrect = sum( D==true_location );
[PC, PCI] = binofit(Ncorrect, opts.trials);


return