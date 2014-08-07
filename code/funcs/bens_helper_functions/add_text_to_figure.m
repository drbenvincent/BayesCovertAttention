function add_text_to_figure(pos,txt, fs)
% add_text_to_figure('TL','hello', 15)

%% set position and alignments
a=axis;
switch pos
	case{'TL'}
		pos					= [a(1) a(4)];
		VerticalAlignment	= 'top';
		HorizontalAlignment = 'Left';
		
	case{'TR'}
		pos					= [a(2) a(4)];
		VerticalAlignment	= 'top';
		HorizontalAlignment = 'Right';
		
	case{'BL'}
		pos					= [a(1) a(3)];
		VerticalAlignment	= 'bottom';
		HorizontalAlignment = 'Left';
		
	case{'BR'}
		pos					= [a(2) a(3)];
		VerticalAlignment	= 'bottom';
		HorizontalAlignment = 'Right';
		
end

%% Write the text
text(pos(1),pos(2),txt,...
	'VerticalAlignment',VerticalAlignment,...
	'HorizontalAlignment',HorizontalAlignment,...
	'Color',[0 0 0],...
	'FontSize', fs);
return