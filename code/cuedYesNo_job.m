%% Sub-function: predictions for a given set size, |N|

function cuedYesNo_job(mcmcparams, N, TRIALS, cue_validity_list, variance_list, subfig)

dprime				= 1./variance_list;

%%
% Loop over a range of cue validities and $d'$ values and compute the
% proportion correct (|PC|) with the function |MCMClocalisation.m|.
% pre-allocate arrays

jobcount = 1;
for v=1:numel(variance_list)
	variance = variance_list(v);
	
	for cv = 1:numel(cue_validity_list)
		cue_validity = cue_validity_list(cv);
		
		fprintf('job %d of %d: %s\n', jobcount,...
			numel(variance_list)*numel(cue_validity_list), datestr(now) )
		% run the main MCMC code with these parameters
		[AUC(cv,v), AUC_valid_present(cv,v), AUC_invalid_present(cv,v)]=...
			MCMCcuedYesNo(mcmcparams, N, variance, cue_validity, TRIALS);
		jobcount = jobcount + 1;
	end
end

%%

ColorSet = ColorBand(numel(variance_list)); % define line colours

subplot(1,3,1)
hold all, set(gca, 'ColorOrder', ColorSet); 
plot( cue_validity_list.*100 , AUC, '.-', 'LineWidth', 2, 'MarkerSize', 20)
ylim([0.5 1])
xlabel('cue validity'), ylabel('AUC')
title('present/absent')

subplot(1,3,2)
hold on, set(gca, 'ColorOrder', ColorSet); 
plot( cue_validity_list.*100 , AUC_valid_present, '.-', 'LineWidth', 2, 'MarkerSize', 20)
ylim([0.5 1])
xlabel('cue validity')
title('valid/present')

subplot(1,3,3)
hold on, set(gca, 'ColorOrder', ColorSet); 
plot( cue_validity_list.*100 , AUC_invalid_present, '.-', 'LineWidth', 2, 'MarkerSize', 20)
ylim([0.5 1])
xlabel('cue validity')
title('invalid/present')

drawnow
%%
% Plot the results
% figure
% 
% ColorSet = ColorBand(numel(variance_list)); % define line colours
% 
% subplot(1,2,subfig)
% hold on, set(gca, 'ColorOrder', ColorSet); 
% plot( cue_validity_list.*100 , AUC, '.-k',...
%     'LineWidth', 2, 'MarkerSize', 20)
% hline(0.5) % AUC=0.5 is chance
% ylim([0 1])
% xlabel('cue validity')
% ylabel('AUC')
% set(gca,'XTick',[0:25:100])
% box off
% axis square
% % legend(num2str(dprime'),...
% % 	'location','SouthEast')
% % legend boxoff
% title(['set size = ' num2str(N)],'FontSize',16)
% drawnow


return