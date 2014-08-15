function slope = slope_in_Z_space(FAR, HR)


zHR = Z(HR);
zFAR = Z(FAR);

% remove inf
myset	= isinf(zHR)==0 & isinf(zFAR)==0;
zHR		= zHR(myset);
zFAR	= zFAR(myset);

% fit
p = polyfit(zFAR,zHR,1);

slope = p(1);
intercept = p(2);

return