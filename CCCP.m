%Populate Station Data
general_settings
templates
Days=[001:365];
Years=[2013];
location = '*';
generateTemplates;
for i = 1:length(Years)
    YEAR = Years(i);
    for j = 1:length(Days);
        DAY = Days(j);
        for template_count = 1:length(template_list)
            station_list = template_list{template_count};
            for station_count = 1:length(station_list)
                single_station = station_list(station_count);
                %Include means so that only one set needs to be downloaded
                download_webServices(single_station.network,single_station.station,location,YEAR,DAY,single_station.channel_list{1},single_station.channel_list{2},single_station.channel_list{3});
%                 folder_check = sprintf('%s/CCC',single_station.station);
%                 if exist(folder_check,'dir')~=7
%                     mkdir(folder_check);
%                 end
                folder_check = sprintf('./%s/%s/CCC/%s',single_station.network,single_station.station,single_station.template);
                if exist(folder_check,'dir')~=7
                    mkdir(folder_check);
                end
                [time,ccc_STA] = CC_station_day(single_station.template,single_station.network,single_station.station,YEAR,DAY,single_station.channel_list{1},single_station.channel_list{2},single_station.channel_list{3});
                ccc_STA_savename = sprintf('./%s/%s/CCC/%s/cccSum.%04d.%03d.mat',single_station.network,single_station.station,single_station.template,YEAR,DAY);
                save(ccc_STA_savename,'ccc_STA');
            end
        end
    end
end
