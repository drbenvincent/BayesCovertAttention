function hist_compare(A,B,X)
% Compare the distribution of 2 variables A and B.
% The input X defines either the number of bins or a set of bin points.
% e.g.
% hist_compare(A,B,50)
% hist_compare(A,B,linspace(0,1,50))

if numel(X)==1
	% then this is the number of bins
	X= linspace( min([A(:) ; B(:)]) , max([A(:) ; B(:)]) , X);
else
	%we've been given a vector of points to evaluate the histogram at
end

yA = hist(A(:),X);
yB = hist(B(:),X);

plot(X,yA,'r-')
hold on
plot(X,yB,'b-')

return