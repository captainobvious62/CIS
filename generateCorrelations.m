function [correlation_object,correlation_object_savename] = generateCorrelations(STA,NET,LOC,CHA,CHA_TEMPLATE,moveout,matches,low_bp,high_bp,before_grab,after_grab,template,erste,ende,trigger)



% for station_count = 1:length(station_list)
%     moveout = station_list(station_count).sWaveArrivalNumeric - station_list(1).sWaveArrivalNumeric;
%     NET = station_list(station_count).network;
%     STA = station_list(station_count).station;
%     LOC = '*';
%     CHAN_LIST = station_list(station_count).channel_list;
%     for chan_count = 1:length(CHAN_LIST);
%         CHA = CHAN_LIST{chan_count};
%
%         directory_check = sprintf('./%s/%s/%s/%s/CO',NET,STA,CHA,template);
%         if exist(directory_check,'dir') ~= 7;
%             mkdir(directory_check);
%             fprintf('Template directory created \n');
%         end
correlation_object_savename = sprintf('./%s/%s/%s/%s/CO/%s.to.%s.%s.%s.mat',NET,STA,CHA,template,num2str(erste),num2str(ende),STA,CHA);
correlation_object = correlation();
pick_number = 0;

for i = 1:length(matches(:,1))
    
    sync_date = [datestr(doy2date(matches(i,2),matches(i,1))),' ',datestr((matches(i,3)+moveout)/86400,'HH:MM:SS.FFF')];
    start_time = [datestr(doy2date(matches(i,2),matches(i,1))),' ',datestr((matches(i,3)+moveout-before_grab)/86400,'HH:MM:SS.FFF')];
    end_time = [datestr(doy2date(matches(i,2),matches(i,1))),' ',datestr((matches(i,3)+moveout+after_grab)/86400,'HH:MM:SS.FFF')];
    
    %% Obligitory fix for US network name change
    DAY = matches(i,2);
    YEAR = matches(i,1);
    
    if strcmp(NET,'US') == 1
        
        time = doy2date(DAY,YEAR);
        change_time = datenum('2011-05-03 00:00:00');
        if strcmp(CHA,'BHE') == 1
            if time > change_time
                CHA = 'BH1';
            end;
        end
        if strcmp(CHA,'BHN') == 1
            if time > change_time;
                CHA = 'BH2';
            end
        end
        if strcmp(CHA,'BH1') == 1
            if time < change_time;
                CHA = 'BHE';
            end
        end
        if strcmp(CHA,'BH2') == 1
            if time < change_time;
                CHA = 'BHN';
            end
        end
    end
    %% END OF NONSENSE
    
    WF_Snippet = [];
    counts = 0;
    failure = 0;
    while isempty(WF_Snippet) == 1
        try
            fprintf('Downloading trace\n')
            WF_Snippet = irisFetch.Traces(NET,STA,LOC, CHA, start_time, end_time,'verbose','includePZ');
            WF_Snippet = convertTraces(WF_Snippet);
        catch exception
            fprintf('Trying again....\n');
        end
        if counts > 5;
            failure = 1;
            break
        end
        counts = counts + 1;
    end
    if isempty(WF_Snippet) == 1
        fprintf('No Data, trying mseed\n');
        YEAR = num2str(YEAR);
        DAY = num2str(DAY);
        fprintf('%s %s %s %s %s\n',YEAR,DAY,NET,STA,CHA);
        seed = rdmseed(strcat([char(NET),'/',char(STA),'/mseed/',char(STA),'.',CHA,'.',YEAR,'.',DAY]));
        time_vec=datevec(cat(1,seed.t));
        day=median(time_vec(:,3));
        good_day=find(time_vec(:,3)==day);
        time=sum([[zeros(length(time_vec(good_day)),1),zeros(length(time_vec(good_day)),1),...
            zeros(length(time_vec(good_day)),1),3600*ones(length(time_vec(good_day)),1),...
            60*ones(length(time_vec(good_day)),1),ones(length(time_vec(good_day)),1)]'.*time_vec(good_day,:)'])';
        [B,I,J]=unique(time,'first');
        temp=cat(1,seed.d);
        data=temp(intersect(good_day,I));
        clear temp;
        freq = seed(1).SampleRate;
        %bp=bandpass(data,low_bp,high_bp,1/freq,3);
        
        index_time = matches(i,3)*freq + moveout*freq;
        begin_time = index_time - before_grab*freq;
        fin_time = index_time + after_grab*freq;
        snippet = data(begin_time:fin_time);
        WF_Snippet = waveform(STA,CHA,seed(1).SampleRate,start_time,snippet);
        
    end
    %Not sure if we just want to add a filter function later
    %and not filter it in situ
    WF_Snippet = fillgaps(WF_Snippet,0);
    
    WF_Snippet = filter_waveform_BP(WF_Snippet,low_bp,high_bp);
    WF_Snippet = addfield(WF_Snippet,'Rel_MAD',matches(i,4));
    WF_Snippet = addfield(WF_Snippet,'Phase',trigger);
    WF_Snippet = correlation(WF_Snippet);
    
    if pick_number == 0;
        correlation_object = WF_Snippet;
    else
        correlation_object = cat(correlation_object,WF_Snippet);
    end
    pick_number = pick_number + 1;
end

template_savename = sprintf('./%s/%s/%s/%s/%s.%s.%s.mat',NET,STA,CHA_TEMPLATE,template,template,STA,CHA_TEMPLATE);
load(template_savename)
fprintf('Template %s loaded.\n',template_savename);
wf_Temp = filter_waveform_BP(wf_Temp,low_bp,high_bp);
wf_Temp = correlation(wf_Temp);
correlation_object = cat(correlation_object,wf_Temp);
% save(correlation_object_savename,'correlation_object');
% fprintf('Correlation object %s saved.\n',correlation_object_savename);

end
