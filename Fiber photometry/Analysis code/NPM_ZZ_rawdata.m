%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by Zhenggang Zhu/Rong Gong

    clear all;
    load ZZColormaps;  

    %% Switch analysis between GRAB-DA and GCaMP 
    fit_exp  = 2; %% fit_exp = 2 for GRAB-DA: multiple 5-min chunks; fit_exp = 0 for GCaMP 

    %% Switch analysis between whole or seperate two blocks analysis
    Period_show = 3; %% Period_show = 3 for the whole session; Period_show = 1:2 for seperate two blocks

    %% keep below Para as default
    Load_data = 1; 
    Beh_var = 'Lick1'; % Behavioral inputs 
    Beh_var_0 = 'Lick0';
    Beh_edit = 0; % Set to 0
    FP.min_lick_interval = 5; 
    FP.min_lick_interval2 = FP.min_lick_interval; 
    Bout_criteria = 0.2; 
    z_score = 2;
    Halves = [0];% 0 for 0-2hr; 
    Half = [0];
    Time_boundary = 3600*2; % for 2hr recording
    fix_singlespout = 0;
    Detectionerror = 0; 
    mergelick = 0; 
    basal_time = 5;
    Ratio_post = 4;
    odor_time = basal_time*Ratio_post;
    control_time = [-basal_time,-basal_time+2]; 
    plot_415 = 0; 
    threshold_415 = 0; 
    offset = 0;       
    heatmap = 1;
    F_470 =  4; 
    F_415 =  3; 
    Nan_Replace = -100;
    Zoom_415 = 1;
    intervalLength = 120*1;  % Length of each interval in seconds
    False_time = [];
    
        %% Reload and recompute
        Lickrt_S=[];
        Lickrt_No=[];
        avgS=[];
        avgNo=[];
        boutL_S=[];
        boutL_No=[];
        boutN_S=[];
        boutN_No=[];
        ILI_OFF=[];
        ILI_S=[];

            %% import the raw signals
            % NOTE: Current Folder must contain photometry data
            % Define the fiberphotometry data
            filePattern = 'FPData202*.csv';
            files = dir(fullfile(filePattern));
            FP.raw = readmatrix(files.name); %imports raw data

            filePattern = 'stimulation*.csv';
            files = dir(fullfile(filePattern));
            if isempty(files)
                FP.stim = 10;
            else
                stim = readtable(files.name); %imports beh data
                FP.stim = stim{:,end};
            end
            
            FP.raw = FP.raw(2:end,:); %removes initialization
            FP.n_channels = length(unique(FP.raw(:,3))); %extracts number of channels (ie 415, 470, 560)

            %ensure equal number of frames for each channel
            while mod(length(FP.raw),FP.n_channels) ~= 0
                FP.raw(end,:) = [];
            end

            Time = FP.raw(FP.raw(:,3)==2,2);
            Duration = max(Time)-min(Time);

            %% when the licking data is not match to the NPM in recent recordings
            filePattern = 'Delta*.csv';
            files = dir(fullfile(filePattern));
            if ~isempty(files)
                DeltaT = readmatrix(files.name);
            else
                DeltaT = 0;
            end
            
            %%create new array with deinterleaved data
            Chn = size(FP.raw,2);
            FP.data(:,1) = FP.raw(FP.raw(:,3)==2,2); %system time when 470 LED is on
 
            %% 
            filePattern = 'LickAndFeed*.csv';
            files = dir(fullfile(filePattern));
            FP.beh0 = readtable(files.name); %imports beh data

            condition = strcmp(FP.beh0{:, 1}, Beh_var);  % Create a logical array
            condition_0 = strcmp(FP.beh0{:, 1}, Beh_var_0);

            %% 
            if size(nonzeros(condition),1)>1 && size(nonzeros(condition_0),1)>1 && mergelick >0 
                % Find all rows where 'Lick' contains 'lick0' and replace with 'lick1'
                FP.beh0.Event = strrep(FP.beh0.Event, 'Lick0', 'Lick1');
                disp('merge licks')
                condition = strcmp(FP.beh0{:, 1}, Beh_var);  % Create a logical array
                condition_0 = strcmp(FP.beh0{:, 1}, Beh_var_0);
            end

            %% Change of the sync time when using the new workflow
            str = fileread(files.name);
            substr = 'CompTime';
            if contains(str,substr)==1
                SynCol = 4; %% use the 4th column to synchronize for the CompTime 
            else
                SynCol = 2;
            end

            filePattern = 'FPData_CompTime*.csv';
            files_old = dir(fullfile(filePattern));  %% exsited in old data
            if isempty(files_old)
