
function [PC, HR, FAR, AUC] = yesnoJOB(opts, N, varT, varD, prev)

T = opts.trials;

uniformDist = ones(1,N)/N;	

dPrior([1:N]) = uniformDist*prev; % prior over each present location
dPrior(N+1) = (1-prev); % prior for target absent

xMu = eye(N+1);							% deterministic p(xmu|D)
xMu = xMu(:,1:N);
correct = 0;							% initialse number of correct trials

% work with std, not var
sigmaT = sqrt(varT);
sigmaD = sqrt(varD);

sigmaTable(xMu==1) = sigmaT;
sigmaTable(xMu==0) = sigmaD;
sigmaTable=reshape(sigmaTable,size(xMu));

pPresent = zeros(T,1); % preallocate
signalTrial = zeros(T,1); % preallocate

for t=1:T
	
	%% GENERATIVE
	d = mnrnd(1,dPrior);				% sample display type
	
	sigma(d([1:N])==1)= sigmaT;				% sigma for targets
	sigma(d([1:N])==0)= sigmaD;				% sigma for distractors.
	
	x = normrnd(d([1:N]),sigma);		% sample noisy observation
	

	
	%% INFERENCE, now we know x
	for n=1:N+1
		% log likelihood of each value of D
		%LLd(n) = sum( log( normpdf(x, xMu(n,:), sigma) ));
	
		
		%Ld(n) = prod( normpdf(x, xMu(n,:), sigma) ); % <---- old wrong line
		
		
		
		% *** PROBLEM FOUND *** 
		% The observer does not actually know the sigma of each location
		% because it doesn't KNOW where the target is. Therefore I think
		% this approach is not doable. It may well be, but we'd have to
		% integrate over
		
		% new
		Ld(n) = prod( normpdf(x, xMu(n,:), sigmaTable(n,:)) );
	end
	%logPosteriorD = LLd + log(dPrior);	% posterior
	
	PosteriorD = Ld .* dPrior;					% posterior
	PosteriorD = PosteriorD./sum(PosteriorD);	% normalise
	
	%% DECISION
	pPresent(t) = sum(PosteriorD([1:N]));
		
	if pPresent(t)>=0.5
		response=1;
	else
		response=0;
	end
% 	response = argmax(PosteriorD);
% 	response = response <= N;
% 
  	
	D=argmax(d);		% what is the actual display type
  	actual = D<=N;		% is the display type present (1) or absent (0)
	if response==actual
		correct = correct + 1;
	end
	

	
	%actual = D<=N;
	signalTrial(t) = actual;
	
	
	D=argmax(d);
 	
	if response==actual
		correct = correct + 1;
	end
	
	
end
PC = correct/T;

S = pPresent(signalTrial==1);
N = pPresent(signalTrial==0);
[HR, FAR, AUC]=ROC_calcHRandFAR_VECTORIZED(N,S);

%figure(5), clf, hist_compare(S,N,100), drawnow

end
