function uptime = check_uptime(station,network,channel,location,time)
check_savename = sprintf('%s/%s/Check/%s/DATA_%s_%s.mat',network,station,channel,station,channel);
mkdir(sprintf('./%s/%s/Check/%s',network,station,channel));

if exist(check_savename,'file') ~= 2
    a = [];
    while isempty(a) == 1
        try
            fprintf('Downloading Data\n')
            check = irisFetch.Stations('CHANNEL',network,station,location, channel);
            a = [check];
        catch exception
            fprintf('Trying again....\n');
        end
    end
    UptimeStartDateArray = zeros(1,length(check.Channels));
    UptimeEndDateArray = zeros(1,length(check.Channels));
    for n = 1:length(check.Channels(1,:))
        UptimeEndDateArray(n) = datenum(check.Channels(1,n).EndDate);
        UptimeStartDateArray(n) = datenum(check.Channels(1,n).StartDate);
    end
    
    UptimeStartDateArray = transpose(UptimeStartDateArray);
    UptimeEndDateArray = transpose(UptimeEndDateArray);
    UptimeStartDateArray = sort(UptimeStartDateArray);
    UptimeEndDateArray = sort(UptimeEndDateArray);
    
    UptimeArray = zeros(length(UptimeStartDateArray),2);
    
    UptimeArray(:,1) = UptimeStartDateArray;
    UptimeArray(:,2) = UptimeEndDateArray;
    
    
    DowntimeStartDateArray = [];
    DowntimeEndDateArray = [];
    
    if isempty(check.Comment) == 0
        for n = 1:length(check.Comment)
            begin_effective_date = datenum(check.Comment(n).BeginEffectiveDate);
            end_effective_date = datenum(check.Comment(n).EndEffectiveDate);
            elapsed = end_effective_date - begin_effective_date;
            if elapsed < 500 && begin_effective_date ~= end_effective_date
                DowntimeStartDateArray = [DowntimeStartDateArray; begin_effective_date];
                DowntimeEndDateArray = [DowntimeEndDateArray; end_effective_date];
            end
        end
        
        
        DowntimeArray = zeros(length(DowntimeStartDateArray),2);
        DowntimeArray(:,1) = DowntimeStartDateArray;
        DowntimeArray(:,2) = DowntimeEndDateArray;
        clear DowntimeDateText;
        DowntimeDateText(:,1) = cellstr(datestr(DowntimeStartDateArray));
        DowntimeDateText(:,2) = cellstr(datestr(DowntimeEndDateArray));
        
    else
        DowntimeArray = [];
        DowntimeDateText = [];
        
        
    end
    clear UptimeDateText;
    UptimeDateText(:,1) = cellstr(datestr(UptimeStartDateArray));
    UptimeDateText(:,2) = cellstr(datestr(UptimeEndDateArray));
    
    check.uptime = UptimeArray;
    check.downtime = DowntimeArray;
    check.uptimeDates = UptimeDateText;
    check.downtimeDates = DowntimeDateText;
    %The ugly code that precedes this provides first a listing of
    %times for which the station is up, and second a listing of
    %definite downtimes. These need to be graphed.
    
    %             StartDateArray = zeros(1,length(check.Channels));
    %             EndDateArray = zeros(1,length(check.Channels));
    %             for n = 1: length(check.Channels(1,:))
    %                 EndDateArray(n) = datenum(check.Channels(1,n).EndDate);
    %                 StartDateArray(n) = datenum(check.Channels(1,n).StartDate);
    %             end
    %             check.uptime = [StartDateArray;EndDateArray];
    %Uptime is a 2*n matrix with the on date ontop and the off date
    %at the bottom. It is ranked from most recent to oldest. Dates
    %are in matlab serial format.
    
    
    save(check_savename,'check');
    fprintf('%s saved.\n',check_savename);
end











exists = 2;
while exists == 2;
    if exist(check_savename,'file') == 2
        load(check_savename)
        exists = 0;
        for i = 1:length(check.Channels)
            if datenum(time) >= check.uptime(i,1) && datenum(time) <= check.uptime(i,2)
                exists = 1;
                if isempty(check.downtime) == 0
                    for n = 1:length(check.downtime)
                        if datenum(time) >= check.downtime(n,1) && datenum(time) <= check.downtime(n,2)
                            exists = 0;
                        end
                    end
                end
                
            end
        end
    elseif exist(check_savename,'file') == 0
        %This is here because the idiot IRIS network decided it would be a
        %good idea to switch channel nomenclature midyear
        exists = 2;
        gatherCheck
    end
end
uptime = exists;