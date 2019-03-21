function sici_edit_ts(source, event, app)
% set the default CS value when the TS value has been editted

% get the test stim value
ts = str2double(app.sici_ui.ts.String);

% default CS = 90% * aMT
% TS = 120% * aMT ==> aMT = TS/1.2
% CS = 0.9 * TS/1.2
cs = 0.9 * ts / 1.2;

app.sici_ui.cs.String = num2str(round(cs));
