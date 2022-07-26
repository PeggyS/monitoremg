function get_emg_act_monitor_parameters(app, param_fname)

% read in parameters   
parameter_file = param_fname;
if ~exist(parameter_file, 'file')
  [filename, pathname] = uigetfile( ...
     {'*.txt';'*.*'}, ...
     'Choose Parameter File');
  parameter_file = fullfile(pathname, filename);
end
if ~exist(parameter_file, 'file')
  error( 'error finding parameter file, %s', parameter_file)
end
% read in the parameter file
keywords = {'ip address' 'sampling frequency (Hz)' 'average time period (sec)' ...
	'emg channel' 'activation goal' 'emg pre trigger time (msec)' ...
	'emg post trigger time (msec)'};
defaults = {'192.168.1.102', 2500, 0.5, 1, 0.2, 50, 100};
paramscell = readparamfile(parameter_file, keywords, defaults);
            app.params.ipAddr    = paramscell{1};
app.params.sampFreq  = paramscell{2};
            app.params.avgPeriod = paramscell{3};
            app.params.dispChan  = paramscell{4};
            app.params.goalPct   = paramscell{5};
app.params.preTriggerTime  = paramscell{6};
app.params.postTriggerTime = paramscell{7};

% 
% seg_time = (app.params.postTriggerTime + app.params.preTriggerTime) / 1000;
% seg_num_points = round(app.params.sampFreq*seg_time);
% time vector in msec
% t = (0:1/app.params.sampFreq:(seg_time-1/app.params.sampFreq))*1000 - app.params.preTriggerTime;
 
           