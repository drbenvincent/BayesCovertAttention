%% Sub-function: predictions for a given set size, |N|

function localisation_job(mcmcparams, N, TRIALS, sp_list, variance_list, subfig)

dprime				= 1./variance_list;

%%
% Loop over a range of cue validities and $d'$ values and compute the
% proportion correct (|PC|) with the function |MCMClocalisation.m|.
jobcount = 1;
for v=1:numel(variance_list)
	variance = variance_list(v);
	
	for s = 1:numel(sp_list)
		sp = sp_list(s);
		
		fprintf('job %d of %d: %s\n', jobcount,...
			numel(variance_list)*numel(sp_list), datestr(now) )
        
        % create the spatial prior distribution
        spdist = [sp , ones(1,N-1).*(1-sp)./(N-1)];
		% run the main MCMClocalisation code with these parameters
		PC(s,v) = MCMClocalisation(mcmcparams,N, spdist, variance, TRIALS);
		
		jobcount = jobcount + 1;
	end
end

%%
% Plot the results
figure(1)
subplot(1,2,subfig)
plot( sp_list.*100 , PC, '-o','LineWidth',6)
hline(1/N)

% formatting
set(gca,'PlotBoxAspectRatio',[1 1 1],...
    'box', 'off',...
    'xlim', [0 100],...
    'ylim', [0 1],...
	'XTick',[0:25:100],...
    'YTick',[0:0.25:1])
xlabel('expectation (%)')
ylabel('proportion correct')
title(['N=' num2str(N)],'FontSize',16)
legend(num2str(dprime'),...
	'location','SouthEast')
axis square

drawnow






return