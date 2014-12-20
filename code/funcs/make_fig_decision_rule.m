% make_fig_decision_rule


close all; clc
% add paths to dependencies
addpath([cd '/funcs'])
addpath([cd '/funcs/export_fig'])
addpath([cd '/funcs/latex_fig'])
addpath([cd '/funcs/ColorBand'])
addpath([cd '/funcs/hline_vline'])
%addpath([cd '/funcs/bordertext'])
addpath([cd '/funcs/bens_helper_functions'])
addpath([cd '/funcs/legendflex'])
plot_formatting_setup


N=4;
colormap(gray)

%% localisation
s(1) = subplot(1,2,1)
d=rand(N,1); d=d./sum(d);
h(1) = bar([1:N],d)
title('localisation')
ylabel('posterior')

xlabel('display type (D)')
xlim([0.5 N+0.5])
ylim([0 1])

% put a symbol above the winning bar
MAPd = argmax(d);
text(MAPd,d(MAPd)+0.01,'*',...
	'FontSize',24)

%% yes/no
% s(2) = subplot(1,2,2)
% d=[randi(10,[1 4])  20]; d=d./sum(d);
% h(2) = bar([1:N+1],d)
% title('yes/no')
% ylabel('posterior')
% xlabel('D')
% %hline(0.5)
% hold on, plot([4.5 5.5],[0.5 0.5],'k-')
% ylim([0 1])
% xlim([0.5 N+1+0.5])
% %set(gca,'XTickLabel',{'present: 1, 2, 3, 4','absent: 5'})
% set(gca,'XTickLabel',{'1','2','3','4','5 (absent)'})
% 
% % put a symbol above the winning bar
% MAPd = argmax(d);
% text(MAPd,d(MAPd)+0.01,'*')

% stacked version of the plot
s(2) = subplot(1,2,2)
d=[randi(10,[1 4])  20]; d=d./sum(d);
PA=[sum(d(1:N)) d(N+1)]

h(2) = bar(PA)
title('yes/no')
ylabel('posterior')
xlabel('display type (D)')
hline(0.5)
%hold on, plot([4.5 5.5],[0.5 0.5],'k-')
ylim([0 1])
xlim([0.5 2+0.5])
set(gca,'XTickLabel',{'present: 1, 2, 3, 4','absent: 5'})
%set(gca,'XTickLabel',{'1','2','3','4','5 (absent)'})

% plot lines for d=1...N
hold on
for n=1:N-1
	plot([1-(0.5*0.8) 1+(0.5*0.8)],...
		[cumsum(d(n)) cumsum(d(n))],...
		'k-')
end
% put a symbol above the winning bar
MAP = argmax(PA);
text(MAP,PA(MAP)+0.01,'*',...
	'FontSize',24)

%% mutual axis formatting stuff
set(s,...
	'box', 'off',...
	'YTick',[0:0.25:1],...
	'PlotBoxAspectRatio',[1.5,1,1])

% bar properties
set(h,...
	'FaceColor','None',...
	'LineWidth',2)
drawnow


%%

%% Export the figure 
latex_fig(14, 7,3)

codedir=cd;
cd('/Users/benvincent/Desktop')
hgsave('fig_decision_rule')
export_fig fig_decision_rule -png -pdf -m1
cd(codedir)