% runAll

close all


% options for non-MCMC evaluation
opts.trials			= 10000;
opts.evalMethod		= 'nonMCMC';

% options for evaluating with MCMC. This is much slower.
%opts.trials		= 1000;
%opts.evalMethod	= 'MCMC';		opts.run_type='testing';





SCRIPTyesno(opts)

SCRIPTcuedYesNo(opts)

SCRIPTLocalisation(opts)

SCRIPTcuedLocalisation(opts)