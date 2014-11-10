
function [PC, HR, FAR, AUC] = evaluateYesNo(opts, N, varT, varD, prev)

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
	
	%% STEP 1: GENERATIVE
	d = mnrnd(1,dPrior);				% sample display type
	
	sigma(d([1:N])==1)= sigmaT;				% sigma for targets
	sigma(d([1:N])==0)= sigmaD;				% sigma for distractors.
	
	x = normrnd(d([1:N]),sigma);		% sample noisy observation

	%% STEP 2: INFERENCE, now we know x
	% The observer is calculating the joint probability of P(D,x,sigmaT,sigmaD,dprior)
	% It will do this by evaluating the joint probability over all N+1
	% categorical values of D (display type)
	
	for dparam=1:N+1 % loop over each possible display type 
		Ld(dparam) = prod( normpdf(x, xMu(dparam,:), sigmaTable(dparam,:)) );
	end
	
	PosteriorD = Ld .* dPrior;					% posterior
	PosteriorD = PosteriorD./sum(PosteriorD);	% normalise
	
	%% STEP 3: DECISION
	pPresent(t) = sum(PosteriorD([1:N]));
		
	if pPresent(t)>=0.5
		response=1;
	else
		response=0;
	end
  	
	D=argmax(d);		% what is the actual display type
  	actual = D<=N;		% is the display type present (1) or absent (0)
	if response==actual
		correct = correct + 1;
	end
		
	% binary label of whether this is a signal trial
	signalTrial(t) = actual;

	%D=argmax(d);
 	
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
