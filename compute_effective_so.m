function effective_so = compute_effective_so(magstim_val, bistim_val, isi_ms, stimulator_setup)
% Compute the stimulator output that a single stand-alone Magstim would
% produce given the 2 stimulator settings in a Bistim setup.
%
% A single pulse through the Bistim is equivalent to 90% of a single
% Magstim.
%
% Simultaneous discharge of the Bistim (isi = 0) is equivalent to 113% of a
% single Magstim.
%
% magstim_val is the upper/1st/master stimulator setting
% bistim_val is the lower/2nd/slave stimulator setting
% isi_ms is the interstimulus interval (in ms)
% stimulator_setup (optional) is either 'magstim' if the coil was connected to 1 stimulator 
%	or 'bistim' if the coil was connected through the Bistim box using 2
%	stimulators. If the string is not sent, then EMD Data window will be
%	looked for. If the text object with the tag stim_setup_text is present,
%	then it's string value will be used. If the window does not exist, then
%	the user will be asked which setup to use in a dialog box.


if nargin < 4
	stimulator_setup = [];
end

effective_so = 0;

if isempty(stimulator_setup)
	emg_data_fig = findwind('EMG Data', 'Name');
	if ~ishandle(emg_data_fig)
		% ask if magstim or bistim setup
		q_str = 'What stimulator setup was used?';
		tlt = 'Stimulator Setup';
		hf = uifigure('Position', [974   689   411   216]);
		movegui(hf,'center')
		hf.WindowStyle = 'alwaysontop';
		ans_butt = uiconfirm(hf, q_str, tlt, ...
			'Options', {'Magstim', 'Bistim'}, ...
			'DefaultOption', 2);
		close(hf)
		% 	disp(ans_butt)
		stimulator_setup = lower(ans_butt);
	else
		% 	keyboard
		h_stim_txt = findobj(emg_data_fig, 'Tag', 'stim_setup_text');
		assert(~isempty(h_stim_txt), 'compute_effective_so: did not find object with Tag = stim_setup_text in EMG Data figure')
		stimulator_setup = lower(h_stim_txt.String);
	end
end

switch lower(stimulator_setup)
	case 'magstim'
		effective_so = magstim_val;
	case 'bistim'
		if magstim_val > 0 && bistim_val == 0
			effective_so = 0.9 * magstim_val;
		elseif magstim_val == bistim_val && isi_ms == 0
			effective_so = 1.13 * magstim_val;
		end
end
effective_so = round(effective_so);