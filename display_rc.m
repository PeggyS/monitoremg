function display_rc(app, param)

switch param
	case 'start'
		init_rc_fig(app)
		
	case 'stop'
		delete(app.rc_fig)
end 
