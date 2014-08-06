function yesno(T)
% yesno(1000)

tic

figure(1), clf


%% EXPERIMENT 1 - ROC curves for multiple noise leves
display('Experiment 1')
N = [2];
variance_list = [0.25 1 4];
sigma_list = sqrt(variance_list);
prev=0.5;

for stdev = 1:numel(sigma_list)
	sigma = sigma_list(stdev);
	
	% CALCULATE PERFORMANCE FOR THESE PARAMETER VALUES ------------
	[PC(stdev), HR(:,stdev), FAR(:,stdev), AUC(stdev)] = ...
		yesnoJOB(N, sigma, sigma, T, prev);
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
display('Experiment 2')
clear PC HR FAR AUC prev
size_sizes = [2 4 8 16];
variance_list = [0.25 1 4];
sigma_list = sqrt(variance_list);
prev=0.5;

% Run through all simulations
for ss = 1:numel(size_sizes)
	N = size_sizes(ss);
	
	for stdev = 1:numel(sigma_list)
		sigma = sigma_list(stdev);
		
		% CALCULATE PERFORMANCE FOR THESE PARAMETER VALUES ------------
		[PC(ss,stdev), ~, ~, AUC(ss,stdev)] = ...
			yesnoJOB(N, sigma, sigma, T, prev);
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
display('Experiment 3')
clear PC HR FAR AUC prev
N = 4;
prev=0.5;
varianceA = 4; sigmaA=sqrt(varianceA);
varianceB = 1; sigmaB=sqrt(varianceB);
% CALCULATE PERFORMANCE FOR THESE PARAMETER VALUES ------------
[AB_PC, AB_HR, AB_FAR, AB_AUC] = yesnoJOB(N, sigmaA, sigmaB, T, prev);
[BA_PC, BA_HR, BA_FAR, BA_AUC] = yesnoJOB(N, sigmaB, sigmaA, T, prev);
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

display('Saving')
codedir=cd;
cd('../plots/nonMCMC')

latex_fig(11, 7, 4)
hgsave('results_yesno')
export_fig results_yesno -pdf -png -m1

cd(codedir)


end

