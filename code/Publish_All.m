%% Publish_All
% This function will publish the code to .html format



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


clear options
options.createThumbnail = false;
options.outputDir = [cd '/html/'];
options.evalCode = false;
options.format = 'html';



% add paths to dependencies
addpath([cd '/funcs/Publish_Called_functions'])



%% Localisation
publishdepfun('SCRIPTLocalisation',options,...
    {},...
    {'min_sec','hline','export_fig','latex_fig'})

%% Cued localisation
publishdepfun('SCRIPTcuedLocalisation',options,...
    {},...
    {'min_sec','export_fig','latex_fig'})

%% Detection
publishdepfun('SCRIPTdetection',options,...
    {'ROC_calcHRandFAR_VECTORIZED'},...
    {'min_sec','export_fig','format_axis_ROC','latex_fig'})
