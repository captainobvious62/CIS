Blackpool_Template
general_settings_Blackpool
%
%
%
%Adjust time data to MATLAB readable format
start_date = sprintf('%04d-%02d-%02d %02d:%02d.%d',start_year,start_month,start_day,start_minute,start_second);
end_date = sprintf('%04d-%02d-%02d %02d:%02d.%d',end_year,end_month,end_day,end_minute,end_second);

%Check to ensure the proper flow of time
start_date = datenum(start_date);
end_date = datenum(end_date);
delta_time = end_date - start_date;
is_real = delta_time > 0;
if is_real == 0;
    fprintf('The Campaign for Real Time requests that you please ensure that your ending date follows your starting date. \n');
end
intervals = delta_time/CC_increment;
run([getenv('ANTELOPE'),'/setup.m'])
DB_Location = sprintf('/media/Back40/Blackpool/Blackpool');
db = dbopen(DB_Location,'r');

lower_band = 1;
upper_band = 12;
filter = filterobject('H',5, 4);
%Antelope Datasource
datasource = datasource('antelope',DB_Location)
before = 10;
after = 10;
lower = 1;



events = {'Time Index', 'CC Value','Time (UTC)','MATLAB Time','Threshold Value','Station','Network','Template', 'Location','MAD','CC Relation to MAD'};
phase = 'S';
row = 2;
total_detections = 0;
template = 'Blackpool';

%Loads waveforms from Antelope and places them within a struct directory
for i = length(list):-1:1
fprintf('Start Date: %s\n',datestr(start_date));
fprintf('End Date: %s\n',datestr(end_date));

    list(i).channels = struct();
    for j = 1:length(list(i).channel_list);
        list(i).channels(j).channel = list(i).channel_list{j};
        
        list(i).channels(j).location = list(i).location;
        list(i).channels(j).scnlobject = scnlobject(list(i).station,list(i).channels(j).channel,list(i).network,list(i).channels(j).location);
        list(i).channels(j).template = waveform(datasource,list(i).channels(j).scnlobject,datestr(datenum(list(i).sWaveArrival)-before/86400),datestr(datenum(list(i).sWaveArrival)+after/86400));
	upper = (get(list(i).channels(j).template,'freq')/2)*0.8;  
	list(i).channels(j).template =filtfilt(filter,list(i).channels(j).template);
        event_match_printout = sprintf('%s_to_%s__%s_Blackpool.csv',datestr(start_date),datestr(end_date),get(list(i).channels(j).scnlobject,'station'));

%list(i).channels(j).waveforms = waveform();
        for time = 1:intervals;
            w = waveform(datasource,list(i).channels(j).scnlobject,datestr((start_date+time),29),datestr((start_date + time+ CC_increment),29));
            
            if isempty(w) == 1;
                list(i).channels(j).waveforms(time) =  waveform();
            else
                w = fillgaps(w,0);
		
		upper = 0.8*(get(w(1),'freq')/2);
                w = filtfilt(filter,w);
		%w = filter_waveform_BP(w,lower,upper);
                
                
                list(i).channels(j).waveforms(time) = w;
            end
        end
        w= fix_data_length(w);
        [w xc] = mastercorr_scan(list(i).channels(j).waveforms,list(i).channels(j).template,0.5)
        
        xc = fix_data_length(xc);
        list(i).channels(j).waveforms = w;
        list(i).channels(j).XC = xc;
        
    end
    for time = 1:intervals
        %list(i).XC_Stacking = [];
        stack = list(i).channels(1).XC(time);
        for j = 2:length(list(i).channels)
            stack = fix_data_length([stack,list(i).channels(j).XC(time)]);
            stack = plus(stack(1),stack(2));
        end
        list(i).XC_Stack(time) = stack;
    end
    network = list(i).network;
    station = list(i).station;
    location = get(list(i).channels(j).scnlobject,'location');
    for delta  = 1:intervals
        time = start_date + delta;
        data = get(list(i).XC_Stack(delta),'data'); %Review CC for prospects
        threshold = 9*mad(data);
        freq = get(list(i).XC_Stack(delta),'freq');
        [PeakCorr,PeakIndex] = getpeaks(data,'NPEAKS',candidates);
        TimeIndex = PeakIndex/freq;
        DisplayTime = time;
        detections = 0;
        for z = 1:candidates
            
            if PeakCorr(z) >= threshold
                DisplayTime = time + (TimeIndex(z)/(60*60*24));
                events{row,1} = TimeIndex(z);
                events{row,2} = PeakCorr(z);
                events{row,3} = datestr(DisplayTime,'dd mmmm yyyy HH:MM:SS.FFF');
                events{row,4} = DisplayTime;
                events{row,5} = threshold;
                events{row,6} = station;
                events{row,7} = network;
                events{row,8} = template;
                events{row,9} = location;
                events{row,10} = threshold/9;
                events{row,11} = PeakCorr(z)/(threshold/9);
                row = row + 1;
                total_detections = total_detections + 1;
            end
        end
    end
    fprintf('%d events detected\n',detections);
    fprintf('%d total events detected\n',total_detections);
    dlmcell(event_match_printout,events,',');
    
    
end


