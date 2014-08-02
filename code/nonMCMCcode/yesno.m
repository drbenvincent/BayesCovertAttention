function PC = yesno(T)
% yesno(1000)

tic

figure(1), clf


%% EXPERIMENT 1 - ROC curves for multiple noise leves
N = [2];
variance_list = [0.25 1 4];
sigma_list = sqrt(variance_list);

for stdev = 1:numel(sigma_list)
	sigma = sigma_list(stdev);
	
	% CALCULATE PERFORMANCE FOR THESE PARAMETER VALUES ------------
	[PC(stdev), HR(:,stdev), FAR(:,stdev), AUC(stdev)] = ...
		yesnoPC(N, sigma, sigma, T);
	% -------------------------------------------------------------
	
end

% Plot the results

ColorSet = ColorBand(numel(variance_list)); % define line colours

figure(1)
subplot(1,3,1)
hold all 
set(gca, 'ColorOrder', ColorSet); 
plot(FAR,HR)
format_axis_ROC
legend('4, 1', '1, 4')
legend(num2str(variance_list'),...
	'location','SouthEast')
legend boxoff
title('Target/Distracter similarity','FontSize',16)




%% EXPERIMENT 2 - set size effects, for multiple noise levels
clear PC HR FAR AUC
size_sizes = [2 4 8 16];
variance_list = [0.25 1 4];
sigma_list = sqrt(variance_list);

% Run through all simulations
for ss = 1:numel(size_sizes)
	N = size_sizes(ss);
	
	for stdev = 1:numel(sigma_list)
		sigma = sigma_list(stdev);
		
		% CALCULATE PERFORMANCE FOR THESE PARAMETER VALUES ------------
		[PC(ss,stdev), ~, ~, AUC(ss,stdev)] = ...
			yesnoPC(N, sigma, sigma, T);
		% -------------------------------------------------------------
		
	end
	
end

% Plot the results
figure(1)
subplot(1,3,2)
hold all 
set(gca, 'ColorOrder', ColorSet); 
plot(size_sizes,AUC,'.-',...
    'MarkerSize', 30)
axis square

title('Set size effects','FontSize',16)
xlabel('set size')
ylabel('AUC')

axis([1 max(size_sizes) 0.5 1])
set(gca,'XTick',size_sizes)

legend(num2str(variance_list'),...
	'location','NorthEast')
legend boxoff




%% EXPERIMENT 3 - search assymmetry
clear PC HR FAR AUC
N = [2];

% CALCULATE PERFORMANCE FOR THESE PARAMETER VALUES ------------
[AB_PC, AB_HR, AB_FAR, AB_AUC] = yesnoPC(N, sqrt(4), sqrt(1), T);
[BA_PC, BA_HR, BA_FAR, BA_AUC] = yesnoPC(N, sqrt(1), sqrt(4), T);
% -------------------------------------------------------------

% Plot the results
figure(1)
subplot(1,3,3)
title('Search asymmetry','FontSize',16)
plot(AB_FAR,AB_HR,'k')
hold on
plot(BA_FAR,BA_HR,'k:')
format_axis_ROC
legend('\sigma^2_T = 4, \sigma^2_D = 1',...
    '\sigma^2_T = 1, \sigma^2_D = 4',...
    'location','SouthEast')
legend boxoff


min_sec(toc);

latex_fig(11, 7, 4)

end


function [PC, HR, FAR, AUC] = yesnoPC(N, sigmaT, sigmaD, T)

uniformDist = ones(1,N)/N;	
prev=0.5;
dPrior([1:N]) = uniformDist*prev; % prior over each present location
dPrior(N+1) = (1-prev); % prior for target absent

xMu = eye(N+1);							% deterministic p(xmu|D)
xMu = xMu(:,1:N);
correct = 0;							% initialse number of correct trials

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
		LLd(n) = sum( log( normpdf(x, xMu(n,:), sigma) ));
	end
	logPosteriorD = LLd + log(dPrior);	% posterior
	
	%% DECISION
	response = argmax(logPosteriorD);
	response = response <= N;

 	D=argmax(d);
 	actual = D<=N;
	if response==actual
		correct = correct + 1;
	end
	
	% convert into a normalised probability
	postD=exp(logPosteriorD);
	postD=postD./sum(postD);
	
	pPresent(t) = sum(postD([1:N]));
	signalTrial(t) = actual;
	
end
PC = correct/T;

S = pPresent(signalTrial==1);
N = pPresent(signalTrial==0);
[HR, FAR, AUC]=ROC_calcHRandFAR_VECTORIZED(N,S);
end
