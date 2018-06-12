function save_rc_table(data, fname)

% fname = [fname_base datestr(now,'-yyyymmdd-HHMMSS') '.csv'];
if height(data) > 0
	writetable(data, fname)
else
	disp('no data points to save')
end

return