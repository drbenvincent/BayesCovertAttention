% runAll


opts.trials			= 100;

% options for non-MCMC evaluation
opts.evalMethod		= 'nonMCMC';

% options for evaluating with MCMC. This is much slower.
%opts.evalMethod	= 'MCMC';		opts.run_type='testing';





SCRIPTyesno(opts)

SCRIPTcuedYesNo(opts)

SCRIPTLocalisation(opts)

SCRIPTcuedLocalisation(opts)