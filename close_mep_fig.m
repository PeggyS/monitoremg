function close_mep_fig(source, event, app)

% delete the figure
delete(source)

% change checkbox
app.CheckBoxDisplayMEP.Value = 0;

return