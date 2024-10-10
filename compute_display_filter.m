function compute_display_filter(app)

% % parameters to high pass filter at 10 Hz
% [b, a] = butter(4, 10/(app.params.sampFreq/2), 'high');

if app.HPFilterCheckBox.Value == 1
	cutoff = app.HPEditField.Value;
	[hp_b, hp_a] = butter(4, cutoff/(app.params.sampFreq/2), 'high');
	hp_dig_filt = dfilt.df2t(hp_b, hp_a);
	app.display_filter = hp_dig_filt;
else
	app.display_filter = dfilt.df2t; %  default, discrete-time, direct-form II 
	% transposed filter, Hd, with b=1 and a=1. This filter passes the input 
	% through to the output unchanged.
end
if app.LPFilterCheckBox.Value == 1
	cutoff = app.LPEditField.Value;
	[lp_b, lp_a] = butter(4, cutoff/(app.params.sampFreq/2), 'low');
	lp_dig_filt = dfilt.df2t(lp_b, lp_a);
	app.display_filter = dfilt.cascade(app.display_filter, lp_dig_filt);
end



% app.display_filter.a = a;
% app.display_filter.b = b;

return
end % function