function [responsePM] = YesNoDecisionRule(logPosterior, N)
% Given a posterior distribution over display types 1, ..., N+1, this
% function will calculate the decision variable. 
%
% It also calculates the response of an unbiased observer.




%% DECISION VARIABLE

%
logPosteriorPresent = sum(logPosterior(1:N));
logPosteriorAbsent	= logPosterior(N+1);
decision_variable	= logPosteriorPresent - logPosteriorAbsent;


%% DECISION BY POSTERIOR MODE

posterior_mode = argmax(logPosterior);

if posterior_mode == N+1
	responsePM=0; % absent
else
	responsePM=1; % present
end

% DECISION BY DECISION VARIABLE
if decision_variable<0
	responseDV=0; % absent
else
	responseDV=1; % present
end

if responseDV ~= responsePM
	error
end
