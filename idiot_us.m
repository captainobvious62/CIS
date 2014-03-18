function single_station = idiot_us(single_station,DDD,YR)

NET = single_station.network;

if strcmp(NET,'US') == 1
   
    CHA_E = single_station.channel_list{1};
    CHA_N = single_station.channel_list{2};
    time = doy2date(DDD,YR);
    change_time = datenum('2011-05-03 00:00:00');
    if strcmp(CHA_E,'BHE') == 1
        if time > change_time
            CHA_E = 'BH1';
        end;
    end
    if strcmp(CHA_N,'BHN') == 1
        if time > change_time;
            CHA_N = 'BH2';
        end
    end
    if strcmp(CHA_E,'BH1') == 1
        if time < change_time;
            CHA_E = 'BHE';
        end
    end
    if strcmp(CHA_N,'BH2') == 1
        if time < change_time;
            CHA_N = 'BHN';
        end
    end
    
    single_station.channel_list{1} = CHA_E;
    single_station.channel_list{2} = CHA_N;
end