function save_rc_table(data, fname_base)

fname = [fname_base datestr(now,'-yyyymmdd-HHMMSS') '.csv'];
writetable(data, fname)

return