function PC = cuedLocalisation(T)
% PC = cuedLocalisation(1000)

tic

%% set up variables for all simulations
set_size_list = [2 4];
sigma_list = [0.5 1 2];
cueValidityList = linspace(0,1,21);

%% Run through all simulations
for ss = 1:numel(set_size_list)
	N = set_size_list(ss);
	
	for stdev = 1:numel(sigma_list)
		sigma = sigma_list(stdev);
		
		for v = 1:numel(cueValidityList)
			expec = cueValidityList(v);
			% CALCULATE PERFORMANCE FOR THESE PARAMETER VALUES ------------
			PC(ss,stdev,v) = cuedLocalisationPC(N, sigma, T, expec);
			% -------------------------------------------------------------
		end
	end
	
	% plot results for this set size
	subplot(1, numel(set_size_list),ss)
	plot(cueValidityList, squeeze(PC(ss,:,:))',...
		'k-')
	drawnow	
end

min_sec(toc);

end


function PC = cuedLocalisationPC(N, sigma, T, cueValidity)

uniformDist = ones(1,N)/N;				% prior over cue location
xMu = eye(N);							% deterministic p(xmu|D)
correct = 0;							% initialse number of correct trials

for t=1:T
	
	%% GENERATIVE MODEL: simulate noisy observations
	c = mnrnd(1,uniformDist);			% sample cue location
	
	% define the prior over display types as a function of cue location
	dPrior(c==1) = cueValidity;
	dPrior(c==0) = (1-cueValidity)/(N-1);
	
	d = mnrnd(1,dPrior);				% sample display type
	x = normrnd(d,sigma);				% sample noisy observation
	
	%% INFERENCE: what is an optimal observer's response?
	for n=1:N
		% log probability of each display type
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
