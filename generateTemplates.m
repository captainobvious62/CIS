%CCCP
%Grab Correlation Object Script
%Code is optimized for Debian based Linux
%Grabs snippets from picks in events file
%Loads into correlation object
%At the moment, offset is +/- 10 sec(ish).
%Later on, this will be defined in the input file

%Snippet Settings
%Snippet window settings (sec)




%Read in written/generated template data from file
%all input parameters are modifiable in template_data_input.m
%all general parameters are modifiable in general_settings.m
templates
general_settings
components={'E','N','Z'};

%directory_check = sprintf('%s',template_folder);
%if exist(directory_check,'dir') ~= 7;
%    mkdir(directory_check);
%    fprintf('Template directory created \n');
%end

%Narrowing down focus to individual stations and channels
for template_count = 1:length(template_list)
    single_template = template_list{template_count};
    for station_count = 1:length(single_template);
        station_specific_template = single_template(station_count);
        P_Pick_time = datenum(station_specific_template.pWaveArrival);
        S_Pick_time = datenum(station_specific_template.sWaveArrival);
        
        %Choose which point to use for correlation, P or S break
        
        %For P Wave
        if strcmp(station_specific_template.trigger,'P') == 1
            starttime = P_Pick_time - (time_before/86400);
            endtime = P_Pick_time + (time_after/86400);
        elseif strcmp(station_specific_template.trigger,'S') == 1
            %For S Wave
            starttime = S_Pick_time - (time_before/86400);
            endtime = S_Pick_time + (time_after/86400);
        end
        numberofchannels = length(station_specific_template.channel_list);
        template = station_specific_template.template;
        station = station_specific_template.station;
        network = station_specific_template.network;
        for chan_count = 1:numberofchannels
            channel = station_specific_template.channel_list{chan_count};
            %Check for directory structure
            
 %           directory_check = sprintf('%s/%s',network,station);
 %           %if exist(directory_check,'dir') ~= 7;
 %               mkdir(directory_check);
 %               fprintf('Network directory created \n');
 %           %end
 %           directory_check = sprintf('%s/Templates',station);
 %           %if exist(directory_check,'dir') ~= 7;
 %               mkdir(directory_check);
%                fprintf('Network directory created \n');
%            %end
            directory_check = sprintf('%s/%s/Templates/%s',network,station,components{chan_count});
            %if exist(directory_check,'dir') ~= 7;
                mkdir(directory_check);
                fprintf('Network directory created \n');
            %end
            
            
            directory_check = sprintf('%s',network);
            if exist(directory_check,'dir') ~= 7;
                mkdir(directory_check);
                fprintf('Network directory created \n');
            end
            directory_check = sprintf('%s/%s',network,station);
            if exist(directory_check,'dir') ~= 7;
                mkdir(directory_check);
                fprintf('Station directory created \n');
            end
            directory_check = sprintf('%s/%s/%s',network,station,channel);
            if exist(directory_check,'dir') ~= 7;
                mkdir(directory_check);
                fprintf('Channel directory created \n');
            end
            directory_check = sprintf('%s/%s/%s/%s',network,station,channel,template);
            if exist(directory_check,'dir') ~= 7;
                mkdir(directory_check);
                fprintf('Template directory created \n');
            end
            
            
            template_savename = sprintf('%s/%s/%s/%s/%s.%s.%s.mat',network,station,channel,template,template,station,channel);
            if exist(template_savename,'file') == 2
                fprintf('Template Exists. Yay.\n')
                load(template_savename);
                fprintf('Template %s loaded.\n',template_savename)
            else
                wf_Temp = waveform();
                attempts = 0;
                while isempty(wf_Temp) == 1
                    try
                        fprintf('Downloading template\n')
                        wf_Temp = irisFetch.Traces(network,station,location, channel, starttime, endtime,'verbose','includePZ');
                        
                    catch exception
                        fprintf('Trying again....\n');
                    end
                    attempts = attempts +1;
                    if attempts >5
                        break
                    end
                end
                wf_Temp = convertTraces(wf_Temp);
                wf_Temp = fillgaps(wf_Temp,0);
                data = get(wf_Temp,'data');
                if length(data) > (time_before+time_after)*get(wf_Temp,'freq')+1
                    data = data(1:(time_before+time_after)*get(wf_Temp,'freq')+1);
                elseif length(data) < (time_before+time_after)*get(wf_Temp,'freq')+1
                    data((time_before+time_after)*get(wf_Temp,'freq')+1) = 0;
                end
                data_savename = sprintf('%s/%s/Templates/%s/template_%s.mat',network,station,components{chan_count},template);
                wf_Temp = set(wf_Temp,'data',data);
                clear data
                if strcmp(station_specific_template.trigger,'P') == 1
                    wf_Temp = addfield(wf_Temp,'TRIGGER',datenum(station_specific_template.pWaveArrival));
                elseif strcmp(station_specific_template.trigger,'S') == 1
                    wf_Temp = addfield(wf_Temp,'TRIGGER',datenum(station_specific_template.sWaveArrival));
                end
                save(template_savename,'wf_Temp');
                fprintf('Template %s saved.\n',template_savename)
                wf_Temp = filter_waveform_BP(wf_Temp,lower_band,upper_band);
                timevec =get(wf_Temp,'timevector');
                timevec = timevec - datenum(datestr(timevec(1),1));
                timevec = timevec *86400;
                if chan_count == 1;
                    template_E = [timevec,get(wf_Temp,'data')];
                    save(data_savename,'template_E');
                elseif chan_count ==2;
                    template_N = [timevec,get(wf_Temp,'data')];
                    save(data_savename,'template_N');
                elseif chan_count == 3;
                    template_Z = [timevec,get(wf_Temp,'data')];
                    save(data_savename,'template_Z');
                end
                
            end
        end
    end
end

