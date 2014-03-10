clear all
warning off all

id='402';
threshold=8;  %times the MAD above 0
% fid = fopen(['template_',id,'_times_new.txt'], 'w');
% fclose(fid);
search_days=[243];

time=0:0.025:86400;   %seconds in a day

for YEAR = {'2011'}   %'2006','2009','2010','2011','2012'
    for DAY=search_days     %For each day
        strDAY=num2str(DAY,'%03d');  %need the day as a text string to open files
        if((exist(strcat(['M54A/CCC/',id,'/cccSum.',char(YEAR),'.',strDAY,'.mat']),'file') &&...
                exist(strcat(['N54A/CCC/',id,'/cccSum.',char(YEAR),'.',strDAY,'.mat']),'file') &&...
                exist(strcat(['MCWV/CCC/',id,'/cccSum.',char(YEAR),'.',strDAY,'.mat']),'file')) &&...
                (exist(strcat(['N54A/mseed/N54A.BHZ.',char(YEAR),'.',strDAY]),'file') ||...
                exist(strcat(['M54A/mseed/M54A.BHZ.',char(YEAR),'.',strDAY]),'file') ||...
                exist(strcat(['MCWV/mseed/MCWV.BHZ.',char(YEAR),'.',strDAY]),'file')))
            %%% Load the cross corelation file for each station in my detector
            %%% network

            [N54A]=load(['N54A/CCC/',id,'/cccSum.',char(YEAR),'.',strDAY,'.mat']);
            load(['N54A/Templates/Z/template_',id,'.mat']);
            load(['N54A/Templates/N/template_',id,'.mat']);
            load(['N54A/Templates/E/template_',id,'.mat']);
            
            %Load in the time of the start of this template
            N54A_template_time=template_Z(1,1);
            
            %Adjust the time. For this first template, I do no adjustment - every other
            %template will be relative to this one.
            N54A_time=time-0;
            
            ccc_N54A=N54A.ccc_STA;
            if(isempty(ccc_N54A))
                ccc_N54A=zeros(1,3456001);
            end
            
            [M54A]=load(['M54A/CCC/',id,'/cccSum.',char(YEAR),'.',strDAY,'.mat']);
            load(['M54A/Templates/Z/template_',id,'.mat']);
            load(['M54A/Templates/N/template_',id,'.mat']);
            load(['M54A/Templates/E/template_',id,'.mat']);
            
            %Load in the time of the start of this template
            M54A_template_time=template_Z(1,1);
            
            %Adjust the time of this template relative to N54A 
            M54A_time=time-(template_Z(1,1)-N54A_template_time);
            
            ccc_M54A=M54A.ccc_STA;
            if(isempty(ccc_M54A))
                ccc_M54A=zeros(1,3456001);
            end
      

            [MCWV]=load(['MCWV/CCC/',id,'/cccSum.',char(YEAR),'.',strDAY,'.mat']);
            load(['MCWV/Templates/Z/template_',id,'.mat']);
            load(['MCWV/Templates/N/template_',id,'.mat']);
            load(['MCWV/Templates/E/template_',id,'.mat']);
            
            %Load in the time of the start of this template
            MCWV_template_time=template_Z(1,1);
            
            %Adjust the time of this template relative to N54A
            MCWV_time=time-(template_Z(1,1)-N54A_template_time);
            
            ccc_MCWV=MCWV.ccc_STA;
            if(isempty(ccc_MCWV))
                ccc_MCWV=zeros(1,3456001);
            end

            %sum the cross correlations up, using the adjusted times before
            %interpolating
            ccc_sum=interp1(M54A_time(1:length(ccc_M54A)),ccc_M54A,time,'linear')+...
                interp1(N54A_time(1:length(ccc_N54A)),ccc_N54A,time,'linear')+...
                interp1(MCWV_time(1:length(ccc_MCWV)),ccc_MCWV,time,'linear');
            
            peak_threshold=max(threshold*mad(ccc_sum),1);
            [pks,locs]=findpeaks(ccc_sum,'minpeakheight',peak_threshold,'minpeakdistance',6*40);
            peak_times=[time(locs)]';
            
            peak_times_tosave=[ones(length(locs),1)*str2num(char(YEAR)),ones(length(locs),1)*str2num(strDAY),time(locs)',pks'];
            if(~isempty(peak_times_tosave))
                peak_times_tosave
            end
            disp(['Finished summing Correlations for day ',strDAY,' of Year ',char(YEAR),'. Threshold for the day is ',num2str(peak_threshold),'.'])
        end
    end
end
