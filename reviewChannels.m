%CCCP
%Template Check Script
%Code is optimized for Debian based Linux
%
%At the moment, offset is +/- 10 sec.
%Later on, this will be defined in the input file

%Snippet Settings
%Snippet window settings (sec)
time_before = 10;
time_after = 10;




%Read in written/generated template data from file
%all input parameters are modifiable in template_data_input.m
%all general parameters are modifiable in general_settings.m
templates
general_settings


directory_check = sprintf('./%s/%s',base_folder,check_folder);
if exist(directory_check,'dir') ~= 7;
    mkdir(directory_check);
    fprintf('Check directory created \n');
end



%Narrowing down focus to individual stations and channels
for template_count = 1:length(template_list(:,1))
    single_template = template_list{template_count};
    
    
    for station_count = 1:length(single_template);
        station_specific_template = single_template(station_count);
        numberofchannels = length(station_specific_template.channel_list);
        template = station_specific_template.template;
        station = station_specific_template.station;
        network = station_specific_template.network;
        
        
        for chan_count = 1:numberofchannels
            a = [];
            channel = station_specific_template.channel_list{chan_count};
            check_savename = sprintf('%s/%s/DATA_%s_%s.mat',base_folder,check_folder,station,channel);
            if exist(check_savename,'file') == 2
                load(check_savename);
                fprintf('Data Exists\n');
            else
                
                
                while isempty(a) == 1
                    try
                        fprintf('Downloading Data\n')
                        check = irisFetch.Stations('CHANNEL',network,station,location, channel);
                        a = [check];
                    catch exception
                        fprintf('Trying again....\n');
                    end
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
        
        
    end
    
    
end

