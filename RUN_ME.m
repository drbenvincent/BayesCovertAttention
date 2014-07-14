% PublishAll

% %% set up directories
% dirs.root = cd;
% 
% % move into code directory
% cd('code')
% 
% 
% run_type = 'publication'; % ['testing'|'publication']
% 
% close all, drawnow
% % Run models without publishing
% SCRIPTLocalisation(run_type)
% SCRIPTcuedLocalisation(run_type)
% SCRIPTdetection(run_type)
% 
% cd('..')



%%

% initiate use of multiple cores
matlabpool open

cd('code')

% Localisation
publishdepfun('SCRIPTLocalisation',[],...
    {},...
    {'min_sec','hline','export_fig','latex_fig'})

% Cued localisation
publishdepfun('SCRIPTcuedLocalisation',[],...
    {},...
    {'min_sec','export_fig','latex_fig'})

% Detection
publishdepfun('SCRIPTdetection',[],...
    {'ROC_calcHRandFAR_VECTORIZED'},...
    {'min_sec','export_fig','format_axis_ROC','latex_fig'})

cd('..')