cd(mainpath);
addpath('./HORIZONTASK_FUNCTIONS');
addpath('./FUNCTIONS_TASK');
path.savepath = fullfile(datadir, 'DATA_HORIZONTASK');
if ~exist(path.savepath)
    mkdir(path.savepath);
end
path.eye_server = 'C:\Program Files (x86)\EyeTribe\Server';
path.eye_UI = 'C:\Program Files (x86)\EyeTribe\Client';
path.eye_matlab_server = 'C:\Users\updates\Google Drive\EyeTribe-Toolbox-for-Matlab-master\EyeTribe_for_Matlab';
filename = 'HorizonTask'; 
eyeswitch = 0;
eegswitch = 0;
tsk = task_horizon(path, filename, eyeswitch, eegswitch);
tsk.ispay = 3; 
tsk.istest = istest;
tsk.run;
sca
