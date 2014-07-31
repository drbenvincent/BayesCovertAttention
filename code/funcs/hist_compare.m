function hist_compare(A,B,X)

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


