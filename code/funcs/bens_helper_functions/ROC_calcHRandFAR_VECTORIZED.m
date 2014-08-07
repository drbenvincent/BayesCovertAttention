%% ROC_calcHRandFAR_VECTORIZED
% Based upon distributions of signal and noise, contained in the vectors
% |S| and |N|, calculate hit rates |HR|, false alarm rates |FAR|, and the
% area under the ROC curve |AUC|.
% I created this nice, fast, algorithm for calculating ROC curves. Someone
% else may have done it like this before, but I worked it out from scratch.
%%



function [HR, FAR, AUC]=ROC_calcHRandFAR_VECTORIZED(N,S)
%% Example code to test this function:
%
%   N = randn(1000,1)-1;
%   S = randn(1000,1);
%   [HR, FAR, AUC]=ROC_calcHRandFAR_VECTORIZED(N,S);
%   plot(FAR,HR), title(AUC)
%
%%

%% The algorithm...

NN=numel(N);
NS=numel(S);

all=[S(:) ; N(:)];

% Label signals with 1 and noise with 0
labels		= [ones(size(S(:))) ; zeros(size(N(:)))];

% sort according to the x-axis (ie the decision variable)
[~, idx]	= sort(all,1,'descend');
% shuffle the labels along correspondingly
labels		= labels(idx);

% this is the clever part
HR			= cumsum(labels) ./ NS;
FAR			= ([1:NS+NN]' - cumsum(labels)) ./ NN;


%%
% Make sure (0,0) and (1,1) are included
if HR(1)~=0 || FAR(1)~=0
	HR	=[0;HR];
	FAR	=[0;FAR];
end

if HR(end)~=1 || FAR(end)~=1
	HR	=[HR;1];
	FAR	=[FAR;1];
end


%% Remove duplicate values
% These vectors can get quite long, so remove duplicate values.
if numel(FAR) > 1000
	% GET RID OF DUPLICATED VALUES --------
	[FAR, setvec]	=unique(FAR);
	HR				=HR(setvec);
	% -------------------------------------
	
	% interp
	FARi	= [0:0.001:1];
	HRi		= interp1(FAR,HR,FARi);
	
	HR		= HRi(:);
	FAR		= FARi(:);
end

%% Calculate AUC by trapezoidal integration
AUC			= trapz(FAR,HR);

return