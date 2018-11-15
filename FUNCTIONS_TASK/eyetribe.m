classdef eyetribe < handle
    properties
        filename
        connection
        calibration
        path_server
        path_matlab_server
        path_UI
        flag
    end
    methods
        function obj = eyetribe(filename, flag)
            obj.filename = filename;
            if nargin < 2
                flag = 1;
            end
            obj.flag = flag;
        end
        function setup_path(obj, path_server, path_UI, path_matlab_server)
            if obj.flag
                obj.path_server = path_server;
                obj.path_UI = path_UI;
                obj.path_matlab_server = path_matlab_server;
            end
        end
        function startaquiring(obj)
            if obj.flag
                success = eyetribe_start_recording(obj.connection);
            end
        end
        function endaquiring(obj)
            if obj.flag
                success = eyetribe_stop_recording(obj.connection);
            end
        end
        function connect(obj)
            if obj.flag
                [success, obj.connection] = eyetribe_init(obj.filename);
            end
        end
        function disconnect(obj)
            if obj.flag
                success = eyetribe_close(obj.connection);
            end
        end
        function marker(obj,markername)
            if obj.flag
                success = eyetribe_log(obj.connection, markername);
            end
        end
        function start(obj)
            if obj.flag
                obj.start_eyetribe_server;
                obj.gaze_calibrate;
                obj.start_matlab_server;
                obj.connect;
                obj.startaquiring;
            end
        end
        function start_eyetribe_server(obj)            
            if obj.flag
                cd(obj.path_server);
                if ismac
                    !open -a Terminal startEyeTribeServer
                end
                pause(2.0);
            end
        end
        function gaze_calibrate(obj)
            if obj.flag
                cd(obj.path_UI);
                calibration = -1;
                if ismac
                !open -W ./EyeTribeUI.app
                end
                pause(2.0);
                calibration = input('please input the calibration quality: ');
                obj.calibration = calibration;
            end
        end
        function start_matlab_server(obj)
            if obj.flag
                if ismac
                                addpath(obj.path_matlab_server);
                                cd(obj.path_server);
                        !open ./startEyeTribeMatlabServer
                end
                           pause(2.0);
                end
        end
        function close(obj)
            if obj.flag
                obj.endaquiring;
                obj.disconnect;
            end
        end
    end
end