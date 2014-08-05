function cuedYesNo(T)
% cuedYesNo(1000)

tic

figure(4), clf

%% Define parameters

% Experiment 1
n=1;
expt(n).T          = T;
expt(n).set_size_list	= 2; % FIXED, single value
expt(n).dp_list			= [1 2];
expt(n).variance_list	= (1./expt(n).dp_list).^2;
%expt(n).variance_list   = 1./[4 1 0.25];
%expt(n).dp_list			= 1./sqrt(expt(n).variance_list);
expt(n).cue_validity_list= linspace(0.1,0.9,19);
%expt(n).run_type		= run_type;

% Experiment 2
n=2;
expt(n).T          = T;
expt(n).cue_validity_list    = 0.7; % FIXED, single value
expt(n).set_size_list   = [2 6];
expt(n).dp_list			= linspace(0.1,5,20);
expt(n).variance_list	= (1./expt(n).dp_list).^2;
%expt(n).variance_list   = [0.0625 0.125 0.25 0.5 1 2 4 8];
%expt(n).dp_list			= 1./sqrt(expt(n).variance_list);
%expt(n).run_type		= run_type;

% Experiment 3
n=3;
expt(n).T          = T;
expt(n).cue_validity_list = [0.5 0.7];
expt(n).set_size_list   = [2:1:9];
expt(n).variance_list	= 1; % FIXED, single value
expt(n).dp_list			= 1./sqrt(expt(n).variance_list);
%expt(n).run_type		= run_type;


%% RUN EXPERIMENTS

expt(1).results = EXPT1( expt(1) );
expt(2).results = EXPT2( expt(2) );
expt(3).results = EXPT3( expt(3) );



%% save figures
% Automatic resizing to make figure appropriate for font size
latex_fig(11, 7, 4)

codedir=cd
cd('../plots/nonMCMC')

% save as figures
figure(4), latex_fig(11, 7, 4)
hgsave('results_cued_yesno')
export_fig results_cued_yesno -pdf -png -m1

figure(1), latex_fig(10, 8, 2)
hgsave('results_cued_yesnoEXPT1')
export_fig results_cued_yesnoEXPT1 -pdf -png -m1

figure(2), latex_fig(10, 8, 2)
hgsave('results_cued_yesnoEXPT2')
export_fig results_cued_yesnoEXPT2 -pdf -png -m1

figure(3), latex_fig(10, 8, 2)
hgsave('results_cued_yesnoEXPT3')
export_fig results_cued_yesnoEXPT3 -pdf -png -m1

cd(codedir)



end








function results = EXPT1(expt)
%% EXPERIMENT 1

results = doParameterSweep(expt);

figure(1), clf
plotExperimentResults(expt, results, 'cue_validity_list', 'cue validity')

figure(4), subplot(1,3,1)
ColorSet = ColorBand(numel(expt.variance_list)); % define line colours
hold on, set(gca, 'ColorOrder', ColorSet); 
plot( expt.cue_validity_list ,...
	results.validHR-results.invalidHR,...
	'-', 'LineWidth', 2)%, 'MarkerSize', 20)
ylim([-0.6 0.6])
axis square
xlabel('cue validity')
ylabel('cuing effect')
set(gca,'XTick',[0:0.25:1])

% text for fixed parameter
fixed = sprintf(' N = %d', expt.set_size_list);
add_text_to_figure('TL',fixed, 15)

