function runAll(eval_method)
% runAll('nonMCMC')
% runAll('MCMC')

close all

%% define options
switch eval_method
	case{'MCMC'}
		opts.trials		= 1000;
		opts.evalMethod	= 'MCMC';
		opts.run_type	= 'testing'; %either 'testing' or 'publication'
		
	case{'nonMCMC'}
		opts.trials		= 10000;
		opts.evalMethod	= 'nonMCMC';
		
end

%% Run all scripts 

SCRIPTyesno(opts)

SCRIPTcuedYesNo(opts)

SCRIPTLocalisation(opts)

SCRIPTcuedLocalisation(opts)

return