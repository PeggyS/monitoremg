function init_rc_fig(app)

app.rc_fig = figure('Position', [200   200   600   800], ...
	'NumberTitle', 'off', 'Name', 'Recruitment Curve');

app.rc_axes = axes('Position', [0.13 0.4 0.775 0.55]);
ylabel('MEP Vp-p (µV)')
xlabel('Magstim Power')
