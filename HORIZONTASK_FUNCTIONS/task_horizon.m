classdef task_horizon < exp_template
    properties
        % bandit object
        ban_L_s
        ban_R_s
        ban_L_l
        ban_R_l
        bandit_color
        ispay
        % instructions
        iStr
        iEv
        % cross object
        fixcross
        % payment page
        payment
        % game info
        game
        gamepractice
    end
    methods
        function obj = task_horizon(path, filename, eyeswitch, eegswitch)
            obj.ispay = 0;
            obj.setup_path(path);
            obj.setup_file(filename);
            obj.game = [];
            obj.get_subjectID;
            rand('seed', sum(clock*100) + obj.subjectID);
            if rand < 0.5
                obj.bandit_color = {obj.color.AZmesa, obj.color.AZriver};
            else
                obj.bandit_color = {obj.color.AZriver, obj.color.AZmesa};
            end
            obj.payment.flat = 0;
            obj.set_taskParameter;
            obj.setup_eye(eyeswitch);
            obj.setup_eeg(eegswitch);
        end
        function run(obj)
            space = KbName('space');
            backspace = KbName('backspace');
            leftarrow = KbName('leftarrow');
            rightarrow = KbName('rightarrow');
            keylist = [space, backspace, leftarrow, rightarrow];
            if ~obj.istest
                obj.setup_keylist(keylist);
            else
                obj.setup_keylist([]);
            end
            if obj.istest
%                 PsychDebugWindowConfiguration;
            else
                HideCursor;
            end
            obj.eye.marker('start_exp');
            windowsize = [];
            if ~obj.istest
                obj.get_demo;
            else
                windowsize = [];%[0 0 800 600];
            end
            
            obj.setup_window([],windowsize,[0 0 0]);
            if obj.istest
                commandwindow;
            end
            obj.set_bandit;
            obj.set_cross;
%             obj.baseline_blink;
            if obj.istest ~= -1
                obj.instructions;
            end
            obj.run_exp(inf);
            obj.eye.marker('end_exp');
            obj.save;
            sca;
        end
        function save(obj)
            game = obj.game;
            gamepractice = obj.gamepractice;
            payment = obj.payment;
            subjectID = obj.subjectID;
            keyhistory = obj.keyhistory;
            bandit_color = obj.bandit_color;
            time = obj.time;
            markerlist = obj.eeg.markerlist;
            markers = obj.eeg.markers;
            calibration = obj.eye.calibration;
            save(fullfile(obj.path.savepath, [obj.filename '_behavior_' num2str(obj.subjectID), '_' obj.time.starttime]), ...
                'game','gamepractice','payment','subjectID','keyhistory', ...
                'bandit_color','time','markerlist','markers','calibration');
        end
        function set_taskParameter(obj)
            obj.game = obj.get_taskParameter(1,2);
            obj.gamepractice = obj.get_taskParameter(1,1,10);
        end
        function set_bandit(obj)
            bandit_color = obj.bandit_color;
            w = 80 * obj.window.scalefactor;
            h = 60 * obj.window.scalefactor;
            w_lever = 80 * obj.window.scalefactor;
            h_lever = 60 * obj.window.scalefactor;
            pos_lever = min([obj.game.neg])/2;
            penwidth = 5 * obj.window.scalefactor;
            dotradius = 30 * obj.window.scalefactor;
            font_bandit = round(40 * obj.window.scalefactor);
            horizon = min([obj.game.gameLength]);
            ban_L_s = bandit(obj.window);
            ban_L_s.setup(w,h,w_lever,h_lever,pos_lever,penwidth,dotradius,horizon,'left', font_bandit, bandit_color);
            ban_R_s = bandit(obj.window);
            ban_R_s.setup(w,h,w_lever,h_lever,pos_lever,penwidth,dotradius,horizon,'right', font_bandit, bandit_color);
            
            horizon = max([obj.game.gameLength]);
            ban_L_l = bandit(obj.window);
            ban_L_l.setup(w,h,w_lever,h_lever,pos_lever,penwidth,dotradius,horizon,'left', font_bandit, bandit_color);
            ban_R_l = bandit(obj.window);
            ban_R_l.setup(w,h,w_lever,h_lever,pos_lever,penwidth,dotradius,horizon,'right', font_bandit, bandit_color);
            bgaplen = 0.1;
            top = 0.3;
            ban_L_s.settppos(0.5 - bgaplen, top);
            ban_R_s.settppos(0.5 + bgaplen, top);
            ban_L_l.settppos(0.5 - bgaplen, top);
            ban_R_l.settppos(0.5 + bgaplen, top);
            obj.ban_L_s = ban_L_s;
            obj.ban_L_l = ban_L_l;
            obj.ban_R_s = ban_R_s;
            obj.ban_R_l = ban_R_l;
        end
        function set_cross(obj)
            linewidth = 4 * obj.window.scalefactor;
            size = 20 * obj.window.scalefactor;
            color = obj.color.AZred;
            crosscenter = [obj.window.center.x, obj.ban_L_s.tp_top + obj.ban_L_s.h * obj.ban_L_s.pos_lever];
            fixcross = fixedcross(obj.window);
            fixcross.setup(size, linewidth, color, crosscenter);
            obj.fixcross = fixcross;
        end
        function game = get_taskParameter(obj, R, nfold, nSample)
            if nargin < 4
                nSample = [];
            end
            sig_risk = 8;
            neg = 4;
            % \mu
            var(1).x = [40 60];
            var(1).type = 1;
            % main bandit number
            var(2).x = [1 2];
            var(2).type = 2;
            % \delta \mu
            var(3).x = [-30 -20 -12 -8 -4 4 8 12 20 30];
            var(3).type = 1;
            % game length
            var(4).x = [5 10];
            var(4).type = 2;
            % ambiguity condition
            var(5).x = [1 2 2 3];
            var(5).type = 1;
            [var2, T, N] = counterBalancer(var, R);
            mainBanMean = var2(1).x_cb;
            mainBan = var2(2).x_cb;
            deltaMu = var2(3).x_cb;
            gameLength = var2(4).x_cb;
            ambCond = var2(5).x_cb;
            for j = 1:T
                game(j).neg = neg;
                game(j).sig_risk = sig_risk;
                game(j).gameLength = gameLength(j);
                game(j).displaytime = 0.05 * ones(gameLength(j),1);
                game(j).displaytime(gameLength(j)) = 0.2;
                game(j).delaykeytime = zeros(gameLength(j),1);
