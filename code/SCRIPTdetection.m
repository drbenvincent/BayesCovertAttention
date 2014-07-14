%% SCRIPTdetection
% This script calculates the predictions for a number of attentional
% effects for the yes/no detection task.
% All of these experimental results are a by-product of conducting inference
% about the state of the world (display type, $L$) given noisy sensory
% observations $x$, and knowledge of the causal structure of the detection
% task (see graphical model below) and the internal observation uncertainty
% associated with targets ($\sigma^2_T$) and distractors ($\sigma^2_D$).
%
% <<BGMdetection.png>>
%
%%


%function SCRIPTdetection(run_type)
%% Preliminaries
clear, close all; clc
run_type = 'testing'; % ['testing'|'publication']
T1=clock;

%% Define parameters
% Select parameters to use based on if we are quick testing (faster
% computation times) or final runs (will take a while to compute).

switch run_type
    case{'testing'}
        TRIALS              = 100;
        list_of_variances   = 1./[4 1 0.25];
        dprime              = 1./list_of_variances;
        size_sizes          = [2 4 8];
        external_noise_variance_list = [0.5 1 2 4 8];
    case{'publication'}
        TRIALS              = 5000;
        %list_of_variances   = 1./[8 4 2 1 0.5 0.25 0.125];
		list_of_variances   = 1./[4 1 0.25];
        dprime              = 1./list_of_variances;
        size_sizes          = [2 4 8 16];
        external_noise_variance_list = [0.5 1 2 4 8];
end


%% Calculate ROC curves over a range of different internal noise levels
N = 2;
for n=1:numel(list_of_variances)
	% Grab the parameter value we are looking at
	variance				= list_of_variances(n);
	% Run the main MCMCdetection code given these parameter values
	fprintf('job %d of %d: %s\n', n, numel(list_of_variances), datestr(now) )
	[~, FAR(:,n), HR(:,n)]	= MCMCdetection(N, variance,variance, TRIALS);
end

%%
% Plot the results
figure(1)
subplot(1,3,1)
plot(FAR,HR)
format_axis_ROC
% Axis properties
set(gca, ...
  'XTick'       , 0:0.25:1	, ...
  'YTick'       , 0:0.25:1);
legend('4, 1', '1, 4')
legend(num2str(dprime'),...
	'location','SouthEast')
title('Target/Distracter similarity','FontSize',16)






%% Calculate AUC for a range of set sizes and internal noise levels

%%
% preallocate matrix for AUC values
AUC=zeros(numel(size_sizes),numel(list_of_variances));
%%
% loop over the parameters, and run the MCMC detection code
job =1;
jobs = numel(size_sizes) * numel(list_of_variances);
for s=1:numel(size_sizes)
	for v=1:numel(list_of_variances)
        fprintf('job %d of %d: %s\n', job, jobs, datestr(now) )
		% pull out the parameters we are dealing with now
		N					= size_sizes(s);
		variance			= list_of_variances(v);
		[AUC(s,v), ~, ~]	= MCMCdetection(N, variance, variance, TRIALS);
        job=job+1;
	end
end

%%
% Plot the results
figure(1)
subplot(1,3,2)
plot(size_sizes,AUC,'-o')
xlabel('set size')
ylabel('AUC')
axis square
axis([1 max(size_sizes) 0.5 1])
set(gca,'XTick',size_sizes)
box off
legend(num2str(dprime'),...
	'location','SouthEast')
title('Set size effects','FontSize',16)






%% Search asymmetry

N=4;
% Define variance of item A and B
varA = 4;
varB = 1;

%%
% Search for A amongst B
varTarget       = varA; 
varDistracter   = varB;
[AB_AUC, AB_FAR, AB_HR] = MCMCdetection(N, varTarget, varDistracter, TRIALS);

%%
% Search for B amongst A
varTarget       = varB; 
varDistracter   = varA;
[BA_AUC, BA_FAR, BA_HR] = MCMCdetection(N, varTarget, varDistracter, TRIALS);

%%
% Plot the results
figure(1)
subplot(1,3,3)
plot(AB_FAR,AB_HR,'k')
hold on
plot(BA_FAR,BA_HR,'k--')
format_axis_ROC
% Axis properties
set(gca, ...
  'XTick'       , 0:0.25:1	, ...
  'YTick'       , 0:0.25:1);
legend('4, 1', '1, 4')
title('Search asymmetry','FontSize',16)





%%


% %% External noise -- THIS IS INCORRECT!!! We need variance on the actual stimulus
% % Calculate AUC as a function of increasing distracter noise
% N = 2;
% varTarget = 1;
% clear AUC
% for n=1:numel(external_noise_variance_list)
% 	% Grab the parameter value we are looking at
% 	varDistracter		= external_noise_variance_list(n);
% 	% Run the main MCMCdetection code given these parameter values
% 	fprintf('job %d of %d: %s', n, numel(list_of_variances), datestr(now) )
% 	[AUC(n), ~, ~]	= MCMCdetection(N, varTarget,varDistracter, TRIALS);
% end
% 
% %%
% % Plot the results
% figure(1)
% subplot(2,2,4)
% plot(external_noise_variance_list,AUC,'-o')
% title('INCORRECT','FontSize',16)
% xlabel('Distracter')








%% Export the figure 

% Automatic resizing to make figure appropriate for font size
% Download from here http://www.mathworks.com/matlabcentral/fileexchange/36439-resizing-matlab-plots-for-publication-purposes-latex
latex_fig(11, 7, 4)

% save as a .fig file
codedir=cd;
switch run_type
	case{'testing'}
		cd('../plots/testing')
	case{'publication'}
		cd('../plots')
end
hgsave('results_detection')
cd(codedir)


%%
% If you download <http://www.mathworks.co.uk/matlabcentral/fileexchange/23629-exportfig export_fig.m>
% from Mathworks File Exchange, then the following command can be used for 
% publication quality figure export:
codedir=cd;
switch run_type
	case{'testing'}
		cd('../plots/testing')
	case{'publication'}
		cd('../plots')
end
export_fig results_detection -png -pdf -m1
cd(codedir)

%% report time taken doing job
T2=clock;
etime(T2,T1)	% time in seconds
etime(T2,T1)/60 % time in mins
min_sec(etime(T2,T1));