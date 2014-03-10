function ws = convertTraces(traces)
   for i = 1:length(traces)
       ws(i) = waveform;
      %Use initial location for all forms
       myscnl = scnlobject(char(traces(i).station), ...
           char(traces(i).channel), ...
           char(traces(i).network), ...
           char(traces(1).location));
       ws(i) = set(ws(i),'scnlobject',myscnl,'freq',traces(i).sampleRate); %, 'start', datenum(startDateStr, 'yyyy-mm-dd HH:MM:SS.FFF'));
       ws(i) = set(ws(i),'start', datestr(traces(i).startTime));
       ws(i) = addfield(ws(i),'end',traces(i).endTime);
       ws(i) = addfield(ws(i),'latitude',traces(i).latitude);
       ws(i) = addfield(ws(i),'longitude', traces(i).longitude);
       ws(i) = addfield(ws(i),'elevation',traces(i).elevation);
       ws(i) = addfield(ws(i),'depth',traces(i).depth);
       ws(i) = addfield(ws(i),'azimuth',traces(i).azimuth);
       ws(i) = addfield(ws(i),'dip',traces(i).dip);
       ws(i) = addfield(ws(i),'sensitivity',traces(i).sensitivity);
       ws(i) = addfield(ws(i),'sensitivityFrequency',traces(i).sensitivityFrequency);
       ws(i) = addfield(ws(i),'instrument',char(traces(i).instrument));
       ws(i) = set(ws(i),'units',char(traces(i).sensitivityUnits));
       ws(i) = addfield(ws(i),'calib',1 ./ traces(i).sensitivity);
       ws(i) = addfield(ws(i),'calib_applied','NO');
       ws(i) = set(ws(i),'data', traces(i).data);
       ws(i) = addfield(ws(i),'sacPZ',traces(i).sacpz);
       ws(i) = addfield(ws(i),'calib_applied','NO');
       
    end 

ws = combine(ws);
ws = fillgaps(ws,0);
end
