% runNonMCMCcode

% This script runs the non-MCMC implementation. It is significantly faster.


%% Initial set up
close all, clc
addpath([cd '/funcs'])
addpath([cd '/nonMCMCcode'])
addpath([cd '/funcs/hline_vline'])
addpath([cd '/funcs/export_fig'])
addpath([cd '/funcs/latex_fig'])
addpath([cd '/funcs/ColorBand'])
plot_formatting_setup

T = 50000;



%% Produce figure for localisation and cued-localisation
figure(1), clf

% ~~~~~~~~~
localisation(T); 
cuedLocalisation(T); 
% ~~~~~~~~~

% Automatic resizing to make figure appropriate for font size
latex_fig(11, 7, 4)
% save as a .fig file
codedir=cd;
cd('../plots/nonMCMC')
% save as a .fig file
hgsave('results_localisation')
% save as a .pdf and png file
export_fig results_localisation -png -pdf -m1
cd(codedir)


%% Non-cued yes/no task

% ~~~~~~~~~
yesno(T)
% ~~~~~~~~~

latex_fig(11, 7, 4)
% save as a .fig file
codedir=cd;
cd('../plots/nonMCMC')
% save as a .fig file
hgsave('results_detection')
% save as a .pdf and png file
export_fig results_detection -png -pdf -m1
cd(codedir)
