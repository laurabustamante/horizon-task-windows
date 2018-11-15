classdef bandit < exp_psychtoolbox
    properties
        w
        h
        w_lever
        h_lever
        pos_lever
        penwidth
        dotradius
        horizon
        lever_side
        font_bandit
        tp_left  
        color_frame
        color_highlight
        tp_top
        rect
        numbers
    end
    methods
        function obj = bandit(window)
            obj.window = window;
            obj.w = 0;
            obj.h = 0;
        end
        function setup(obj,w,h,w_lever,h_lever,pos_lever,penwidth,dotradius,horizon,lever_side, font_bandit, color_bandit)
            obj.w = w; % width of the box in each bandit
            obj.h = h; % height of the box in each bandit
            obj.w_lever = w_lever; % width of the lever
            obj.h_lever = h_lever; % height of the lever
            obj.pos_lever = pos_lever; % Position of the lever
            obj.penwidth = penwidth; % width of the bar
            obj.dotradius = dotradius; % size of the handle
            obj.horizon = horizon; % horizon
            obj.lever_side = lever_side; % side of the handle
            obj.font_bandit = font_bandit; % font format for the bandit
            obj.color_highlight = obj.color.AZcactus; % Arizona color for highlight
            obj.settppos(0,0);
            switch obj.lever_side
                case 'left'
                    obj.color_frame = color_bandit{1};
                case 'right'
                    obj.color_frame = color_bandit{2};
            end
        end
        function flush(obj)
            obj.numbers = {};
        end
        function addreward(obj, new)
            obj.numbers{end + 1} = new;
        end
        function draw(obj, played, forcedchoice)
            if nargin < 3
                forcedchoice = [];
            end
            numbers = obj.numbers;
            rect = obj.rect;
            if length(forcedchoice) == 0 && length(numbers) < obj.horizon
                Screen('FillRect', obj.window.id, obj.color_highlight, rect(:,length(numbers)+1));
            end
            Screen('FrameRect', obj.window.id, obj.color_frame, rect, obj.penwidth);
            for i = 1:length(numbers)
                trec = rect(:,i)';
                trec([2 4]) = trec([2 4]) - obj.h*0.15;
                obj.talk(numbers{i}, 'window', obj.font_bandit, trec);
            end
            switch obj.lever_side
                case 'left'
                    fromH = obj.tp_left;
                    toH = fromH - obj.w_lever;
                case 'right'
                    fromH = obj.tp_left + obj.w;
                    toH = fromH + obj.w_lever;
            end
            fromV = obj.tp_top + obj.pos_lever * obj.h;
            if played
                toV = fromV + obj.h_lever;
            else
                toV = fromV - obj.h_lever;
            end
            Screen('Drawline', obj.window.id, obj.color_frame, fromH, fromV, toH, toV, obj.penwidth);
            Screen('DrawDots', obj.window.id, [toH toV], obj.dotradius, obj.color_frame, [0 0]);
        end
        function settppos(obj, cleft, top)
            if nargin < 2 || isempty(cleft)
                cleft = obj.tp_left + obj.w / 2;
            else
                cleft = obj.window.w * cleft;
            end
            if nargin < 3 || isempty(top)
                top = obj.tp_top;
            else
                top = obj.window.h * top;
            end
            w = obj.w;
            h = obj.h;
            left = cleft - w/2;
            obj.tp_left = left;
            obj.tp_top = top;
            for i = 1:obj.horizon
                obj.rect(:,i) = [left+0; top+h*(i-1); left+w; top+h*i];
            end
        end
        
    end
end