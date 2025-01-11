%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by Rong/Zhenggang
%% 
% clear all;
% clc;
% close all;
% 
% 
% %% read licking data from the Evt file
% strEventFn = "X:\EventlogData\8_30_2023\ZXC_80.evt";
% stEventData = ParseEventFile_2mice(strEventFn);
% lick = stEventData.Licking.Time_S* 2 * 10^-2;


function Feed_info = Boutinfo(lick,Feed,minILI11)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% define function -- constant values have been set inside the function
N_days = 1;
for Day_id = N_days

boutStart_all ={};
boutEnd_all ={};
boutDuration_all ={};
boutLicks_all ={};
boutLickRate_all ={};
boutIBI_all ={};

for ANM = 1
% figure
for kk=1
F_size = 1;
plot_duration = 0;

% minILI11=[1000,2500,5000];
ILI_max = 1000;
%% define it first outside the function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plot_duration=0;
% sampleInterval = 100; %in ms   
lowInterval= 80; %in ms
Switch_num = 2; % number of spouts in working
% stimstart=input(['When was the test last ', fname, ' (in min)? ']);
% Total_min=stimstart;
%found mouse ID first
% MiceCond_ID = 5; 

TS1=[];
TS5=[]; 
%2021/02/22
%% figure 1
% scrsz = get(0,'ScreenSize'); % Screensize[left,bottom, width, height]
% set(gcf,'Position',scrsz*F_size);
boutTimeon1={}; 
boutDuration1_bout1 ={};
boutILI11={};
boutStart11={};
averageboutILI1s1 ={};
commonboutILI1s1={};
minILI1s1={};
numberBouts250s1={};
% lickTimeon=lickTimeon_jj{1,kk+(ii-1)*2}; % ZZ edit
lickTimeon={};
% lickTimeon=lickTimeon_jj{1,kk};
lickTimeon=lick*1000;

%% repeat ili 
ili = lickTimeon(2:end) - lickTimeon(1:end-1);
ili500 = ili(ili<ILI_max);
ind = find(ili<lowInterval);
lickTimeLow = lickTimeon(ind+1);
averageILI=sum(ili)/length(ili);
averageILIs=num2str(averageILI);
commonILI= mode(ili);
commonILIs=num2str(commonILI);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% number of bouts- bout criteria- breaks of 250 or greater %%%%%%%%%%%%%%%%

plot_ii = 0;
for minILI1=minILI11
boutData1=[]; 
boutEnd1=[];
boutStart1=[];
boutStart=[];
bout0 = [];
boutDuration1=[];
boutLickRate1=[];
boutILI1=[];
boutLicks1=[];
boutTimeon2=[];
plot_ii = plot_ii +1;    
minILI1s=num2str(minILI1);
% boutDuration1_bout1 ={};
%determine whether an interval is within criteria

boutStart(1,1) = lickTimeon(1,1);
bout0 = [1;find(ili>minILI1)];
for n=2:length(ili)+1
    
    if ili(n-1,1)>minILI1  % find next large ili
    boutStart(n,1) = lickTimeon(n,1);
    
    else
    boutStart(n,1) = 0;
    end
end
boutStart1 = (boutStart(boutStart>0));
%- ones(length(boutStart0),1)
boutEnd1 = [lickTimeon(bout0(2:end));lickTimeon(end)];

boutDuration1 = double(boutEnd1) - boutStart1 + 120; % edit 120 if necessary
% boutDuration1(boutDuration1==0) = 120;
boutEnd1 = boutDuration1 + boutStart1;
boutLicks0 = bout0(2:end) - bout0(1:end-1);
boutLicks1 = [boutLicks0;length(lickTimeon)- bout0(end)];
boutLickRate1 = boutLicks1./boutDuration1*1000;

% Feed 
bout_feed = [];
% Feed = stEventData.Feed1_Pump.Time_S* 2 * 10^-2;
for j = 1:length(boutStart1)
bout_feed(j) = length(find(Feed>boutStart1(j) & Feed<boutEnd1(j)));
end
bout_feed = bout_feed';
boutFeedRate1 = bout_feed./boutDuration1*1000;

boutILI1 = boutStart1(2:end) - boutStart1(1:end-1);

numberBouts250 = length(boutStart1);
numberBouts250s=num2str(numberBouts250);

aveBoutLicks250=sum(boutLicks1)/numberBouts250;
aveBoutLicks250s=num2str(aveBoutLicks250);
aveBoutDuration250=sum(boutDuration1/numberBouts250); %in sec
aveBoutDuration250s=num2str(aveBoutDuration250);
aveboutLickRate250=sum(boutLickRate1)/numberBouts250;
aveboutLickRate250s=num2str(aveboutLickRate250);
averageboutILI1=sum(boutILI1)/length(boutILI1);   %%%%%%%edit zhenggang
averageboutILI1s=num2str(round(averageboutILI1));
commonboutILI1= mode(boutILI1);
commonboutILI1s=num2str(commonboutILI1);

end

boutStart_all{kk,ANM} = boutStart1/1000;
boutEnd_all{kk,ANM} = boutEnd1/1000;
boutDuration_all{kk,ANM} = boutDuration1/1000;
boutLicks_all{kk,ANM} = boutLicks1/1000;
boutLickRate_all{kk,ANM} = boutLickRate1;
boutfeed_all{kk,ANM} = bout_feed/1000;
boutFeedRate_all{kk,ANM} = boutFeedRate1;
boutIBI_all{kk,ANM} = boutILI1/1000;

end
end
end


%% figure 2  
% subplot (2,1,2)
% ANM = 1;
% X = boutStart_all{1,ANM};
% X1 = boutDuration_all{1,ANM};
% for Tiii=1:length(X)
% rectangle('Position',[X(Tiii),7,X1(Tiii),1],'EdgeColor',[0 0 0],'facecolor',[0 0 0]);
% end
% hold on;
% % %% add the opto on/off plot
% % 
% % Opto_stim = stEventData.ON_OFFBlocks.Time_S* 2 * 10^-2/1000;
% % X1 = 120;
% % for Tiii=1:length(Opto_stim)
% % rectangle('Position',[Opto_stim(Tiii),7.5,X1,1],'EdgeColor',[0 0 1],'facecolor',[0 0 1]);
% % end
% 
% set(gca,'YTickLabel','', 'YTick', [])
% xlabel('Time (s)')
% ylabel('Bout raster')
% box off
% hold on
% set(gcf, 'color', [1 1 1])
% linkaxes([ax1 ax2],'x')


clearvars -except minILI11 lick Feed Opto_stim ... 
boutStart_all boutEnd_all boutDuration_all boutLicks_all...
boutLickRate_all boutfeed_all boutFeedRate_all boutIBI_all;
Feed_info.boutstart = boutStart_all;
Feed_info.boutduration = boutDuration_all;
Feed_info.boutend = boutEnd_all;
mat_name0='Feeding_events_day';
mat_name=[mat_name0,'.mat'];
save(mat_name) 

%% save Feed_info into a csv
