
function PC = evaluateCuedLocalisation(N, sigma, T, cueValidity)

uniformDist = ones(1,N)/N;				% prior over cue location
xMu = eye(N);							% deterministic p(xmu|D)
correct = 0;							% initialse number of correct trials

for t=1:T
	
	%% STEP 1: GENERATIVE MODEL: simulate noisy observations
	c = mnrnd(1,uniformDist);			% sample cue location
	
	% define the prior over display types as a function of cue location
	dPrior(c==1) = cueValidity;
	dPrior(c==0) = (1-cueValidity)/(N-1);
	
	d = mnrnd(1,dPrior);				% sample display type
	x = normrnd(d,sigma);				% sample noisy observation
	
	%% STEP 2: INFERENCE: what is an optimal observer's response?
	% The observer is calculating the joint probability of P(D,c,v,x,sigma,dprior)
	% It will do this by evaluating the joint probability over all N
	% categorical values of D (display type)
	for dparam=1:N
		% log probability of each display type
		LLd(ndparam) = sum( log( normpdf(x, xMu(dparam,:), sigma) ));
	end
	logPosteriorD = LLd + log(dPrior);	% posterior
	
	%% STEP 3: DECISION
	response = argmax(logPosteriorD);
	if response == argmax(d)
		correct = correct + 1;
	end
end
PC = correct/T;
end