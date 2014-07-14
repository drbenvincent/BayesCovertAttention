%%  MCMCcuedLocalisation.m
%
%%

function [PC] = MCMCcuedLocalisation(mcmcparams, N, variance, cue_validity, TRIALS)
%  N=4; variance = 1; cue_validity=0.5; TRIALS =1000;

%% Preliminaries
JAGSmodel = 'JAGScuedlocalisation.txt';


%% STEP 1: GENERATE SIMULATED DATASET
% Place observed variables into the structure |params| to pass to JAGS
params.N 				= N;
params.T                = 1;% simulate 1 trial, but generate many MCMC samples, see below
params.v                = cue_validity;
params.variance         = variance;
params.uniformdist      = ones(N,1)./N; % uniform distribution
% % create uninformative prior for dirichlet distribution
% params.dirchprior = ones(N,1);

% for generating the data, we specify the distribution from which L is sampled from
params.pdist			= ones(N,1)./N; 
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

	initial_param(i).L = round( ( rand*(N-1)) +1);
	
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
[dataset, stats, structArray] = matjagsBEN( ...
    params, ...                 
    fullfile(pwd, JAGSmodel), ...   
    initial_param, ...                     
    'doparallel' , mcmcparams.doparallel, ...      
    'nchains', mcmcparams.generate.nchains,...              
    'nburnin', mcmcparams.generate.nburnin,...             
    'nsamples', mcmcparams.generate.nsamples, ...           
    'thin', 1, ...                      
    'monitorparams', {'c','L','x','pdist'}, ...    
    'savejagsoutput' , 0 , ...   
    'verbosity' , 0 , ...              
    'cleanup' , 1 ,...
    'rndseed',1);                    
%min_sec(toc);

clear initial_param


%%
% grab true locations from the dataset made in step 1
true_location = squeeze(dataset.L);









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
	%initial_param(i).L			= randi(params.N, TRIALS,1);
	for t=1:TRIALS
		
		%initial_param(i).L(t) = round( ( rand*(N-1)) +1);
		
		% We need the initial parameter guess for L to NOT be in a location
		% where the target cannot be. For example, if the cue validity is
		% zero and the cue is observed in location 1, then we need the
		% initial guess of L to be anything other than 1.
		
		% L
		done=0;
		while done~=1
			% calculate cue distribution
			cue_dist=ones(N,1)* (1-cue_validity)/(N-1);
			cue_dist(params.c(t)) = cue_validity;
			
			tempLocation = round( (rand*(params.N-1)) +1);
			if cue_dist(tempLocation) ~=0
				initial_param(i).L(t) = tempLocation;
				done=1;
			end
		end
% 		
% 		% c
% 		done=0;
% 		while done~=1
% 			tempLocation = round( (rand*(params.N-1)) +1);
% 			if params.pdist(tempLocation) ~=1
% 				initial_param(i).c(t) = tempLocation;
% 				done=1;
% 			end
% 		end
		
		%initial_param(i).L(t) = round( (rand*(params.N-1)) +1);

	end
end

%%
% Calling JAGS to sample
%fprintf( 'Running JAGS...\n' );
%tic
[samples, stats, structArray] = matjagsBEN( ...
    params, ...                       
    fullfile(pwd, JAGSmodel), ...    
    initial_param, ...                          
    'doparallel' , mcmcparams.doparallel, ...      
    'nchains', mcmcparams.infer.nchains,...             
    'nburnin', mcmcparams.infer.nburnin,...             
    'nsamples', mcmcparams.infer.nsamples, ...           
    'thin', 1, ...                      
    'monitorparams', {'L','pdist'}, ...  
    'savejagsoutput' , 0 , ... 
    'verbosity' , 0 , ... 
    'cleanup' , 1 ,...
    'rndseed',1); 
%min_sec(toc);


%%
% Extract the MCMC samples and use them to calculate the performance
% (proportion correct, |PC|).

for t=1:TRIALS
	L(t)		= mode( vec(samples.L(:,:,t)) );
end

% Examine the performance of the optimal observer
Ncorrect = sum( L==true_location );
[PC, PCI] = binofit(Ncorrect,TRIALS);


return