function [station_list,peak_times_tosave] =  sumEvents_allSTA(station_list,YEAR,DAY,CHA_E,CHA_N,CHA_Z,freq)
YR = YEAR;
YEAR = num2str(YEAR);
DDD = DAY;
DAY = num2str(DAY,'%03d');
%freq = 40;
% CHA_E = 'BHE'
% CHA_N = 'BHN'
% CHA_Z = 'BHZ'

station_list = addNumericTime(station_list);

[dist,index] = sort([station_list(:).sWaveArrivalNumeric],'ascend')
station_list = station_list(index)
station_list(:).station


threshold=8;  %times the MAD above 0
% fid = fopen(['template_',id,'_times_new.txt'], 'w');
% fclose(fid);


time=0:1/freq:86400;   %seconds in a day
data = cell(1,length(station_list));
template_time = cell(1,length(station_list));
station_time = cell(1,length(station_list));
ccc = cell(1,length(station_list));
%sum = cell(1,length(station_list));
ccc_sum = zeros(1,60*60*24*freq+1);


for i = 1:length(station_list)
    STA = station_list(i).station;
    NET = station_list(i).network;
    template = station_list(i).template;
    
    
    
    
    [NET,'/',STA,'/CCC/',template,'/cccSum.',num2str(YEAR),'.',num2str(DAY,'%03d'),'.mat']
    if exist([NET,'/',STA,'/CCC/',template,'/cccSum.',num2str(YEAR),'.',num2str(DAY,'%03d'),'.mat'],'file')
        [data{i}]=load([NET,'/',STA,'/CCC/',template,'/cccSum.',num2str(YEAR),'.',num2str(DAY,'%03d'),'.mat']);
        load([NET,'/',STA,'/Templates/E/template_',template,'.mat'])
        load([NET,'/',STA,'/Templates/N/template_',template,'.mat'])
        load([NET,'/',STA,'/Templates/Z/template_',template,'.mat'])
        %Load in the time of the start of this template
        template_time{i}=template_Z(1,1);
        template_time{i};
        a = i;
        if i == 1
            %Adjust the time. For this first template, I do no adjustment - every other
            %template will be relative to this one.
            station_time{i}=time-0;
        else
            station_time{i}=time-(template_Z(1,1)-template_time{1});
            
        end
        ccc{i}=data{i}.ccc_STA;
        if(isempty(ccc{i}))
            ccc{i}=zeros(1,60*60*24*freq);
        end
        
        
        %sum the cross correlations up, using the adjusted times before
        %interpolating
        arman = interp1(station_time{i}(1:length(ccc{i})),ccc{i},time,'linear');
        
    end
    ccc_sum = arman + ccc_sum;
    
end
peak_threshold=max(threshold*mad(ccc_sum),1);
[pks,locs]=findpeaks(ccc_sum,'minpeakheight',peak_threshold,'minpeakdistance',6*40);
peak_times=[time(locs)]';

peak_times_tosave=[ones(length(locs),1)*str2num(char(YEAR)),ones(length(locs),1)*str2num(DAY),time(locs)',pks'];
if(~isempty(peak_times_tosave))
    peak_times_tosave
end
disp(['Finished summing Correlations for day ',DAY,' of Year ',char(YEAR),'. Threshold for the day is ',num2str(peak_threshold),'.'])

multisum_savename = sprintf('./multisum/%s/%s.%04d.%03d.mat',template,template,YR,DDD);

directory_check = sprintf('./multisum/%s',template);
if exist(directory_check,'dir') ~=7;
    mkdir(directory_check);
    fprintf('%s directory created\n',directory_check);
end
save(multisum_savename,'ccc_sum');
end
