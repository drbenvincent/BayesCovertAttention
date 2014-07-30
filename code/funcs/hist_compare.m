function hist_compare(A,B,nbins)

xvec= linspace( min([A(:) ; B(:)]) , max([A(:) ; B(:)]) , nbins);

yA = hist(A(:),xvec);
yB = hist(B(:),xvec);

plot(xvec,yA,'r-')
hold on
plot(xvec,yB,'b-')


