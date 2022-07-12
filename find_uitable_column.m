function ind = find_uitable_column(h_tbl, col_str)

% can probably replace with a single line:
% ind = find(contains(h_tbl.ColumnName, col_str));
% FIXME

ind = [];

tmp = strfind(h_tbl.ColumnName, col_str); % cell array with matching strings

ind = find(~cellfun(@isempty,tmp)); % index of non empty string