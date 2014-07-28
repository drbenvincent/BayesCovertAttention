%%  MCMCLocalisation.m
%
%%

function [PC] = MCMClocalisation(mcmcparams,N, Dprior, variance, TRIALS)
%  N=4; Dprior=[1/2 1/6 1/6 1/6]; variance = 1; TRIALS =100;

%% Preliminaries
JAGSmodel = 'JAGSlocalisation.txt';


%% STEP 1: GENERATE SIMULATED DATASET
% Place observed variables into the structure |params| to pass to JAGS
params.N 				= N;
% ******************************
params.T                = 1;% simulate 1 trial, but generate many MCMC samples, see below
% ******************************
params.variance         = variance;

% for generating the data, we specify the distribution from which L is sampled from
params.Dprior			= Dprior; 
% create uninformative prior for dirichlet distribution
%params.dirchprior 		= ones(N,1);

% %%
% % MCMC parameters for JAGS
% nchains  = 1;       % WE WANT ONE CHAIN
% nburnin  = 1000;    % How Many Burn-in Samples?
% nsamples = TRIALS;  % How many simulated truals we want

% Set initial values for latent variable in each chain
for n=1:mcmcparams.generate.nchains
    
    %initial_param(i).L = round( ( rand*(N-1)) +1);
    
    %initial_param(i).L = 2;
    
    % The guess initial parameter value for L cannot equal a location who's
    % spatial prior is equal to zero, otherwise we get an error message
    % from JAGS.
    
    % 	done=0;
    %  	while done~=1
    % 		tempLocation = round( ( rand*(N-1)) +1);
    %  		if params.pdist(tempLocation) ~=0
    %  			initial_param(n).L = tempLocation;
    %  			done=1;
    % 		end
    %     end
    
    for t=1:params.T
        done=0;
        while done~=1
            tempLocation = round( ( rand*(N-1)) +1);
            if params.Dprior(tempLocation) ~=0
                initial_param(n).D(t) = tempLocation;
                done=1;
            end
        end
    end
    
end


%%
% Calling JAGS to generate simulated data
%fprintf( 'Running JAGS...\n' );
%tic

% THIS CODE DOES NOT WORK. I WANT THIS TO WORK ********************
[dataset, stats] = matjags( ...
    params, ...                 
    fullfile(pwd, JAGSmodel), ...   
    initial_param, ...                     
    'doparallel' , mcmcparams.doparallel, ...      
    'nchains', mcmcparams.generate.nchains,...              
    'nburnin', mcmcparams.generate.nburnin,...             
    'nsamples', mcmcparams.generate.nsamples, ...           
    'thin', 1, ...                      
    'monitorparams', {'D','x'}, ...    
    'savejagsoutput' , 1 , ...   
    'verbosity' , 1 , ...              
    'cleanup' , 1 ,...
    'rndseed',0,...
    'dic',0); 

% THIS CODE BELOW WORKS. 
% [dataset, stats] = matjagsBEN( ...
%     params, ...                 
%     fullfile(pwd, JAGSmodel), ...   
%     initial_param, ...                     
%     'doparallel' , mcmcparams.doparallel, ...      
%     'nchains', mcmcparams.generate.nchains,...              
%     'nburnin', mcmcparams.generate.nburnin,...             
%     'nsamples', mcmcparams.generate.nsamples, ...           
%     'thin', 1, ...                      
%     'monitorparams', {'L','x'}, ...    
%     'savejagsoutput' , 1 , ...   
%     'verbosity' , 1 , ...              
%     'cleanup' , 1);  

%min_sec(toc);

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

% %%
% % Defining some MCMC parameters for JAGS
% nchains  = 2; % How Many Chains?
% nburnin  = 1000; % How Many Burn-in Samples?
% nsamples = 2000;  % How Many Recorded Samples?

% Set initial values for latent variable in each chain
	% The guess initial parameter value for L cannot equal a location who's
	% spatial prior is equal to zero, otherwise we get an error message
	% from JAGS.
for i=1:mcmcparams.infer.nchains
	%initial_param(i).L			= randi(params.N, TRIALS,1);
	for t=1:TRIALS
		
		done=0;
		while done~=1
			tempLocation = round( (rand*(params.N-1)) +1);
			if params.Dprior(tempLocation) ~=0
				initial_param(i).D(t) = tempLocation;
				done=1;
			end
		end
	
	
		%initial_param(i).L(t) = round( (rand*(params.N-1)) +1);

	end
end
%initial_param(i).L

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
    'savejagsoutput' , 1 , ... 
    'verbosity' , 1 , ... 
    'cleanup' , 1 ,...
    'rndseed',1); 
%min_sec(toc);


%%
% Extract the MCMC samples and use them to calculate the performance
% (proportion correct, |PC|).
%
% The MCMC samples returned from JAGS for the parameter L (estimated signal
% location) is contained in the matrix samples.L. This is a 3-dimensional
% matrix, of size [nchains, nsamples, TRIALS].
%
% Our task now is, for each trial, to examine the posterior distribution
% over L. We will do this by looping over trials. For each trial we extract
% the MCMC samples from all chains, turn this into a vector, and then
% calcaulte the maximum a posterior (MAP) estimate of the signal location.
% Because L is a discreet distribution ($L={1,...,N}$), we can simply calculate 
% the modal value.

for t=1:TRIALS
    % extract MCMC samples for this trial
    samples_for_this_trial = samples.D(:,:,t);
    % convert into a vector
    samples_for_this_trial = samples_for_this_trial(:);
    % Calculate the MAP estimate of target location, i.e. the mode of L
	D(t)		= mode( samples_for_this_trial );
end

%%
% Examine the performance of the optimal observer. On what proportion of
% the trials did the observer's MAP estimate of L correspond to the true
% target location?
Ncorrect = sum( D==true_location );
[PC, PCI] = binofit(Ncorrect,TRIALS);


return