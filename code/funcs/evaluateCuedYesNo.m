function [PC, HR, FAR, AUC, validHR, invalidHR] = evaluateCuedYesNo(opts, N, sigmaT, sigmaD, cueValidity)

T = opts.trials;

uniformDist = ones(1,N)/N;				% prior over cue location
prev=0.5;
% dPrior([1:N]) = uniformDist*prev; % prior over each present location
% dPrior(N+1) = (1-prev); % prior for target absent

xMu = eye(N+1);							% deterministic p(xmu|D)
xMu = xMu(:,1:N);

sigmaTable(xMu==1) = sigmaT;
sigmaTable(xMu==0) = sigmaD;
sigmaTable=reshape(sigmaTable,size(xMu));


correct = 0;							% initialse number of correct trials
pPresent = zeros(T,1); % preallocate
signalTrial = zeros(T,1); % preallocate

nValidHits = 0;
nValidPresent = 0;
nInvalidHits = 0;
nInvalidPresent = 0;

% predefine 
dPrior	= zeros(1,N+1);
LLd		= zeros(1,N+1);

for t=1:T
	
	%% STEP 1: GENERATIVE
	c = mnrnd(1,uniformDist);			% sample cue location
	
	% define the prior over display types as a function of cue location
	dPrior(N+1) = (1-prev);
	dPrior(c==1) = prev*cueValidity;
	dPrior(c==0) = (prev*(1-cueValidity))/(N-1);
	
	d = mnrnd(1,dPrior);				% sample display type
	
	sigma(d([1:N])==1)= sigmaT;				% sigma for targets
	sigma(d([1:N])==0)= sigmaD;				% sigma for distractors.
	
	x = normrnd(d([1:N]),sigma);		% sample noisy observation
	
	
	
	%% STEP 2: INFERENCE, now we know x
	for n=1:N+1
		% log likelihood of each value of D
		%LLd(n) = sum( log( normpdf(x, xMu(n,:), sigma) ));
		% Likelihood
		%Ld(n) = prod( normpdf(x, xMu(n,:), sigma) );
		
		% new
		Ld(n) = prod( normpdf(x, xMu(n,:), sigmaTable(n,:)) );

	end
	%logPosteriorD = LLd + log(dPrior);	% posterior
	
	PosteriorD = Ld .* dPrior;	% posterior
	% normalise
	PosteriorD = PosteriorD./sum(PosteriorD);
	
	%% STEP 3: DECISION
	% 	response = argmax(logPosteriorD);
	% 	response = response <= N;
	
	% response
	posterior_mode = argmax(PosteriorD);
	if posterior_mode == N+1
		response=0; % absent
	else
		response=1; % present
	end
	
	%[response] = YesNoDecisionRule(logPosteriorD, N);

	% WAS THE RESPONSE CORRECT?
	D=argmax(d);
	actual = D<=N;
	if response==actual
		correct = correct + 1;
	end
	

	% This is the decision variable
	pPresent(t) = sum(PosteriorD([1:N]));
	signalTrial(t) = actual;
	
	% Is this a target-present, valid-cue trial?
	if D<=N && argmax(c)==D
		nValidPresent = nValidPresent+1;
		% did the observer also get it right? A hit.
		if response==1
			nValidHits = nValidHits+1;
		end
	end
	
	% Is this a target-present, INvalud-cue trial?
	if D<=N && argmax(c)~=D
		nInvalidPresent = nInvalidPresent+1;
		% did the observer also get it right? A hit.
		if response==1
			nInvalidHits = nInvalidHits+1;
		end
	end
	
	
end
PC = correct/T;

S = pPresent(signalTrial==1);
N = pPresent(signalTrial==0);
[HR, FAR, AUC]=ROC_calcHRandFAR_VECTORIZED(N,S);

validHR		= nValidHits / nValidPresent;
invalidHR	= nInvalidHits / nInvalidPresent;
end