legend(num2str(expt.variance_list'))
legend('Location','SouthEast')
legend boxoff

drawnow

end



function results = EXPT2(expt)
%% EXPERIMENT 2

results = doParameterSweep(expt);

figure(2), clf
%plotExperimentResults(expt, results, 'variance_list', '\sigma ^2')
plotExperimentResults(expt, results, 'dp_list', 'd''')

figure(4), subplot(1,3,2)
ColorSet = ColorBand(numel(expt.set_size_list)); % define line colours
hold on, set(gca, 'ColorOrder', ColorSet);

plot( expt.dp_list , results.validHR-results.invalidHR,...
	'-', 'LineWidth', 2)%, 'MarkerSize', 20)
ylim([0 0.6])
axis square
xlabel('noise variance')
ylabel('cuing effect')

% text for fixed parameter
fixed = sprintf(' v = %1.1f', expt.cue_validity_list);
add_text_to_figure('TL',fixed, 15)

legend(num2str(expt.set_size_list'))
legend('Location','NorthEast')
legend boxoff

drawnow

end

function results = EXPT3(expt)
%% EXPERIMENT 3

results = doParameterSweep(expt);

figure(3), clf
plotExperimentResults(expt, results, 'set_size_list', 'N')

figure(4), subplot(1,3,3)
ColorSet = ColorBand(numel(expt.cue_validity_list)); % define line colours
hold on, set(gca, 'ColorOrder', ColorSet);
plot( expt.set_size_list , results.validHR-results.invalidHR,...
	'.-', 'LineWidth', 2, 'MarkerSize', 20)
ylim([0 0.6])
set(gca,'XTick',[2:2:10])
axis square
xlabel('set size')
ylabel('cuing effect')

% text for fixed parameter
%fixed = sprintf('variance = %1.1f', expt.variance_list);
% add_text_to_figure('TL',...
% 	sprintf('\sigma ^2 = %1.1f', expt.variance_list),...
% 	15)
add_text_to_figure('TL',[' \sigma^2 = ' num2str(expt.variance_list)], 15)

legend(num2str(expt.cue_validity_list'))
legend('Location','SouthEast')
legend boxoff

drawnow

end









function results=doParameterSweep(expt)

tic

%mcmcparams	= define_mcmcparams(expt.run_type, expt.TRIALS);
jobCount	= 1;
nJobs		= numel(expt.variance_list)*...
	numel(expt.cue_validity_list)*...
	numel(expt.set_size_list);

% start parameter sweep
for n=1:numel(expt.set_size_list)
	N = expt.set_size_list(n);
	
	for v=1:numel(expt.variance_list)
		variance = expt.variance_list(v);
		
		for cv = 1:numel(expt.cue_validity_list)
			cue_validity = expt.cue_validity_list(cv);
			
			tic
			fprintf('job %d of %d... ', jobCount, nJobs)
			
			% 			% run the main MCMC code with these parameters
			% 			[validHR(n,cv,v), invalidHR(n,cv,v)]=...
			% 				MCMCcuedYesNo(mcmcparams, N, variance, cue_validity, expt.TRIALS);
			
			sigmaT = sqrt(variance);
			sigmaD = sqrt(variance);
			
			[~, ~, ~, ~, validHR(n,cv,v), invalidHR(n,cv,v)] = ...
				cuedYesNoJob(N, sigmaT, sigmaD, expt.T, cue_validity);
			
			fprintf('%.0f simulated trials per second\n', expt.T/toc)
			
			jobCount = jobCount + 1;
		end
	end
end

% return results
% results.AUC					= squeeze(AUC);
% results.AUC_valid_present	= squeeze(AUC_valid_present);
% results.AUC_invalid_present = squeeze(AUC_invalid_present);
results.validHR				= squeeze(validHR);
results.invalidHR			= squeeze(invalidHR);

min_sec(toc);
end








function plotExperimentResults(expt, results, xVariable, xlabeltext)
%
% = getfield(expt, xVariable);
x = expt.(xVariable); % <-- use of dynamic field name

% % plot output for AUC ~~~~~~~~~~~~~~~~~~~
% subplot(2,3,1)
% plotStuff(x, results.AUC_valid_present, xlabeltext, 'AUC', 'valid')
%
% subplot(2,3,2)
% plotStuff(x, results.AUC_invalid_present, xlabeltext, 'AUC', 'invalid')
%
% subplot(2,3,3)
% plotStuff(x, results.AUC_valid_present - results.AUC_invalid_present,...
% 	xlabeltext, 'AUC', 'cueing benefit')

% plot output for hit rates ~~~~~~~~~~~~~~~~~~~
subplot(1,3,1)
plotStuff(x, results.validHR, xlabeltext, 'HR', 'valid-cue trials')

subplot(1,3,2)
plotStuff(x, results.invalidHR, xlabeltext, 'HR', 'invalid-cue trials')

subplot(1,3,3)
plotStuff(x, results.validHR-results.invalidHR,...
	xlabeltext, 'cuing effect (HR_{valid}-HR_{invalid})', '')

drawnow

	function plotStuff(x, y, xlabeltext, ylabeltext, titleText)
		hold all, %set(gca, 'ColorOrder', ColorSet);
		plot( x , y, '.-',...
			'LineWidth', 2, 'MarkerSize', 20)
		xlabel(xlabeltext), ylabel(ylabeltext)
		title(titleText)
		axis square
		
		% append info
		dt = datestr(now,'yyyy mmm dd, HH:MM AM');
		bordertext('figurebottomright', [mfilename ' ' dt]);
	end

end











function [PC, HR, FAR, AUC, validHR, invalidHR] = cuedYesNoJob(N, sigmaT, sigmaD, T, cueValidity)

uniformDist = ones(1,N)/N;				% prior over cue location
prev=0.5;
% dPrior([1:N]) = uniformDist*prev; % prior over each present location
% dPrior(N+1) = (1-prev); % prior for target absent

xMu = eye(N+1);							% deterministic p(xmu|D)
xMu = xMu(:,1:N);

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
	
	%% GENERATIVE
	c = mnrnd(1,uniformDist);			% sample cue location
	
	% define the prior over display types as a function of cue location
	dPrior(N+1) = (1-prev);
	dPrior(c==1) = prev*cueValidity;
	dPrior(c==0) = (prev*(1-cueValidity))/(N-1);
	
	d = mnrnd(1,dPrior);				% sample display type
	
	sigma(d([1:N])==1)= sigmaT;				% sigma for targets
	sigma(d([1:N])==0)= sigmaD;				% sigma for distractors.
	
	x = normrnd(d([1:N]),sigma);		% sample noisy observation
	
	
	
	%% INFERENCE, now we know x
	for n=1:N+1
		% log likelihood of each value of D
		%LLd(n) = sum( log( normpdf(x, xMu(n,:), sigma) ));
		% Likelihood
		Ld(n) = prod( normpdf(x, xMu(n,:), sigma) );
	end
	%logPosteriorD = LLd + log(dPrior);	% posterior
	
	PosteriorD = Ld .* dPrior;	% posterior
	% normalise
	PosteriorD = PosteriorD./sum(PosteriorD);
	
	%% DECISION
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
