classdef exp_template < exp_psychtoolbox
	properties
        path
        eye
        eeg
        testmode
        subjectID
        filename
        postques
        demo
        time
        savepath
    end
	methods
		function obj = exp_template()
            obj.testmode = 0;
            obj.demo = [];
            obj.eye.flag = false;
            obj.eeg.ison = false;
            obj.time.starttime = datestr(now, 30);
        end
        function baseline_blink(obj)
             ev{1} = 'We will measure your brain activity before doing the task.';
            ev{2} = 'Please look at the blank screen during this period. Feel free to mind wandering.';
            ev{3} = 'This will take about 5 minutes. Press space to start when you are ready.';
            obj.time.baseline.KeyNum = [];
            obj.time.baseline.t = [];
            i = 1;
            while i <= 3
                obj.talk(ev{i}, 'instructions');
                obj.talkAndflip([],'pageturner');
                keyspace = [KbName('space') KbName('delete')];
                [KeyNum, obj.time.baseline.t(end+1)] = obj.waitForInput([keyspace],Inf);
                obj.time.baseline.KeyNum(end+1) = KeyNum;
                if KeyNum == keyspace(1)
                    i = i + 1;
                elseif i > 1
                    i = i - 1;
                end
            end
            for i = 3:-1:1
                obj.talkAndflip(num2str(i));
                WaitSecs(1.0);
            end
            obj.talkAndflip('Start now');
            WaitSecs(1.0);
            obj.time.baseline.start = obj.talkAndflip('');
            obj.eye.marker('Baseline_start');
            if obj.eye.flag
                obj.time.baseline.end = WaitSecs(300.0);
            else
                obj.time.baseline.end = WaitSecs(1.0);
            end
            obj.eye.marker('Baseline_end');
            obj.talkAndflip('Thank you for your patience. Press space to continue', 'instructions');
            [KeyNum, obj.time.baselineend] = obj.waitForInput([keyspace],Inf);
     
            
        end
        function get_subjectID(obj)
            obj.subjectID = input('subjectID: ');
        end
        function setup_path(obj, path)
            obj.path = path;
        end
        function setup_file(obj, filename)
            obj.filename = filename;
        end
        function setup_eye(obj, ison)
            if nargin < 2
                ison = 0;
            end
            path = pwd;
            eye = eyetribe(fullfile(obj.path.savepath,'eye',strcat(obj.filename,'_eye_', obj.time.starttime)), ison);
            try
                eye.setup_path(obj.path.eye_server, obj.path.eye_UI, obj.path.eye_matlab_server);
            end
            eye.start;
            cd(path);
            obj.eye = eye;
        end
        function setup_eeg(obj, ison)
            if nargin < 2
                ison = 0;
            end
            obj.eeg = eegmarker('E037', ison);
        end
%         function setup_vid(obj)
%             vid = videoinput('winvideo',1,'MJPG_640x480');
%             vid.FrameGrabInterval = 1;
%             vid.FramesPerTrigger = 1;
%             vid.TriggerRepeat = Inf;
%             vwObj = VideoWriter(fullfile(obj.path.data,obj.filename),'Motion JPEG AVI');
%             vid.DiskLogger = vwObj;
%             vid.LoggingMode = 'disk';
%             obj.vid = vid;
%         end
%         function start_vid(obj)
%             start(obj.vid);
%         end
%         function stop_vid(obj)
%             stop(obj.vid);
%         end
%         function close_vid(obj)
%             vid = obj.vid;
%             vwObj = vid.DiskLogger;
%             close(vwObj);
%             delete(vid);
%         end
%         function shutdown_eye(obj)
%         end
        function get_demo(obj)
            x = 0;
            while ~strcmp(x, '1')
                demo.age = input('What is your age?  ', 's');
                demo.gender = input('What is your gender? 1 for male, 2 for female  ', 's');
                demo.math = input('How many college level math classes have you taken?  ', 's');
                demo.history = input('Have you participated in other experiments in this lab before? 1 for yes, 0 for no  ', 's');
                x = input('Is this information correct? Type 0 for no and 1 for yes:  ', 's');
            end
            obj.demo = demo;
        end
        function get_postques(obj)
            clc;
            x = '0';
            while ~strcmp(x, '1')
                post.engage = input('Are you really doing the task? 1 for Yes, 0 for No:  ','s');
                post.percent = input('What percentage of time are you really doing the task? type 0-100%:  ','s');
                post.history = input('Have you participated in this experiment before? 1 for Yes, 0 for No:   ','s');
                post.comment = input('Any comment?  ','s');
                x = input('Is this information correct? Type 0 for no and 1 for yes:  ', 's');
            end
            obj.postques = post;
        end
	end
end