%                 game(j).delaykeytime(neg+1) = 2.0;
                game(j).horizontime = 0;
                switch ambCond(j)
                    case 1        
                        r = randi(4);
                        switch r
                            case 1
                                nForced = [1 1 1 2];
                            case 2
                                nForced = [1 1 2 1];
                            case 3
                                nForced = [1 2 1 1];
                            case 4
                                nForced = [2 1 1 1];
                        end
                    case 2
                        r = randi(6);
                        switch r
                            case 1
                                nForced = [1 1 2 2];
                            case 2
                                nForced = [1 2 1 2];
                            case 3
                                nForced = [2 1 1 2];
                            case 4
                                nForced = [2 1 2 1];
                            case 5
                                nForced = [2 2 1 1];
                            case 6
                                nForced = [1 2 2 1];
                        end
                    case 3
                        r = randi(4);
                        switch r
                            case 1
                                nForced = [2 2 2 1];
                            case 2
                                nForced = [2 2 1 2];
                            case 3
                                nForced = [2 1 2 2];
                            case 4
                                nForced = [1 2 2 2];
                        end
                    case inf
                        r = randi(2);
                        switch r
                            case 1
                                nForced = [1 1 1 2];
                            case 2 
                                nForced = [2 2 2 1];
                        end
                end
                game(j).nForced = nForced;
                game(j).forced = nForced;
                game(j).forced(neg+1:gameLength(j)) = 0;
                game(j).nfree = [gameLength(j) - neg];
                if mainBan(j) == 1
                    mu(1) = mainBanMean(j);
                    mu(2) = [mainBanMean(j) + deltaMu(j)];
                elseif mainBan(j) == 2
                    mu(2) = mainBanMean(j);
                    mu(1) = [mainBanMean(j) + deltaMu(j)];
                end
                game(j).mean = [mu(1); mu(2)];
                game(j).rewards = ...
                    [(round(randn(gameLength(j),1)*sig_risk + mu(1)))'; ...
                    (round(randn(gameLength(j),1)*sig_risk + mu(2)))'];
                ind99 = game(j).rewards > 99;
                game(j).rewards(ind99) = 99;
                ind01 = game(j).rewards < 1;
                game(j).rewards(ind01) = 1;
                game(j).gID = j;
            end
            gd0 = game;
            if nfold > 1
                for ni = 1:(nfold-1)
                    gd = gd0;
                    for j = 1:length(gd)
                        mu = gd(j).mean;
                        gd(j).rewards(:,neg+1:end) = ...
                            [(round(randn(gd(j).nfree,1)*sig_risk + mu(1)))'; ...
                            (round(randn(gd(j).nfree,1)*sig_risk + mu(2)))'];
                        ind99 = gd(j).rewards > 99;
                        gd(j).rewards(ind99) = 99;
                        ind01 = gd(j).rewards < 1;
                        gd(j).rewards(ind01) = 1;
                    end
                    game = [game gd];
                end
            end
            flag = true;
            while flag
                % scramble games
                game = game(randperm(length(game)));
                % check to make sure whether no repeats within N trials of each other
                N = 5;
                gp = zeros(N, length(game));
                gID = [game.gID];
                for i = 1:N
                    gp(i,1:length(gID)-i) = gID(i+1:length(gID));
                end
                matchID = sum(repmat(gID, [N 1]) == gp);
                flag = sum(matchID) > 0;
            end
            if ~isempty(nSample)
                game = game(1:nSample);
            end
        end
        function [key,reward,ttime] = run_trial(obj,rL,rR,forced,ban_L,ban_R,displaytime, delaykeytime)
            if nargin < 8
                delaykeytime = 0;
            end
            if nargin < 7
                displaytime = 0;
            end
            leftkeys = KbName('leftarrow');
            rightkeys = KbName('rightarrow');
            switch forced
                case 1
                    ban_L.draw(0);
                    ban_R.draw(0,'forbid');
                    ttime.timeBanditOn = obj.flip;
                    obj.eye.marker('bandit_on');
                    obj.eeg.marker(obj.eeg.markers.bandit_on);
                    validkeys = leftkeys;
                case 2
                    ban_L.draw(0,'forbid');
                    ban_R.draw(0);
                    ttime.timeBanditOn = obj.flip;
                    obj.eye.marker('bandit_on');
                    obj.eeg.marker(obj.eeg.markers.bandit_on);
                    validkeys = rightkeys;
                case 0
                    ban_L.draw(0);
                    ban_R.draw(0);
                    ttime.timeBanditOn = obj.flip;
                    obj.eye.marker('bandit_on');
                    obj.eeg.marker(obj.eeg.markers.bandit_on);
                    validkeys = [leftkeys, rightkeys];
                otherwise
                    ban_L.draw(0,'forbid');
                    ban_R.draw(0,'forbid');
                    obj.eye.marker('horizon_on');
                    obj.eeg.marker(obj.eeg.markers.horizon_on);
                    ttime.horizonOn = obj.flip;
                    ttime.horizonOff = WaitSecs(displaytime);
                    key = nan;
                    reward = nan;
                    return;
            end            
            [KeyNum, ttime.timePressKey, ttime.deltatimePressKey] = obj.waitForInputrelease(validkeys);
            obj.eye.marker('key_down');
            obj.eeg.marker(obj.eeg.markers.keypress);
            if ismember(KeyNum, leftkeys)
                KeyNum = 1;
            elseif ismember(KeyNum, rightkeys)
                KeyNum = 2;
            end
            key = KeyNum;
            switch KeyNum
                case 1 % left
                    reward = rL;
                    ban_L.addreward(num2str(reward));
                    ban_R.addreward('XX');
                case 2 % right
                    reward = rR;
                    ban_L.addreward('XX');
                    ban_R.addreward(num2str(reward));
            end
            if delaykeytime
                ttime.KeypressHoldOff = WaitSecs(delaykeytime);
            else 
                ttime.KeypressHoldOff = 0;
            end
            if displaytime
                switch KeyNum
                    case 1
                        ban_L.draw(1,'forbid');
                        ban_R.draw(0,'forbid');
                    case 2
                        ban_L.draw(0,'forbid');
                        ban_R.draw(1,'forbid');
                    otherwise
                        ban_L.draw(0,'forbid');
                        ban_R.draw(0,'forbid');
                end
                ttime.timeRewardOn = obj.flip;
                obj.eeg.marker(obj.eeg.markers.rewardon);
                obj.eye.marker('reward_on');
                WaitSecs(0.05);
                ban_L.draw(0,'forbid');
                ban_R.draw(0,'forbid');
                ttime.timeRewardOn_up = obj.flip;
                if displaytime > 0.05
                    ttime.timeRewardOff = WaitSecs(displaytime-0.1);
                else
                    ttime.timeRewardOff = 0;
                end
            else
                timeRewardOn = inf;
            end
        end
        function run_game(obj, g, prac)
            if nargin < 3 || isempty(prac) || prac == 0
                prac = 0;
                game = obj.game(g);
            else
                game = obj.gamepractice(g);
            end
            glen = game.gameLength;
            neg = game.neg;
            switch glen
                case min([obj.game.gameLength])
                    ban_L = obj.ban_L_s;
                    ban_R = obj.ban_R_s;
                case max([obj.game.gameLength])
                    ban_L = obj.ban_L_l;
                    ban_R = obj.ban_R_l;
            end
            ban_L.flush;
            ban_R.flush;
            obj.eye.marker('start_cross');
            obj.eeg.marker(obj.eeg.markers.cross);
            obj.game(g).time.crossOn = obj.fixcross.drawAndflip;
            obj.game(g).time.crossOff = WaitSecs(1.0);
            obj.eye.marker('end_cross');
            obj.eeg.marker(obj.eeg.markers.cross);
            [~,~,ttime] = obj.run_trial([],[],inf,ban_L,ban_R,game.horizontime);
            obj.game(g).time.horizonOn = ttime.horizonOn;
            obj.game(g).time.horizonOff = ttime.horizonOff;
            for i = 1:glen
                forced = game.forced(i);
                rL = game.rewards(1,i);
                rR = game.rewards(2,i);
                displaytime = game.displaytime(i);
                delaykeytime = game.delaykeytime(i);
                obj.eye.marker('start_trial');
                obj.eeg.marker(obj.eeg.markers.starttrial);
                [key,reward,ttime] = obj.run_trial(rL,rR,forced,ban_L,ban_R, displaytime, delaykeytime);
                obj.eye.marker('end_trial');
                obj.eeg.marker(obj.eeg.markers.endtrial);
                if prac == 0
                    obj.game(g).key(i) = key;
                    obj.game(g).reward(i) = reward;
                    obj.game(g).time.trial(i) = ttime;
                    obj.game(g).correct(i) = reward == max(rL, rR);
                else
                    obj.gamepractice(g).key(i) = key;
                    obj.gamepractice(g).reward(i) = reward;
                    obj.gamepractice(g).time.trial(i) = ttime;
                    obj.gamepractice(g).correct(i) = reward == max(rL, rR);
                end
            end
%             obj.run_trial([],[],inf,ban_L,ban_R,0.1);
        end
        function run_exp(obj, maxtimeallowed)
            obj.time.maxtimeallowed = maxtimeallowed;
            obj.time.startclock = clock;
            obj.eye.marker('start_task');
            nBlocks = 4;
            if obj.istest
                gamelength = 4;
            else
                gamelength = length(obj.game);
            end
            gamestandard = gamelength;
            gamesperblock = gamestandard / nBlocks;
            reward = zeros(gamelength,1);
            g = 0; % game number
            b = 0; % block number
            startblock = 1;
            mtime = etime(clock, obj.time.startclock)/60;
            iscorrect = [];
            while (b <= nBlocks) && g < gamelength && mtime < obj.time.maxtimeallowed
                g = g + 1;
                if g == startblock
                    b = b + 1;
                    obj.talkAndflip(['Beginning block ' num2str(b) '\n\nPress space to begin']);
                    obj.waitForInputrelease(KbName('space'));
                    leftarrow = KbName('leftarrow');
                    rightarrow = KbName('rightarrow');
                    keylist = [leftarrow, rightarrow];
                    if ~obj.istest
                        obj.setup_keylist(keylist);
                    end
                    endblock = startblock + gamesperblock - 1;
                end
                obj.eye.marker('start_game');
                obj.run_game(g);
                obj.eye.marker('end_game');
                if obj.game(g).nfree == 6
                    iscorrect(g) = obj.game(g).correct(10);
                else
                    iscorrect(g) = nan;
                end
                if g == endblock
                    obj.talkAndflip(['End of block ' num2str(b) '\n\nPress space to continue.']);
                    space = KbName('space');
                    if ~obj.istest
                        obj.setup_keylist(space);
                    end
                    obj.waitForInputrelease(KbName('space'));
                    startblock = endblock + 1;
                end
                mtime = etime(clock, obj.time.startclock)/60;
                obj.time.tasktime = mtime;
                obj.save;
            end
            obj.time.tasktime = mtime;
            obj.eye.marker('end_task');
            obj.talkAndflip(['Congratulations! You have finished the task! \n\nPress q to exit.']);
%             obj.waitForInputrelease(KbName('space'));
            ac_p = nanmean(iscorrect);
            obj.payment.accuracyduringtask = ac_p;
            mm = obj.calcreward(ac_p);
            obj.payment.money = mm;
            if obj.ispay
            disp(sprintf('You earned a total of %.2f dollars', mm + obj.payment.flat));
            obj.talkAndflip(sprintf('You earned a total of %d dollars\n press q to exit.', mm + obj.payment.flat));
            end
            obj.setup_keylist([]);
            obj.waitForInputrelease(KbName('q'));
        end
        function m = calcreward(obj, p)
%             if p <= 0.5
%                 m = 0;
%             elseif p > 0.5 & p <= 0.65
%                 m = 0 + floor(7*(p-0.5)/0.15);
%             elseif p > 0.65 & p <= 0.75
%                 m = 7 + floor(4*(p-0.65)/0.1);                
%             elseif p > 0.75 & p <= 0.9
%                 m = 11 + floor(4*(p-0.75)/0.15);
%             else
%                 m = 15;
%             end
              m = round(obj.ispay * p.^2,2);
        end
        function instructions(obj)
            obj.instructionList;
            iStr = obj.iStr;
            ev = obj.iEv;
            
            endFlag = false;
            count = 1;
                ban_L10 = obj.ban_L_l;
                ban_R10 = obj.ban_R_l;
                ban_L5 = obj.ban_L_s;
                ban_R5 = obj.ban_R_s;
            bgaplen = 0.1;
            top = 0.3;
            ban_L10.settppos(0.5 - bgaplen, top);
            ban_R10.settppos(0.5 + bgaplen, top);
            ban_L5.settppos(0.5 - bgaplen, top);
            ban_R5.settppos(0.5 + bgaplen, top);
            while ~endFlag
                [A, B] = Screen('WindowSize', obj.window.id);
                
                
                ef = false;
                fontins = ceil(obj.font.fontsize * obj.window.scalefactor);
                                        obj.talk([count length(iStr)],'pagenumber',fontins);

                switch ev{count}
                    
                    case 'blank' % blank screen
                         obj.talk(iStr{count},'instructions', fontins);                         obj.talkAndflip([],'pageturner', fontins);
                        
                    case 'bandits' % bandits example
                        
                        ban_L10.flush;
                        ban_R10.flush;
                        
                        ban_L10.draw(0);
                        ban_R10.draw(0);
                        
                        obj.talk(iStr{count},'instructions', fontins);                         obj.talkAndflip([],'pageturner', fontins);
                        
                    case 'realBandits' % bandits example
                        
                         obj.talk(iStr{count},'instructions', fontins);                         obj.talkAndflip([],'pageturner', fontins);
                        
                        
                    case 'bandits_lever'
                        
                        ban_L10.flush;
                        ban_R10.flush;
                        ban_L10.draw(1);
                        ban_R10.draw(0);
                        
                         obj.talk(iStr{count},'instructions', fontins);                         obj.talkAndflip([],'pageturner', fontins);
                        
                    case 'L_77'
                        
                        ban_L10.flush;
                        ban_R10.flush;                     
                        ban_L10.addreward('77');
                        
                        ban_L10.draw(1);
                        ban_R10.draw(0);
                        
                         obj.talk(iStr{count},'instructions', fontins);                         obj.talkAndflip([],'pageturner', fontins);
                        
                    case 'L_77beep'
                        
                        
                        ban_L10.flush;
                        ban_R10.flush;
                        ban_L10.addreward('77');
                        
                        ban_L10.draw(1);
                        ban_R10.draw(0);
                        
                         obj.talk(iStr{count},'instructions', fontins);                         obj.talkAndflip([],'pageturner', fontins);
                        
                    case 'L_85beep'
                        
                        ban_L10.flush;
                        ban_R10.flush;
                        ban_L10.addreward('85');
                        
                        ban_L10.draw(1);
                        ban_R10.draw(0);
                        
                         obj.talk(iStr{count},'instructions', fontins);                         obj.talkAndflip([],'pageturner', fontins);
                        
                    case 'L_20beep'
                        
                        ban_L10.flush;
                        ban_R10.flush;
                        ban_L10.addreward('20');
                        
                        ban_L10.draw(1);
                        ban_R10.draw(0);
                        
                         obj.talk(iStr{count},'instructions', fontins);                         obj.talkAndflip([],'pageturner', fontins);
                        
                    case 'R_52'
                        
                        ban_L10.flush;
                        ban_R10.flush;
                        ban_R10.addreward('52');
                        
                        ban_L10.draw(0);
                        ban_R10.draw(1);
                        
                         obj.talk(iStr{count},'instructions', fontins);                         obj.talkAndflip([],'pageturner', fontins);
                        
                    case 'R_56'
                        
                        ban_L10.flush;
                        ban_R10.flush;
                        ban_R10.addreward('52');
                        ban_R10.addreward('56');
                        
                        ban_L10.draw(0);
                        ban_R10.draw(1);
                        
                         obj.talk(iStr{count},'instructions', fontins);                         obj.talkAndflip([],'pageturner', fontins);
                        
                    case 'R_45'
                        
                        ban_L10.flush;
                        ban_R10.flush;
                        
                        ban_R10.addreward('52');
                        ban_R10.addreward('56');
                        ban_R10.addreward('45');
                        
                        ban_L10.draw(0);
                        ban_R10.draw(1);
                        
                         obj.talk(iStr{count},'instructions', fontins);                         obj.talkAndflip([],'pageturner', fontins);

                        
                    case 'R_all'
                        
                        ban_L10.flush;
                        ban_R10.flush;
                        
                        ban_R10.addreward('52');
                        ban_R10.addreward('56');
                        ban_R10.addreward('45');
                        ban_R10.addreward('39');
                        ban_R10.addreward('51');
                        ban_R10.addreward('50');
                        ban_R10.addreward('43');
                        ban_R10.addreward('60');
                        ban_R10.addreward('55');
                        ban_R10.addreward('45');
                        
                        ban_L10.draw(0);
                        ban_R10.draw(1);
                        
                         obj.talk(iStr{count},'instructions', fontins);                         obj.talkAndflip([],'pageturner', fontins);
                        
                        
                        
                    case 'bandits5' % bandits example
                        ban_L5.flush;
                        ban_R5.flush;
                        
                        ban_L5.draw(0);
                        ban_R5.draw(0);
                        
                         obj.talk(iStr{count},'instructions', fontins);                         obj.talkAndflip([],'pageturner', fontins);
                        
                    case 'forcedL1'
                        
                        ban_L10.flush;
                        ban_R10.flush;
                        
                        ban_L10.draw(0);
                        ban_R10.draw(0,'forbid');
                        
                         obj.talk(iStr{count},'instructions', fontins);                         obj.talkAndflip([],'pageturner', fontins);
                        
                    case 'forcedR2'
                        
                        ban_L10.flush;
                        ban_R10.flush;
                        
                        ban_L10.addreward('77');
                        ban_R10.addreward('XX');
                        
                        ban_L10.draw(0,'forbid');
                        ban_R10.draw(0);
                        
                         obj.talk(iStr{count},'instructions', fontins);                       
                         obj.talkAndflip([],'pageturner', fontins);
                    case 'cross'
                        obj.fixcross.draw;
                         obj.talk(iStr{count},'instructions', fontins);                       
                         obj.talkAndflip([],'pageturner', fontins);
                    case '4t'
                         ban_L10.flush;
                        ban_R10.flush;
                        
                        ban_L10.addreward('77');
                        ban_L10.addreward('XX');
                        ban_L10.addreward('65');
                        ban_L10.addreward('67');
                        
                        ban_R10.addreward('XX');
                        ban_R10.addreward('52');
                        ban_R10.addreward('XX');
                        ban_R10.addreward('XX');
                        
                        ban_L10.draw(0);
                        ban_R10.draw(0);
                         obj.talk(iStr{count},'instructions', fontins);          
                         obj.talkAndflip([],'pageturner', fontins);
                    case 'free'
                        
                        ban_L10.flush;
                        ban_R10.flush;
                        
                        ban_L10.addreward('77');
                        ban_L10.addreward('XX');
                        ban_L10.addreward('65');
                        ban_L10.addreward('67');
                        
                        ban_R10.addreward('XX');
                        ban_R10.addreward('52');
                        ban_R10.addreward('XX');
                        ban_R10.addreward('XX');
                        
                        ban_L10.draw(0);
                        ban_R10.draw(0);
%                         
%                         obj.Beep;
%                         obj.gocue;
                         obj.talk(iStr{count},'instructions', fontins);  
                         obj.talkAndflip([],'pageturner', fontins);
                        
                    case 'exampleplay'
                        Screen('FillRect',obj.window.id,[0 0 0]);
                        Screen('Flip',obj.window.id);
                        for g = 1:5
                            obj.run_game(g,1);
                        end
                         obj.talk(iStr{count},'instructions', fontins);                       
                         obj.talkAndflip([],'pageturner', fontins);
                end
                
                keyspace = KbName('space');
                if ismac
                    keybackspace = KbName('delete');
                else
                    keybackspace =  KbName('backspace');
                end
                % press button to move on or not
                if ~ef
                    flag = 1;
                    while flag
                    [KeyNum, when] = obj.waitForInputrelease([keyspace keybackspace],Inf);
                    
                    switch KeyNum
                        
                        case keyspace % go forwards
                            count = count + 1;
                            if count > length(iStr)
                                endFlag = true;
                            end
                            flag = 0;
                        case keybackspace % go backwards
                            ef = true;
                            count = count - 1;
                            if count < 1
                                count = 1;
                            end
                            endFlag = false;
                            flag = 0;
%                         case 5 % skip through
%                             endFlag = true;
%                             
%                         case 6 % quit
%                             sca
%                             error('User requested escape!  Bye-bye!');
                        otherwise
                            flag =1;
                    end
                    end
                end
            end
            WaitSecs(0.1);
        end
        function instructionList(obj)
            
            i = 0;
            
               % instructions without sound
                i=i+1; ev{i} = 'blank';      iStr{i} = 'Welcome! Thank you for volunteering for this experiment.';
                if obj.ispay
                    i=i+1; ev{i} = 'blank';      iStr{i} = 'This is a paid experiment. You will play a gambling game and the amount we pay you will be based on your performance. Please read through this instruction carefully.';
                end
                %                 i=i+1; ev{i} = 'blank';      iStr{i} = 'In this experiment you will do two things.  First you will play a gambling task in which you will make choices between two options. This will take about 30 minutes.  Next you will fill in a personality questionnaire.  This will take about 10 minutes.  When you''re done please return to the main lab for debriefing.';
                i=i+1; ev{i} = 'realBandits';iStr{i} = 'In this experiment - the gambling task - we would like you to choose between two one-armed bandits of the sort you might find in a casino.';
                i=i+1; ev{i} = 'bandits';    iStr{i} = 'The one-armed bandits will be represented like this';
                i=i+1; ev{i} = 'bandits_lever';iStr{i} = 'Every time you choose to play a particular bandit, the lever will be pulled like this ...';
                i=i+1; ev{i} = 'L_77';       iStr{i} = '... and the payoff will be shown like this.  For example, in this case, the left bandit has been played and is paying out 77 points. ';
                %i=i+1; ev{i} = 'L_77';       iStr{i} = 'The points you earn by playing the bandits will be converted into REAL money at the end of the experiment, so the more points you get, the more money you will earn.';
%                 i=i+1; ev{i} = 'L_77';       iStr{i} = 'The points you earn by playing the bandits will be converted into a reward of time during the experiment, so the more points you get, the faster you will get out of this room and get your credits.';
                i=i+1; ev{i} = 'L_77';       iStr{i} = 'Your goal is to maximize the points you get through out the task. Try your best to get as many points as you can!';
                
                i=i+1; ev{i} = 'bandits';    iStr{i} = 'During one game, each bandit tends to pay out about the same amount of reward on average, but there is variability in the reward on any given play.  ';
                i=i+1; ev{i} = 'R_52';       iStr{i} = 'For example, the average reward for the bandit on the right might be 50 points, but on the first play we might see a reward of 52 points because of the variability ...';
                i=i+1; ev{i} = 'R_56';       iStr{i} = '... on the second play we might get 56 points ... ';
                i=i+1; ev{i} = 'R_45';       iStr{i} = '... if we open a third box on the right we might get 45 points this time ... ';
                i=i+1; ev{i} = 'R_all';      iStr{i} = '... and so on, such that if we were to play the right bandit 10 times in a row we might see these rewards ...';
                i=i+1; ev{i} = 'R_all';      iStr{i} = 'Both bandits will have the same kind of variability and this variability will stay constant throughout the experiment.';
                i=i+1; ev{i} = 'bandits';    iStr{i} = 'During one game, one of the bandits will always have a higher average reward and hence is the better option to choose on average.  ';
                i=i+1; ev{i} = 'bandits';    iStr{i} = 'On any trial you can only choose to play one of the two bandits and the number of trials in each game is determined by the height of the bandits.  For example, when the bandits are 10 boxes high, there are 10 trials in that game ... ';
                i=i+1; ev{i} = 'bandits5';   iStr{i} = '... when the stacks are 5 boxes high there are only 5 trials in the game.';
                i=i+1; ev{i} = 'forcedL1';   iStr{i} = 'The first 4 trials in each game are instructed trials. These instructed trials will be indicated by a green square inside the box we want you to open and you must press the button to choose this option in order to move on to see the reward and move on the next trial. For example, if you are instructed to choose the left box on the first trial, you will see this:';
                i=i+1; ev{i} = 'forcedR2';   iStr{i} = 'If you are instructed to choose the right box on the second trial, you will see this:';
                i=i+1; ev{i} = 'free';       iStr{i} =  'Once these instructed trials are complete, you will have a free choice between the two stacks that is indicated by two green squares inside the two boxes you are choosing between.';
%                 i=i+1; ev{i} = 'free';       iStr{i} =  'The reward will show up 2 seconds after you made your choice. This delay is to allow us to record your brain activity.';
                i = i+1; ev{i} = 'cross';       iStr{i} = ' Throughout the task we will be tracking your eyes. To help us better track your eyes, please stay in the chin rest throughout the task.  Each game begins with the presentation of a fixation cross like this for 1 second ... please try to stare at this cross while it is displayed.';
                i = i+1; ev{i} = 'forcedL1';     iStr{i} = 'After 1 second, the fixation cross will disappear, the bandits will appear and you are free to play the game. After the bandit shows up, feel free to look where you want to.';
%                 i = i+1; ev{i} = 'free';        iStr{i} = 'After 3 more seconds a GO cue will appear at which point you are free to choose between the two options';
%                 i = i+1; ev{i} = '4t';     iStr{i} = 'In a 10-trials game, the remaining 5 choices can be made quickly.';
                i=i+1; ev{i} = 'blank';      iStr{i} = 'So ... to be sure that everything makes sense let''s work through a few example games ... \n Press <- to play the left bandit \n Press -> to play the right bandit';
                i=i+1; ev{i} = 'exampleplay';iStr{i} = 'Great job! Now you know the rule!';
                i=i+1; ev{i} = 'bandits';    iStr{i} = 'Just to repeat, to make your choice:\n Press <- to play the left bandit \n Press -> to play the right bandit';
                i=i+1; ev{i} = 'blank';      iStr{i} = 'We want to see how well a human being can do in this task, try your best to get as many points as you can!';
                i=i+1; ev{i} = 'blank';      iStr{i} = 'Press space when you are ready to begin. \nGood luck!';
                
                obj.iStr = iStr;
                obj.iEv = ev;
        end
    end
end