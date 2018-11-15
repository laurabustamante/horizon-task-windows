classdef eyetracker < handle
    properties
        filename
        datadir
        eyetribedir
        eyetribeSourcedir
        connection
        success
        flag
    end
    methods
        function obj = eyetracker(eyetribedir,eyetribeSourcedir)
            obj.eyetribedir = eyetribedir;
            obj.eyetribeSourcedir = eyetribeSourcedir;
            addpath(eyetribedir);
            addpath(eyetribeSourcedir);
        end
        function setup(obj,datadir,filename)
            if obj.flag
                obj.filename = filename;
                obj.datadir = datadir;
            end
        end
        function open(obj)
            if obj.flag
                 % open eyetribe server and eyetribe calibration
                cd(obj.eyetribedir);
                !open -a Terminal startEyeTribeServer
                WaitSecs(10)
            end
        end
        function close(obj)
            if obj.flag
                cd(obj.eyetribedir);
                !pkill EyeTribe
            end
        end
        function startmatlabserver(obj)
            if obj.flag
                cd(obj.eyetribedir)
                !open ./startEyeTribeMatlabServer
                WaitSecs(5)
            end
        end
        function calibrate(obj)
            if obj.flag
                cd /Applications/EyeTribe
                !open -W ./EyeTribeUI.app
            end
        end
        function connect(obj)
            if obj.flag
                add = [obj.datadir obj.filename]
                % open a connection in matlab
                [obj.success, obj.connection] = eyetribe_init(add);
            end
        end
        function disconnect(obj)
            if obj.flag
                obj.success = eyetribe_close(obj.connection);
            end
        end
        function startaquiring(obj)
            if obj.flag
                obj.success = eyetribe_start_recording(obj.connection);
            end
        end
        function endaquiring(obj)
            if obj.flag
                obj.success = eyetribe_stop_recording(obj.connection);
            end
        end
        function marker(obj,markername)
            if obj.flag
                obj.success = eyetribe_log(obj.connection, markername);
            end
        end
    end
end