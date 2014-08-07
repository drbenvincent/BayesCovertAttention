function [m,s]=min_sec(t,varargin)
% [m,s, str]=min_sec(toc, ['print','no_print'])

% defaults
h=0;
m=0;
s=0;

switch nargin
	case{1}
		shall_I_print='print';
	case{2}
		shall_I_print=varargin{1};
end


% how many minuites
m=fix(t/60);

% if under 60 mins
if m<60
	s=t - (60*m);
end

% if over 60 mins then how many hours, and how many residual mins
if m>60
	% seconds
	s = t - (60*m);
	
	% hours
	h = fix(m/60);
	% additional mins
	m = m - h*60;
end

switch shall_I_print
	case{'print'}
		% seconds
		if m<1
			fprintf('%2.0f sec \n',s);
		else
			if h<1
				fprintf('%2.0fmin %2.0fsec\n',m,s);
			else
				fprintf('%2.0fhr %2.0fmin %2.0fsec\n',h,m,s);
			end
		end
end

return

