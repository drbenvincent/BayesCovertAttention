function [y]=Z(x)
% For ROC, the function y=Z(x) is the inverse cumulative Gaussian
% distribution.

y = norminv(x,0,1);
return