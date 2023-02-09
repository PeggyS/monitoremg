function compute_non_mep_ampl(src, evt, app)



% find col num of some variables in the table
use_col = find(contains(app.h_uitable.ColumnName, 'Use'));
isi_col = find(contains(app.h_uitable.ColumnName, '>ISI<'));
magstim_col = find(contains(app.h_uitable.ColumnName, '>MagStim<'));
bistim_col = find(contains(app.h_uitable.ColumnName, '>BiStim<'));

is_mep_col = find(contains(app.h_uitable.ColumnName, '>Is<'));
latency_col = find(contains(app.h_uitable.ColumnName, '>latency<'));
mep_end_col = find(contains(app.h_uitable.ColumnName, '>end<'));
% mep_ampl_col = find(contains(app.h_uitable.ColumnName, '>MEPAmpl<'));

% keyboard
% find unique combinations of is_mep, magstim, bistim, and isi
tbl_stim = cell2table(app.h_uitable.Data(:,[is_mep_col, magstim_col, bistim_col, isi_col]), ...
	'VariableNames', {'is_mep', 'magstim', 'bistim', 'isi'});
[t2, unq_rows, c2] = unique(tbl_stim, 'rows');


tbl_data = cell2table(app.h_uitable.Data(:,[is_mep_col, magstim_col, bistim_col, isi_col, ...
	latency_col, mep_end_col]), ...
	'VariableNames', {'is_mep', 'magstim', 'bistim', 'isi', 'latency', 'mep_end'});

for u_cnt = 1:length(unq_rows)
	if tbl_stim.is_mep(unq_rows(u_cnt)) == true % only if some meps have been identified
		% find all rows in the datapoint table with these magstim, bistim,
		% and isi
		magstim = tbl_stim.magstim(unq_rows(u_cnt));
		bistim = tbl_stim.bistim(unq_rows(u_cnt));
		isi = tbl_stim.isi(unq_rows(u_cnt));

		% find rows in tbl with these values and is_mep == true
		has_latency_tbl = tbl_data(tbl_data.is_mep & tbl_data.magstim==magstim & ...
			tbl_data.bistim==bistim & tbl_data.isi==isi,  {'latency' 'mep_end'});
		mean_latency = mean(has_latency_tbl.latency);
		mean_end = mean(has_latency_tbl.mep_end);

		% find rows with is_mep == false and same stim & isi values
		no_mep_rows = find(~tbl_data.is_mep & tbl_data.magstim==magstim & ...
			tbl_data.bistim==bistim & tbl_data.isi==isi);

		% fill in latency and end times in the table
		app.h_uitable.Data(no_mep_rows, latency_col) = {mean_latency};
		app.h_uitable.Data(no_mep_rows, mep_end_col) = {mean_end};

		% compute amplitude
	end
end

return
end