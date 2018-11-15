classdef eegmarker < handle
    properties
        ioObj
        address
        markers
        ison
        markerlist
    end
    methods
        function obj = eegmarker(code, ison)
            obj.markers.rewardon = 3;
            obj.markers.keypress = 5;
            obj.markers.bandit_on = 7;
            obj.markers.horizon_on = 9;
            obj.markers.starttrial = 2;
            obj.markers.endtrial = 6;
            obj.markers.cross = 8;
            obj.markers.baseline = 1;
            obj.ison = ison ~= 0;
            obj.markerlist.x = [];
            obj.markerlist.t = [];
            if ison
                ioObj = io64;
                % initialize the interface to the inpoutx64 system driver
                status = io64(ioObj);
                % if status = 0, you are now ready to write and read to a hardware port
                % let's try sending the value=1 to the parallel printer's output port (LPT1)
                address = hex2dec(code);          %standard LPT1 output port address
                obj.ioObj = ioObj;
                obj.address = address;
            end
        end
        function marker(obj, data_out)
            if obj.ison
                io64(obj.ioObj, obj.address, data_out);   %output command
                obj.markerlist.x(end+1) = io64(obj.ioObj,obj.address);
                obj.markerlist.t(end+1) = WaitSecs(0.1);
            end
        end
    end
end