%                 FP.timesync = FP.raw(:,4);
                FP.timesync = FP.raw(:,SynCol);
                FP.data(:,2) = FP.raw(FP.raw(:,3)==2,6); %photometry data when 470 LED is on
                FP_415 = FP.raw(FP.raw(:,3)==1,6);
                FP.data(1:length(FP_415),3) = FP_415; %photometry data when 415 LED is on 
            else 
                FP.data(:,2) = FP.raw(FP.raw(:,3)==2,Chn); %photometry data when 470 LED is on
                FP.data(:,3) = FP.raw(FP.raw(:,3)==1,Chn); %photometry data when 415 LED is on
                FP.timesync = readmatrix(files_old.name); %imports raw data
            end
        
            %% 
            FP.data(:,3) = FP.data(:,3) * Zoom_415;

            %% 
            FP.fr = 1/mean(diff(FP.data(:,1))); % calculate framerate

            if Beh_edit==0
                FP.beh = FP.beh0{condition, 3};  % Extract values from the third column
                condition_feed = logical(mod(condition + 1, 2));
                FP.feed = FP.beh0{condition_feed, 3};  % Extract feed values
                %%
                FP.beh_0 = FP.beh0{condition_0, 3};  % Extract values from the third column
                condition_feed_0 = logical(mod(condition_0 + 1, 2));
                FP.feed_0 = FP.beh0{condition_feed_0, 3};  % Extract feed values                
                
            else
                FP.beh = readmatrix('Lick_data_sanitized.csv'); %imports behavior timestamps only for mice1 day1
                FP.beh_0 = readmatrix('Lick_data_sanitized.csv'); %imports behavior timestamps only for mice1 day1
                
                disp ('Lick_data_sanitized');   
                FP.feed = FP.beh(1:3:end,1);  % Extract feed values
                FP.feed_0 = FP.beh(1:3:end,1);  % Extract feed values                
     
            end
    
            %% correcting for photobleaching
            %%
            figure
            tiledlayout(4,1)
            ax1 = nexttile;  
            %% 
            temp_x = FP.raw(FP.raw(:,3)==2,1); %use frame number as temporary x variable for fitting to avoid sig figs issue with MATLAB
%           
            %% 
            len_FP_data = size(FP.data, 1);
            while length(temp_x) < len_FP_data
                % Add zeros to temp_x to match the length of FP.data(:,3)
                temp_x = [temp_x; temp_x(end) + 3];
            end

             if fit_exp == 0
                FP.fit2 = robustfit(FP.data(:,3),FP.data(:,2),'bisquare'); %scale using robust fit -- note you can "tune" this function -- but the default is often groovy enough
                FP.lin_fit = FP.data(:,3)*FP.fit2(2)+FP.fit2(1); %save resulting scaled fit
                disp('Fit: Scaled 415');

            elseif fit_exp == 1
                FP.fit1 = fit(temp_x,FP.data(:,3),'exp2'); %fit raw isosbestic with biexponential exp2
                FP.fit2 = robustfit(FP.fit1(temp_x),FP.data(:,2),'bisquare'); %scale using robust fit -- note you can "tune" this function -- but the default is often groovy enough
                FP.lin_fit = FP.fit1(temp_x)*FP.fit2(2)+FP.fit2(1); %save resulting scaled fit
                disp('Fit: exp2')
           %% 
            elseif fit_exp == 2 %% GRAB DA
                % Define the size of each chunk
                chunkSize = round(300*FP.fr); %% 5 min
                % Get the number of chunks
                numChunks = ceil(size(FP.data, 1) / chunkSize);
                % Preallocate arrays for storing results
                FP.lin_fit = zeros(size(FP.data, 1), 1);

                for i = 1:numChunks
                    % Define the range for the current chunk
                    idxStart = (i-1)*chunkSize + 1;
                    idxEnd = min(i*chunkSize, size(FP.data, 1));
                    range = idxStart:idxEnd;
                    % Perform the fits for the current chunk
                    temp_x_chunk = temp_x(range);
                    FP.data_chunk = FP.data(range, :);
                    % Fit and scale
                     FP.fit2 = robustfit(FP.data_chunk(:,3), FP.data_chunk(:,2), 'bisquare',[],'off'); % Scale using robust fit, no constant term
                    % Save the resulting scaled fit
                    FP.lin_fit(range) = FP.data_chunk(:,3)*FP.fit2;
                end
                disp('Fit: Scaled 415 for each chunk')

            end

            plot(FP.data(:,3),'LineWidth',2) %plot raw 415 FP.lin_fit_415
            hold on
            Ratio = mean(FP.data(:,3))/mean(FP.data(:,2));
            plot(FP.data(:,2)*Ratio,'k') %plot raw 415
            hold on
            title('415 data with scaled 470 data(black)')
            xlabel('frame number')
            ylabel('F (mean pixel value')
            
            %% also analyze 415 data 
            FP.data(:,5) = FP.lin_fit; %divide 415 data by scaled fit
            %% analyze 470 data
            FP.data(:,4) = FP.data(:,2)./(FP.lin_fit); %divide 470 data by scaled fit

            ax2 = nexttile;
            plot(FP.data(:,2),'k') %plot raw 470
            hold on
            plot(FP.lin_fit,'LineWidth',1) %overlay fit
            box off
            title('Scaled Piecewise linear interpolation fit over raw 470 data(black)')
            xlabel('frame number')
            ylabel('F (mean pixel value')

            ax3 = nexttile;
            plot(FP.data(:,4),'b','LineWidth',0.3); hold on;
            xlabel('frame number')
            ylabel('normalized F')
