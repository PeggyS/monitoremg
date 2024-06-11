function update_review_emg_data_line(app, h_tbl, new_row)
% disp('update_review_emg_data_line');
if new_row == 0 || new_row > size(h_tbl.Data,1)
	disp('invalid row in emg data table')
	return
end
% display emg data
% shift the data by the ISI (time between conditioning stim and test stim)

% find the ISI (from the table)
isi_col = find(contains(app.h_uitable.ColumnName, '>ISI<'));
isi_ms = h_tbl.Data{new_row, isi_col}; %#ok<FNDSB>
st_col = find(contains(app.h_uitable.ColumnName, '>Type<'));
if ~isempty(st_col)
	stim_type = h_tbl.Data{new_row, st_col}; 
else
	stim_type = '';
end

% if sici/icf and ISI > 0, shift the data by ISI ms
%if app.CheckBoxSici.Value == 1 && isi_ms > 0 && ~isempty(stim_type) && ~strcmp(stim_type, 'Test Stim')
% line above assumes test stim is the magstim, but we changed to using the bistim
if app.CheckBoxSici.Value == 1 && isi_ms > 0 && ~isempty(stim_type) && ~strcmpi(stim_type, 'Test Stim')
	% sici & icf
	isi_shift_pts = round(app.params.sampFreq * isi_ms / 1000);
elseif app.CheckBoxSici.Value == 1 && isi_ms > 0 && ~isempty(stim_type) && strcmpi(stim_type, 'Test Stim') ...
	% test stim: check bistim col. If it has a non-zero value, then it was used for the test stim
	% and the data needs to be shifted
	bistim_col = find(contains(app.h_uitable.ColumnName, '>BiStim<'));
	if h_tbl.Data{new_row, bistim_col} > 0 %#ok<FNDSB> 
		% test stim in the lower/bistim stimulator
		isi_shift_pts = round(app.params.sampFreq * isi_ms / 1000);
	else
		% test stim with 0 in the lower/bistim stimulator
		isi_shift_pts = 0;
		isi_ms = 0;
	end
else
	% bistim
	isi_shift_pts = 0;
	isi_ms = 0;
end
tmp_data = app.emg_data(new_row, app.emg_data_num_vals_ignore+1:end);
if length(tmp_data) ~= length(app.h_emg_line.YData)
	% for s2737 sici data, only 299 data points were saved, not the usual 300
	% detect this condition and add an extra nan at the end of the data to dislay
	fprintf('saved emg data is %d points; anticipated length is %d\n', ...
		length(tmp_data), length(app.h_emg_line.YData))
	fprintf('   adding a NaN to the end of the emg data\n')

	if length(tmp_data) < length(app.h_emg_line.YData)
		add_pts = length(app.h_emg_line.YData) - length(tmp_data);
		tmp_data = [tmp_data nan(1,add_pts)];
	else
		tmp_data = tmp_data(1:length(app.h_emg_line.YData));
	end
end
app.h_emg_line.YData = [tmp_data(isi_shift_pts+1:end) nan(1,isi_shift_pts)];

% update conditioning stim line h_cs_line
app.h_cs_line.XData = -isi_ms*[1 1];

% if axes y limits are the same (i.e. ymin == ymax), make them wider
ymin = min(app.emg_data(new_row, app.emg_data_num_vals_ignore:end));
ymax = max(app.emg_data(new_row, app.emg_data_num_vals_ignore:end));
if ymax - ymin < eps
	ymax = ymax + 1;
	ymin = ymin - 1;
end
app.h_disp_emg_axes.YLim = [ymin ymax];
app.row_displayed = new_row;

% update pre-stim line
pre_stim_col = find_uitable_column(h_tbl, 'PreStim');
pre_stim_val = app.h_uitable.Data{new_row,pre_stim_col};
pre_stim_val = compute_pre_stim_emg_value(app, app.h_emg_line);
% app.h_uitable.Data(new_row,pre_stim_col) = {pre_stim_val}; % if the table
% value is updated then the row becomes unselected
app.h_pre_stim_emg_line.YData = [pre_stim_val pre_stim_val];

% update std line
std_val = compute_pre_stim_emg_std_value(app, app.h_emg_line) * str2double(app.h_num_std.String);
% disp(['pre stim ' app.h_num_std.String '*std for epoch ' num2str(new_row) ' = ' num2str(std_val)])
app.h_pre_stim_emg_pos_std_line.YData = [std_val std_val];
app.h_pre_stim_emg_neg_std_line.YData = [-std_val -std_val];

% update emg auc patch
mep_start_time = app.h_t_min_line.XData(1);
mep_end_time = app.h_t_max_line.XData(1);
[vertices, faces] = compute_patch(mep_start_time, mep_end_time, app.h_emg_line, 0);

app.h_emg_auc_patch.Vertices = vertices;
app.h_emg_auc_patch.Faces = faces;
% auc = compute_auc(vertices);

% highlight data point in rc_fig or sici_fig
if isgraphics(app.rc_axes)
	h_ax = app.rc_axes;
elseif isgraphics(app.sici_axes)
	h_ax = app.sici_axes;
else
	return
end
h_line = find_rc_datapoint(h_ax, new_row);
if ~isempty(h_line)
	clr = [0 0.8 0];
	emg_ind = find_uitable_column(h_tbl, 'MonitorEMG');
	emg_min_ind = find_uitable_column(h_tbl, 'Goal<br />Min');
	emg_max_ind = find_uitable_column(h_tbl, 'Goal<br />Max');
	if h_tbl.Data{new_row, emg_ind} > h_tbl.Data{new_row, emg_max_ind}
		clr = [170 100 245]/255;
	elseif h_tbl.Data{new_row, emg_ind} < h_tbl.Data{new_row, emg_min_ind}
		clr = [255 193 59]/255;
	end
	h_line.Color = clr;
	h_line.MarkerSize = 50;
	uistack(h_line,'top')
end
if ~isempty(app.rc_highlight_line)
	if isgraphics(app.rc_highlight_line)
		% unhighlight prev
		app.rc_highlight_line.Color = [0    0.4470    0.7410];
		if app.rc_highlight_line.Marker == 'x'
			app.rc_highlight_line.MarkerSize = 20;
		else
			app.rc_highlight_line.MarkerSize = 40;
		end
	end
end
% save highlighted line handle
app.rc_highlight_line = h_line;
