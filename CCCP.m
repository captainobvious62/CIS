%Populate Station Data
general_settings
templates
% %Current control point
% erste = 305;
% ende = 335;
% Days=[erste:ende];
% Years=[2011];
location = '*';
generateTemplates;
FREQ = 40;
results = cell(1,length(template_list));


first_date = datenum(sprintf('%02d/%02d/%04d',start_month,start_day,start_year));
last_date = datenum(sprintf('%02d/%02d/%04d',end_month,end_day,end_year));


for date = first_date:1:last_date
    
    YEAR = datevec(date);
    YEAR = YEAR(1);
    DAY = date2doy(date);
    for template_count = 1:length(template_list)
        station_list = template_list{template_count};
        for station_count = 1:length(station_list)
            station_list(station_count).template_channels = station_list(station_count).channel_list;
            single_station = station_list(station_count);
%             single_station = idiot_us(single_station,DAY,YEAR);
%             station_list(station_count) = single_station;
            %Include means so that only one set needs to be downloaded
            download_webServices(single_station.network,single_station.station,location,YEAR,DAY,single_station.channel_list{1},single_station.channel_list{2},single_station.channel_list{3});
            
            folder_check = sprintf('./%s/%s/CCC/%s',single_station.network,single_station.station,single_station.template);
            if exist(folder_check,'dir')~=7
                mkdir(folder_check);
            end
            ccc_STA_savename = sprintf('./%s/%s/CCC/%s/cccSum.%04d.%03d.mat',single_station.network,single_station.station,single_station.template,YEAR,DAY);
            if exist(ccc_STA_savename,'file') == 0
                %[time,ccc_STA] = station_day_ccc(single_station.template,single_station.network,single_station.station,YEAR,DAY,single_station.channel_list{1},single_station.channel_list{2},single_station.channel_list{3},FREQ);
                [time,ccc_STA] = CC_station_day(single_station.template,single_station.network,single_station.station,YEAR,DAY,single_station.channel_list{1},single_station.channel_list{2},single_station.channel_list{3},FREQ);
                parasave(ccc_STA_savename,ccc_STA);
                
            end
        end
        [station_list, peak_times_tosave] = sumEvents_allSTA(station_list,YEAR,DAY,single_station.channel_list{1},single_station.channel_list{2},single_station.channel_list{3},FREQ);
        results{template_count} = [results{template_count};peak_times_tosave];
        template_list{template_count} = station_list;
    end
end

for template_count = 1:length(template_list);
    station_list = template_list{template_count};
    template = template_names{template_count};
    folder_check = sprintf('./Results/%s',template_names{template_count});
    if exist(folder_check,'dir')~=7
        mkdir(folder_check);
    end
    result_savename = sprintf('./Results/%s/%s_to_%s.mat',template_names{template_count},datestr(first_date),datestr(last_date));
    iterResult = results{template_count};
    save(result_savename,'iterResult');
    fprintf('%s saved\n',result_savename);
    
    
    for station_count = 1:length(station_list)
        moveout = station_list(station_count).sWaveArrivalNumeric - station_list(1).sWaveArrivalNumeric;
        NET = station_list(station_count).network;
        STA = station_list(station_count).station;
        LOC = '*';
        trigger = station_list(station_count).trigger;
        CHAN_LIST = station_list(station_count).channel_list;
        for chan_count = 1:length(CHAN_LIST);
            CHA = CHAN_LIST{chan_count};
            CHA_TEMPLATE = station_list(station_count).template_channels{chan_count};
            directory_check = sprintf('./%s/%s/%s/%s/CO',NET,STA,CHA,template);
            if exist(directory_check,'dir') ~= 7;
                mkdir(directory_check);
                fprintf('Template directory created \n');
            end
            if isempty(iterResult) ~=1
                [correlation_object,correlation_object_savename] = generateCorrelations(STA,NET,LOC,CHA,CHA_TEMPLATE,moveout,iterResult,lower_band,upper_band,before_S_Wave,after_S_Wave,template,datestr(first_date),datestr(last_date),trigger);
                
                parasave(correlation_object_savename,correlation_object);
            end
        end
    end
end



