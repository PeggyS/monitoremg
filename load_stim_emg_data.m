function load_stim_emg_data(source,event, app)

if any(strcmp(properties(app), 'h_uitable')) % when used in review_emg_rc.app, data is already in this field
% 	% but re-read it in from the file as a table
 	if any(strcmp(properties(app), 'MuscleEditField')) 
 		filename = app.MuscleEditField.Value;
% 		data = readtable(app.DatapointsCSVEditField.Value);
% 	else
 	end

	data = cell2table(app.h_uitable.Data);
	colnames = strrep(app.h_uitable.ColumnName, '<html><center>', '');
	colnames = strrep(colnames, '</center></html>', '');
	colnames = strrep(colnames, '<br />', '_');
	colnames = strrep(colnames, '*', '_');
	% fix several column names:
	colnames = strrep(colnames, 'MonitorEMG_val', 'MonitorEMGval');
	colnames = strrep(colnames, 'Goal_EMG', 'GoalEMG');
	colnames = strrep(colnames, 'Goal_Min', 'GoalEMGmin');
	colnames = strrep(colnames, 'Goal_Max', 'GoalEMGmax');
	data.Properties.VariableNames = colnames; 
else % request the file name	
	[filename, pathname] = uigetfile('*.txt; *.csv', 'Pick a text file with MagStim_Setting and MEPAmpl_uVPp');
	if isequal(filename,0) || isequal(pathname,0)
	   disp('User pressed cancel')
	else
	   fname = fullfile(pathname, filename);
	end

	switch filename(end-2:end)
		case 'txt'
			data = readtable(fname, 'delimiter', '\t');
		case 'csv'
			data = readtable(fname);
	end
end


% clear any existing points
if isgraphics(app.rc_axes)
	cla(app.rc_axes)
	which_axes = 'rc_axes';
elseif isgraphics(app.sici_axes)
	if isfield(app.sici_ui, 'data_lines')
		if ~isempty(app.sici_ui.data_lines)
			delete(app.sici_ui.data_lines)
			app.sici_ui.data_lines = {};
		end
	end
	which_axes = 'sici_axes';
else
	% neither rc or sici
	return
end

% data table is saved in axes userdata
app.(which_axes).UserData = data;

% norm factor
if isfield(app.rc_fit_ui, 'edNormFactor') && isgraphics(app.rc_fit_ui.edNormFactor)
	norm_factor = str2double(app.rc_fit_ui.edNormFactor.String);
else
	norm_factor = 1;
end

% get mep method
rb_mep_ampl = findobj(app.emg_data_fig, 'Tag', 'rb_mep_ampl');
if rb_mep_ampl.Value
	data_var = 'MEPAmpl_uVPp';
else
	data_var = 'MEPAUC_uV_ms';
end
for cnt = 1:height(data)
	switch which_axes
		case 'rc_axes'
			add_point2rc(app.rc_axes, data.Epoch(cnt), data.MagStim_Setting(cnt), data.(data_var)(cnt)/norm_factor)
		case 'sici_axes'
			add_point2sici(app, data.Epoch(cnt), data.MagStim_Setting(cnt), data.(data_var)(cnt)/norm_factor)
 	end
end

title(strrep(filename, '_', ' '))

return