% make_fig_distractor_heterogeneity

addpath('funcs')
plot_formatting_setup

figure(1)
clf

x=linspace(-10,10,1000);


%% Vincent et al (2009)
muT = 0;
muD = 0;
sigmaT = 1;



% Low distractor variance
h(1)=subplot(2,2,1)
sigmaD = 1.5;
hold on

T = normpdf(x,muT,sigmaT);
T = T ./sum(T);

D = normpdf(x,muD,sigmaD);
D = D ./sum(D);

plot(x,T,'k-')
plot(x,D,'k:')

ylabel('Vincent et al (2009)')
title('low distractor variance')


% High distractor variance
h(2)=subplot(2,2,2)
sigmaD = 4;
hold on

T = normpdf(x,muT,sigmaT);
T = T ./sum(T);

D = normpdf(x,muD,sigmaD);
D = D ./sum(D);

plot(x,T,'k-')
plot(x,D,'k:')

title('high distractor variance')




%% Palmer et al (2000)
muT = 0;
muD = 3;
sigmaT = 1;



% Low distractor variance
h(3)=subplot(2,2,3)
sigmaD = 1;
hold on

T = normpdf(x,muT,sigmaT);
T = T ./sum(T);

D = normpdf(x,muD,sigmaD);
D = D ./sum(D);

plot(x,T,'k-')
plot(x,D,'k:')

ylabel('Palmer et al (2000)')
title('low distractor variance')


% High distractor variance
h(4)=subplot(2,2,4)
sigmaD = 3;
hold on

T = normpdf(x,muT,sigmaT);
T = T ./sum(T);

D = normpdf(x,muD,sigmaD);
D = D ./sum(D);

plot(x,T,'k-')
plot(x,D,'k:')

title('high distractor variance')



%%
set(h, 'PlotBoxAspectRatio',[1.5 1 1],...
    'box', 'off',...
    'yticklabel',{},...
	'YTick',[],...
    'xlim', [-10 10],...
    'XTick',[])

%% Export
codedir=cd;
cd('../plots')
export_fig distractor_heterogeneity -png -pdf -m1
cd(codedir)
