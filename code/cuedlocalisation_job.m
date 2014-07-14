%% Sub-function: predictions for a given set size, |N|

function cuedlocalisation_job(mcmcparams, N, TRIALS, cue_validity_list, variance_list, subfig)

dprime				= 1./variance_list;

%%
% Loop over a range of cue validities and $d'$ values and compute the
% proportion correct (|PC|) with the function |MCMClocalisation.m|.
jobcount = 1;
for v=1:numel(variance_list)
	variance = variance_list(v);
	
	for cv = 1:numel(cue_validity_list)
		cue_validity = cue_validity_list(cv);
		
		fprintf('job %d of %d: %s\n', jobcount,...
			numel(variance_list)*numel(cue_validity_list), datestr(now) )
		% run the main MCMClocalisation code with these parameters
		PC(cv,v) = MCMCcuedLocalisation(mcmcparams, N, variance, cue_validity, TRIALS);
		
		jobcount = jobcount + 1;
	end
end

%%
% Plot the results
figure(1)

subplot(1,2,subfig)
hold on
plot( cue_validity_list.*100 , PC, 'k-o','LineWidth',2)
hline(1/N)
ylim([0 1])
xlabel('expectation (%)')
ylabel('percent correct')
set(gca,'XTick',[0:25:100])
box off
axis square
legend(num2str(dprime'),...
	'location','SouthEast')
title(['N=' num2str(N)],'FontSize',16)
drawnow


return