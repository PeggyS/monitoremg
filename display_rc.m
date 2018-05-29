function display_rc(app, param)

switch param
	case 'start'
		init_rc_fig(app)
		
		rc_get_meps(app)
	case 'stop'
		delete(app.rc_fig)
end 
