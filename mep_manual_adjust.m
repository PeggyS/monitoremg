function mep_manual_adjust(src, evt, app, beg_or_end)

% update the column in the data table with the check (src.Value)

% table row number
row = str2double(app.h_edit_epoch.String);

% table column 
switch beg_or_end
	case 'begin'
		mep_adj_col = find(contains(app.h_uitable.ColumnName, '>Latency<'));
	case 'end'
		mep_adj_col = find(contains(app.h_uitable.ColumnName, '>End<'));
end

app.h_uitable.Data{row, mep_adj_col} = logical(src.Value);

end % function
