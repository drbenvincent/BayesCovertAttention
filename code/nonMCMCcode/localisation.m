function PC = localisation(T)
% PC = localisation(1000)
%
% figure(1), clf, localisation(1000); cuedLocalisation(1000); export_fig results_localisation -png -pdf -m1

tic


%% set up variables for all simulations
set_size_list = [2 4];
sigma_list = [0.5 1 2];
expectation_list = linspace(0,1,21);

%% Run through all simulations
for ss = 1:numel(set_size_list)
	N = set_size_list(ss);
	
	for stdev = 1:numel(sigma_list)
		sigma = sigma_list(stdev);
		
		for ex = 1:numel(expectation_list)
			expec = expectation_list(ex);
			
			% CALCULATE PERFORMANCE FOR THESE PARAMETER VALUES ------------
			PC(ss,stdev,ex) = localisationPC(N, sigma, T, expec);
			% -------------------------------------------------------------
			
		end
	end
	
	% plot results for this set size
	subplot(1, numel(set_size_list),ss)
	plot(expectation_list, squeeze(PC(ss,:,:))',...
		'LineWidth',10)
	title(sprintf('N = %d', N))
	ylim([0 1])
	hline(1/N)
	box off
	hold on
	drawnow
	
end


min_sec(toc);

end


function PC = localisationPC(N, sigma, T, expec)

dPrior(1) = expec;						% prob of target in location 1
dPrior([2:N]) = (1-expec)/(N-1);		% prob of target elsewhere

xMu = eye(N);							% deterministic p(xmu|D)
correct = 0;							% initialse number of correct trials

for t=1:T
	
	%% GENERATIVE
	d = mnrnd(1,dPrior);				% sample display type
	x = normrnd(d,sigma);				% sample noisy observation
	
	%% INFERENCE, now we know x
	for n=1:N
		% log likelihood of each value of D
		LLd(n) = sum( log( normpdf(x, xMu(n,:), sigma) ));
	end
	logPosteriorD = LLd + log(dPrior);	% posterior
	
	%% DECISION
	response = argmax(logPosteriorD);
	if response == argmax(d)
		correct = correct + 1;
	end
end
PC = sum(correct)/T;
end