%             set(gca,'YTickLabel','', 'YTick', [])
            title('normalized F')
            box off
            set(gcf, 'color', [1 1 1])
            % hold on
            %% convert behavior timestamps (in computer time) to photometry time
            beh_norm = [];
            error = 0;
            %find nearest photometry frame using computer timestamps
            for i = 1:length(FP.beh(:,1))
                if ~isempty(find(FP.timesync(:,1)>=FP.beh(i),1))
                    beh_norm(i) = find(FP.timesync(:,1)>=FP.beh(i),1); %find the nearest larger photometry frame using computer timestamps
                else
                    disp('time sync error1')
                    error = 1;
                end
            end
%            %find nearest photometry frame using computer timestamps
%             for i = 1:length(FP.feed(:,1))
%                 if ~isempty(find(FP.timesync(:,1)>=FP.feed(i),1))
%                     feed_norm(i) = find(FP.timesync(:,1)>=FP.feed(i),1); %find the nearest larger photometry frame using computer timestamps
%                 else
%                     disp('time sync error2')
%                     error = 1;
%                 end
%             end
%             %find nearest photometry frame using computer timestamps
%             for i = 1:length(FP.stim(:,1))
%                 if ~isempty(find(FP.timesync(:,1)>=FP.stim(i),1))
%                     stim_norm(i) = find(FP.timesync(:,1)>=FP.stim(i),1); %find the nearest larger photometry frame using computer timestamps
%                 else
%                     disp('time sync error3')
%                     error = 1;
%                 end
%             end
            
            
            if ~isempty(files_old)
                beh_norm = beh_norm(beh_norm>1); % sometimes the first Beh timestamps are not valid for analysis
                beh_norm = FP.timesync(beh_norm,2); %finish conversion to photometry frame
                beh_norm = beh_norm(beh_norm<length(FP.raw(:,2)));
                beh_norm = FP.raw(beh_norm,2); %convert to photometry time
                
                feed_norm = feed_norm(feed_norm>1); % sometimes the first Beh timestamps are not valid for analysis
                feed_norm = FP.timesync(feed_norm,2); %finish conversion to photometry frame
                feed_norm = feed_norm(feed_norm<length(FP.raw(:,2)));
                feed_norm = FP.raw(feed_norm,2); %convert to photometry time

                stim_norm = stim_norm(stim_norm>1); % sometimes the first Beh timestamps are not valid for analysis
                stim_norm = FP.timesync(stim_norm,2); %finish conversion to photometry frame
                stim_norm = stim_norm(stim_norm<length(FP.raw(:,2)));
                stim_norm = FP.raw(stim_norm,2); %convert to photometry time
            else
                beh_norm = beh_norm(beh_norm>1); % sometimes the first Beh timestamps are not valid for analysis
                beh_norm = beh_norm(beh_norm<length(FP.raw(:,2)));
                beh_norm = FP.raw(beh_norm,2); %%%%%%%%%%%convert to photometry time
                
                feed_norm = feed_norm(feed_norm>1); % sometimes the first Beh timestamps are not valid for analysis
                feed_norm = feed_norm(feed_norm<length(FP.raw(:,2)));
                feed_norm = FP.raw(feed_norm,2); %convert to photometry time
            end             

        %%  assign feeding to the laser on/off periods
            Feed_all = feed_norm - FP.raw(1,2) - DeltaT;             
            Beh_all = beh_norm - FP.raw(1,2)- DeltaT;   
            Lick_onid = [];% find which behaviors belongs to the on period;
            Lick_offid = [];% calculate mode(T/120), if it =
            Feed_onid = [];
            Feed_offid = [];
            Epoch = intervalLength; % duration of on/off in seconds
            for i = 1: length(Beh_all)
                if mod(floor(Beh_all(i)/Epoch),2) == 0
                    Lick_onid = [Lick_onid,i];
                else
                    Lick_offid = [Lick_offid,i];
                end
            end

            for i = 1: length(Feed_all)
                if mod(floor(Feed_all(i)/Epoch),2) == 0
                    Feed_onid = [Feed_onid,i];
                else
                    Feed_offid = [Feed_offid,i];
                end
            end

            Lick_allid = 1: length(Beh_all);    
            Feed_allid = 1: length(Feed_all);  
            Feed_info_all = Boutinfo(beh_norm(Lick_allid,:),feed_norm(Feed_allid,:),FP.min_lick_interval*1000);
            %% plot for laser stimulation
        %         figure 
            ax4 = nexttile;
            X = Feed_info_all.boutstart{1,1}- FP.raw(1,2);
            X1 = Feed_info_all.boutduration{1,1};
            for Tiii=1:length(X)
                rectangle('Position',[X(Tiii),7,X1(Tiii),1],'EdgeColor',[0.5 0.5 0.5],'facecolor',[0 0 0]);
            end
            hold on;

            %% add the opto on/off plot
            Total_duration = FP.raw(end,2)-FP.raw(1,2);
            Opto_stim = 0:intervalLength*2:Total_duration;
            X1 = intervalLength;
            for Tiii=1:length(Opto_stim)
            rectangle('Position',[Opto_stim(Tiii),6.1,X1,1],'EdgeColor',[1 1 1],'facecolor',[0 0 1]);
            end
            set(gca,'YTickLabel','', 'YTick', [])
            xlabel('Time (s)')
            ylabel('Bout & laser')
            box off
            xlim([0 Total_duration])
            set(gcf, 'color', [1 1 1])
            hold off
            saveas(gcf, 'Raw_Beh_F.fig');
            filename = 'licks.csv';
            csvwrite(filename,Beh_all);

            %%  set Time_boundary a option
            if ~isempty(Time_boundary)
                Beh_all = Beh_all(Beh_all<=Time_boundary);
                Feed_all = Feed_all(Feed_all<=Time_boundary);
                Opto_stim = Opto_stim(Opto_stim<=Time_boundary);
            end

            if ~isempty(False_time)
                Beh_all = Beh_all(Beh_all<=False_time(1)| Beh_all>=False_time(2));
                Feed_all = Feed_all(Feed_all<=False_time(1)|Feed_all>=False_time(2));
                Opto_stim = Opto_stim(Opto_stim<=False_time(1)|Opto_stim>=False_time(2));

           %% set new id to make sure these events are limited to the episodes
                Lick_onid = [];% find which behaviors belongs to the on period;
                Lick_offid = [];% calculate mode(T/120)
                Feed_onid = [];
                Feed_offid = [];
                feed_norm = [];       
                stim_norm = []; 
                beh_norm = []; 
                Epoch = intervalLength; % duration of on/off in seconds
                for i = 1: length(Beh_all)
                    if mod(floor(Beh_all(i)/Epoch),2) == 0
                        Lick_onid = [Lick_onid,i];
                    else
                        Lick_offid = [Lick_offid,i];
                    end
                end
    
                for i = 1: length(Feed_all)
                    if mod(floor(Feed_all(i)/Epoch),2) == 0
                        Feed_onid = [Feed_onid,i];
                    else
                        Feed_offid = [Feed_offid,i];
                    end
                end
    
                Lick_allid = 1: length(Beh_all);    
                Feed_allid = 1: length(Feed_all); 

                feed_norm = Feed_all + FP.raw(1,2) + DeltaT;            
                beh_norm = Beh_all + FP.raw(1,2) + DeltaT;  
                
            end
            %% lick to bout calculation
            Cons = 20;
            Lick_time = Beh_all*1000*1000/Cons;
            Feed_time = Feed_all*1000*1000/Cons;

            Cam_time = Total_duration*1000*1000/Cons;
            StimS = (Opto_stim')*1000*1000/Cons;
            StimE = (Opto_stim' + intervalLength)*1000*1000/Cons - 1;
            Stim_offS = StimE +1;            
            Stim_offE = StimE + intervalLength*1000*1000/Cons;
            loading_evt = 0;

            if Bout_criteria > 2

            %% add BoutL_off_lickF, BoutL_S_LickF for the analysis
                [BoutL_off_lickF, BoutL_S_LickF, Lickrt_S,Lickrt_No,avgS,avgNo,boutL_S,boutL_No,boutN_S,boutN_No,boutL_ST,boutL_NoT,ILI_OFF,ILI_S]= ...
                lickrate_2blocks(loading_evt,FP.min_lick_interval2,Lick_time,Feed_time,Cam_time,StimS,StimE,Stim_offS,Stim_offE);    
                Feed_info_all.boutstart_new = {[boutL_ST{1},boutL_NoT{1}]'};
                Feed_info_all.boutduration_new = [boutL_S{1},boutL_No{1}];
                saveas(gcf, ['Beh_lickrate_2blocks_', num2str(Half),'.fig']);

                %% plot for ISI
                % Example Data (Replace with Actual Data)
                ILI_cont = ILI_OFF{1}; % ILI data for contingent
                ILI_noncont = ILI_S{1}; % ILI data for noncontingent
                
                % Filter to ILIs less than 1 second
                ILI_cont = ILI_cont(ILI_cont > 0.08 & ILI_cont <= 1);
                ILI_noncont = ILI_noncont(ILI_noncont > 0.08 & ILI_noncont <= 1);
                
                % Density Fits for KDE
                [f_cont, xi_cont] = ksdensity(ILI_cont, 'Support', [0 1.01]); % Contingent
                [f_noncont, xi_noncont] = ksdensity(ILI_noncont, 'Support', [0 1.01]); % Noncontingent
                
                % Find Modes (Most Common Values)
                [~, idx_cont] = max(f_cont);
                mode_cont = xi_cont(idx_cont); % Most common value for ILI_cont
                [~, idx_noncont] = max(f_noncont);
                mode_noncont = xi_noncont(idx_noncont); % Most common value for ILI_noncont

            end

        for aa = Period_show  % on and off 
            if aa == 1
                Lick_id = Lick_onid;
                Feed_id = Feed_onid;
                disp('laser on');
            elseif aa == 2
                Lick_id = Lick_offid;
                Feed_id = Feed_onid;
                disp('laser off');
            elseif aa == 4
                Lick_id = Lick_allid;
                Feed_id = Feed_onid;
                disp('laser off');    
            else
                Lick_id = Lick_allid;
                Feed_id = Feed_onid;
                disp('All');        
            end

            FP.beh_norm = beh_norm(Lick_id,:);
            FP.feed_norm = feed_norm(Feed_id,:);
            %% Extract bouts information

            Feed_info = Boutinfo(FP.beh_norm,FP.feed_norm,FP.min_lick_interval*1000);
            FP.lick_bout = Feed_info.boutstart{1, 1};
            Boutduration = Feed_info.boutduration{1, 1};

            %% Analysis for behaviors
            bin = 1/FP.fr;  %% 
            interval = 1/FP.fr; %% 
            FP.bl = round(FP.fr*basal_time); %number of datapoints before event 
            FP.seg_dur = round(FP.fr*odor_time); %number of datapoints after event 
            counter = 1;
            Delete_bout = [];
            for i = 1:length(FP.lick_bout)
                temp = find(FP.data(:,1)>=FP.lick_bout(i),1);
                if ~isempty(temp)
                    if temp >= FP.bl && temp+FP.seg_dur <= length(FP.data)&& Boutduration(i)>Bout_criteria%ensure behavioral timepoints aren't too close to the beginning or end of a recording
%                         disp(Boutduration(i))
                        i;
                    else
                        Delete_bout = [Delete_bout,i];
                    end
                end

            end

            if ~isempty(False_time)
                Delete_bout_false = [] ;
                Delete_bout_false = find(FP.lick_bout>=False_time(1)+FP.data(1,1)&FP.lick_bout<=False_time(2)+FP.data(1,1));
                Delete_bout_false = Delete_bout_false';
                Delete_bout = unique([Delete_bout,Delete_bout_false]);
            end

            %% Z-score calculation
            timestamps = FP.lick_bout-FP.data(1,1);  % Replace with your actual timestamps
            trigger_times = timestamps; % behaviors;
            trigger_times(Delete_bout) = [];% behaviors;
            values = FP.data(:,4);
            values_415 = FP.data(:,5);
            %% find the non-behavioral baseline 
            wholeTimepoints = FP.data(:,1);  % Whole timepoints
            startBehaviors = Feed_info_all.boutstart{1, 1};  % Start of behavior timepoints
            endBehaviors = Feed_info_all.boutend{1, 1};  % End of behavior timepoints
            % Initialize a logical array to mark behavior intervals
            isBehaviorInterval = false(size(wholeTimepoints));
            % Mark the behavior intervals
            for i = 1:numel(startBehaviors)
                isBehaviorInterval(wholeTimepoints >= startBehaviors(i) & wholeTimepoints <= endBehaviors(i)) = true;
            end

            if ~isempty(False_time)
                isBehaviorInterval_false = false(size(wholeTimepoints));
                isBehaviorInterval_false(wholeTimepoints >= False_time(1)+wholeTimepoints(1,1) & wholeTimepoints <= False_time(2)+wholeTimepoints(1,1)) = true;
                isBehaviorInterval = isBehaviorInterval_false + isBehaviorInterval;
            end
            % Find timepoints where behaviors did not occur
            indicesWithoutBehaviors = find(~isBehaviorInterval);
            if z_score == 3
                Bout_off = values;
            else 
                Bout_off = values(indicesWithoutBehaviors);
            end

            %%  calcium data
            odor_time_whole = max(ceil(max(Boutduration)),odor_time);
            [NorF_whole,~,~] = psth_wave2(trigger_times,interval,values,basal_time,odor_time_whole,control_time(1),control_time(2),offset,z_score,Bout_off);  

            [NorF_original,~,~] = psth_wave2(trigger_times,interval,values,basal_time,odor_time,control_time(1),control_time(2),offset,z_score,Bout_off);  
            Bout_off_415 = values_415(indicesWithoutBehaviors);
            [NorF_original_415,~,~] = psth_wave2(trigger_times,interval,values_415,basal_time,odor_time,control_time(1),control_time(2),offset,z_score,Bout_off_415);  

        if max(threshold_415) > 0
          figure; imagesc(NorF_original_415);end
            
        %% Data preparation for plotting
        Boutduration(Delete_bout) = [];
        sort_id_original = 1:length(Boutduration);
        NorF = NorF_whole;

        %% generate the null NorF
        NorF_nan = NaN(size(NorF_original));

        for Ti=1:length(Boutduration)
        Duration_i = Boutduration(Ti);
        % find the of NorF during bout
        Episode = FP.bl+Duration_i*FP.fr; 
            if Episode > FP.bl+FP.seg_dur %% Need to determine whether include data outside of the whole episode
                Episode = FP.bl+FP.seg_dur;
            end
        X = round(FP.bl:Episode);
        NorF_nan(Ti,X) = NorF_original(Ti,X);

        end
        % Find columns with NaN values
        nanColumns = [];
        for i =1:size(NorF_nan,2)
            if isempty(find(isnan( NorF_nan(:,i))==0, 1))      
                nanColumns = [nanColumns,i];
            end
        end
        % Replace NaN columns with zeros
        NorF_nan(:, nanColumns) = -100;
        % Calculate the mean without considering NaN columns
        meanWithoutNaN = nanmean(NorF_nan, 1); %nanmean

        %% Sortbyduration
        [~,sort_id_bout] = sort(Boutduration,'descend');

        %% SortbyAUC
        X1 = Boutduration(sort_id_original);
        AUC=[];
        AUC_S=[];
        PeakF=[];

        for Ti=1:length(Boutduration)
            Duration_i = X1(Ti);
            % find the AUC of NorF during bout
            Episode = FP.bl+Duration_i*FP.fr; 
            X = round(FP.bl:Episode);% x position x the signals

            %% replace round to ceil
            if fix_singlespout == 1
                X = round(FP.bl:round(Episode));% x position x the signals
            end

            if length(X) == 1
                AUC(Ti) = NorF(Ti,X); 
                PeakF(Ti) = max(NorF(Ti,X));
                disp('single lick');

            elseif length(X)<1    
                AUC(Ti) = 0; %
                PeakF(Ti) = 0; 
                disp('no lick');
            else
                AUC(Ti) = trapz(X/FP.fr,NorF(Ti,X));
                PeakF(Ti) = max(NorF(Ti,X));
            end

            AUC_S(Ti)= AUC(Ti)/Duration_i;

        end
        [~,sort_id_auc] = sort(AUC,'descend');
        [~,sort_id_peak] = sort(PeakF,'descend');      

        FP.ERF_time = linspace(-FP.bl/FP.fr,FP.seg_dur/FP.fr,size(NorF_original,2));
        %% PSTH around behavioral events
        figure
        % Set the figure size (width and height in pixels)
        fig_width = 250*2;  % Adjust as needed
        fig_height = 600;  % Adjust as needed
        set(gcf, 'Position', [100, 100, fig_width, fig_height]);

        %% subplot 1: Heatmap using original order
        subplot(3,2,2)
        %% use the original data
        sort_id = sort_id_original;
        NorF = NorF_original(sort_id,:);
        X1 = Boutduration(sort_id,:);

        smooth_res = 3;                                                                  
        if smooth_res
            smoothed_data = linearSmooth(NorF,smooth_res);%load linearSmooth
        else
            smoothed_data = NorF;
        end

        imagesc(FP.ERF_time,1:size(smoothed_data,1),smoothed_data)                                                                  %%%%%%%%%%%20180312  do not delete
        colormap(mycmap);
        caxis([-2, 5]); % Set the colorbar range
        hold on;

        for Ti=1:length(X1)
        Duration_i = X1(Ti);
        Duration_i(Duration_i > FP.seg_dur/FP.fr) = FP.seg_dur/FP.fr -0.05;
        rectangle('Position',[Duration_i,Ti-0.25,0.12,0.5],'EdgeColor',[0.2 0.2 0.2],'facecolor',[0.2 0.2 0.2]);
        hold on;
        % find the peak value of NorF during bout
        Episode = round(FP.bl+Duration_i*FP.fr); 
        if Episode > FP.bl+FP.seg_dur
            Episode = FP.bl+FP.seg_dur;
        end
        end
        xline(0, 'k--'); % The 'r--' specifies the line style (red dashed)
        h = colorbar;
        set(h, 'Position', [0.92 0.73 0.02 0.15]); % [left, bottom, width, height]
        box off
        ylabel('Events')
        xlabel('Time (s)')
        title('Heatmap', 'FontSize', 8);
        %% subplot 2: Heatmap using sorted order of bout duration
        subplot(3,2,1)
        sort_id = sort_id_bout;
        NorF = NorF_original(sort_id,:);
        X1 = Boutduration(sort_id,:);

        smooth_res = 3;                                                                  
        if smooth_res
            smoothed_data = linearSmooth(NorF,smooth_res);%load linearSmooth
        else
            smoothed_data = NorF;
        end

        imagesc(FP.ERF_time,1:size(smoothed_data,1),smoothed_data)                                                                  %%%%%%%%%%%20180312  do not delete
        colormap(mycmap);
        caxis([-2, 5]); % Set the colorbar range
        hold on;

        for Ti=1:length(X1)
            Duration_i = X1(Ti);
            Duration_i(Duration_i > FP.seg_dur/FP.fr) = FP.seg_dur/FP.fr -0.05;
            rectangle('Position',[Duration_i,Ti-0.25,0.12,0.5],'EdgeColor',[0.2 0.2 0.2],'facecolor',[0.2 0.2 0.2]);
            hold on;
        end
        xline(0, 'k--'); % The 'r--' specifies the line style (red dashed)
        h = colorbar;
        set(h, 'Position', [0.92 0.73 0.02 0.15]); % [left, bottom, width, height]
        box off
        ylabel('Events')
        xlabel('Time (s)')
        title('Sorted heatmap using bout duration', 'FontSize', 8);
        %% Calculate the mean and SEM of the data
        smooth_factor = 15;
        NorF_original1 = NorF_original;

        % Smooth each row with a factor of 15
        for i = 1:size(NorF_original, 1)
            NorF_original(i, :) = smoothdata(NorF_original(i, :), 'movmean', smooth_factor);
        end
        subplot(3,2,3)
        %% Edit, plot the sem of within bout data; 
        % Replace NaN columns with zeros
        NorF_nan(NorF_nan == -100) = nan;

        %% pure stimulation, which calculate mean
        %% food intake, which calculate within bout response. 

        if mean(Boutduration) > 0.15 
            NorF_original = NorF_nan; 
        end

        hold on
        if plot_415 == 1
            NorF_original_415(isinf(NorF_original_415)|isnan(NorF_original_415)) = 0; 
            plot(FP.ERF_time,smooth(mean(NorF_original_415),smooth_factor),'k', 'LineWidth', 1)
            hold on
        end
        plot(FP.ERF_time,smooth(nanmean(NorF_original1),smooth_factor),'cyan', 'LineWidth', 1)
        hold on

       % Smooth each row with a factor
        for i = 1:size(NorF_original, 1)
            % Find indices of non-NaN values
            non_nan_indices = find(~isnan(NorF_original(i, :)));
            % Smooth only the non-NaN values
            NorF_original(i, non_nan_indices) = smoothdata(NorF_original(i, non_nan_indices), 'movmean', smooth_factor);
        end

        plot(FP.ERF_time,nanmean(NorF_original),'r', 'LineWidth', 1.5); hold on;
        meanData = nanmean(NorF_original);
        semData = nanstd(NorF_original, 0, 1)/ sqrt(size(NorF_original, 1)); % Standard Error of the Mean
        timeValues = FP.ERF_time;
        % Smooth the mean data
        smoothMeanData = meanData;
        % Calculate the upper and lower bounds for the SEM shading
        upperBound = smoothMeanData + semData;
        lowerBound = smoothMeanData - semData; 
         upperBound (isnan(upperBound))=0;
         lowerBound (isnan(lowerBound))=0;
        % Create the shaded area for SEM in very dim magenta
        fill([timeValues, fliplr(timeValues)], [upperBound, (fliplr(lowerBound))], [1, 0, 1], 'FaceAlpha', 0.1, 'EdgeColor', 'none');
        hold on;
        
        mean_duration = mean(Boutduration);
        xlabel('Time (s)')
        ylabel('Z-score')
        % Add a vertical line at x = 4
        xline(0, 'k--'); % The 'r--' specifies the line style (red dashed)
        xline(mean_duration, 'k--'); % The 'r--' specifies the line style (red dashed)

        if z_score == 0
            ylim([-0.02, 0.05]); 
        else 
            ylim([-1, 3]); 
        end

        % Set the x-axis range
        xlim([-FP.bl/FP.fr, FP.seg_dur/FP.fr])
        title(['Bout duration: ',num2str(round(mean_duration, 2))], 'FontSize', 8);
        box off
        %% 
        meanWithoutNaN = meanData;
        NorF_original = NorF_original1;

        subplot(3,2,4)
        % Sample data
        sort_id = sort_id_original;
        x = (1:length(sort_id))';
        y = (AUC(sort_id))';
        %Visualize the regression
        scatter(x, y, 5,'k', 'filled');  % Blue dots for data points
        hold on;
% 
        if size(x,1)>2
                % Perform robust linear regression using robustfit
                [b, stats] = robustfit(x, y);
                % Get the coefficients from the robust fit
                intercept = b(1);
                slope = b(2);
                % Get the p-value for the slope coefficient
                p = stats.p(2);
                % Calculate the correlation coefficient (R)
                r = corr(x, y);
                % Plot the robust regression line
                x_range = min(x):0.1:max(x);
                y_fit = intercept + slope * x_range;
                plot(x_range, y_fit, 'r', 'LineWidth', 1);hold on;
                title(['r = ', num2str(round(r, 3)), '; p = ', num2str(p),'; Slope = ', num2str(round(slope, 3))], 'FontSize', 8);
        
        end

        grid off;
        legend('off');
        xlabel('Bout IDs across a session'); 
        % ylabel('Peak Value')
        ylabel('AUC')
        ylim([-5, 50]); 
        xlim([0, length(sort_id)+1]);
        box off
        hold off;
        set(gcf, 'color', [1 1 1])

        subplot(3,2,5)
        % Sample data
        sort_id = sort_id_original;
%         NorF = NorF_original(sort_id,:);
        X1 = Boutduration(sort_id,:);
        x = X1;
        y = (AUC(sort_id))';
        %Visualize the regression
        scatter(x, y, 5,'k', 'filled');  % Blue dots for data points
        hold on;
        if size(x,1)>2
%           % Perform robust linear regression using robustfit
            [b, stats] = robustfit(x, y);
            intercept = b(1);
            slope = b(2);
            % Get the p-value for the slope coefficient
            p = stats.p(2);
            % Calculate the correlation coefficient (R)
            r = corr(x, y);

            % Plot the robust regression line
            x_range = min(x):0.1:max(x);
            y_fit = intercept + slope * x_range;
            plot(x_range, y_fit, 'r', 'LineWidth', 1);hold on;
            % Calculate the confidence intervals for the coefficients
            title(['r = ', num2str(round(r, 3)), '; p = ', num2str(p),'; Slope = ', num2str(round(slope, 3))], 'FontSize', 8);
        title(['r = ', num2str(round(r, 3)), '; p = ', num2str(p),'; Slope = ', num2str(round(slope, 3))], 'FontSize', 8);
        end
                    grid off;
        legend('off');
        xlabel('Bout duration (s)')
        % ylabel('Peak Value')
        ylabel('AUC')
        ylim([-5, 50]); 
        xlim([0, 30]);
        
        box off
        hold off;
        set(gcf, 'color', [1 1 1])


        subplot(3,2,6)
        % Sample data
        sort_id = sort_id_original;
%         NorF = NorF_original(sort_id,:);
        X1 = Boutduration(sort_id,:);
        x = X1;
%         y = (PeakF(sort_id))';
        y = (AUC_S(sort_id))'; %% 
        
        %Visualize the regression
        scatter(x, y, 5,'k', 'filled');  % Blue dots for data points
        hold on;
        if size(x,1)>2
%                 % Perform robust linear regression using robustfit
            [b, stats] = robustfit(x, y);
            % Get the coefficients from the robust fit
            intercept = b(1);
            slope = b(2);
            % Get the p-value for the slope coefficient
            p = stats.p(2);
            % Calculate the correlation coefficient (R)
            r = corr(x, y);


            % Plot the robust regression line
            x_range = min(x):0.1:max(x);
            y_fit = intercept + slope * x_range;
            plot(x_range, y_fit, 'r', 'LineWidth', 1);hold on;
            % Calculate the confidence intervals for the coefficients
            title(['r = ', num2str(round(r, 3)), '; p = ', num2str(p),'; Slope = ', num2str(round(slope, 3))], 'FontSize', 8);
        end
        grid off;
        legend('off');
        xlabel('Bout duration (s)')
%         ylabel('Peak Value')
        ylabel('AUC/Duration')
        ylim([-5, 10]); 
        xlim([0, 30]); 
        box off
        hold off;
        set(gcf, 'color', [1 1 1])
        
        boutDuration_onoff{aa,1} = Feed_info.boutduration{1, 1};
        
        clearvars -except Detectionerror BoutL_off_lickF BoutL_S_LickF intervalLength fix_singlespout threshold_415 Beh_edit Beh_var_0 Beh_var ILI_OFF ILI_S plot_415 z_score Beh_all Beh_all_0 Beh_all_1 gcf Half aa Period_show Lickrt_S Lickrt_No avgS avgNo boutL_S boutL_No boutN_S boutN_No ...
        sort_id_original sort_id_bout NorF_whole NorF_original NorF_original_415 meanWithoutNaN Boutduration z_score FP PeakF AUC ...
        AUC_S mycmap Lick_allid Lick_onid Lick_offid Feed_allid Feed_onid Feed_offid beh_norm feed_norm stim_norm...
        Feed_info Feed_info_all False_time Bout_criteria basal_time odor_time control_time offset heatmap F_470 F_415 
     
        % print(gcf, filename, '-dsvg');
        if aa == 1 
            gcf_name = ['Psth_ON_Zscore_', num2str(Half),'_', num2str(z_score),'.fig'];
            saveas(gcf, gcf_name);
            save(['Feeding_ON_signals_', num2str(Half),'.mat']);
        elseif aa == 2
            gcf_name = ['Psth_OFF_Zscore_', num2str(Half),'_', num2str(z_score),'.fig'];
            saveas(gcf, gcf_name);
            save(['Feeding_OFF1_signals_', num2str(Half),'.mat']);
        elseif aa == 3
            gcf_name = ['Psth_ALL_Zscore_' , num2str(Half),'_', num2str(z_score),'.fig'];
            saveas(gcf, gcf_name);
            save(['Feeding_OFF_signals_', num2str(Half),'.mat']);
   
        end

        end
