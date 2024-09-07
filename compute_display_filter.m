function compute_display_filter(app)

% parameters to high pass filter at 10 Hz
[b, a] = butter(4, 10/(app.params.sampFreq/2), 'high');

app.display_filter.a = a;
app.display_filter.b = b;

return
end % function