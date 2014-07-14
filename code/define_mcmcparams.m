function mcmcparams = define_mcmcparams(run_type, TRIALS)

switch run_type
	case{'testing'}
		
		mcmcparams.doparallel=1;
		
		mcmcparams.generate.nchains = 1;
		mcmcparams.generate.nburnin = 500;
		mcmcparams.generate.nsamples = TRIALS; % number of simulated trials
		
		mcmcparams.infer.nchains = 4;
		mcmcparams.infer.nburnin = 1000;
		mcmcparams.infer.nsamples = round(10^2/mcmcparams.infer.nchains);  
		
		
	case{'publication'}
		
		mcmcparams.doparallel =1;
		
		mcmcparams.generate.nchains = 1;
		mcmcparams.generate.nburnin = 500;
		mcmcparams.generate.nsamples = TRIALS; % number of simulated trials
		
		mcmcparams.infer.nchains = 4;
		mcmcparams.infer.nburnin = 1000;
		mcmcparams.infer.nsamples = round(10^4/mcmcparams.infer.nchains);  
		
end

return