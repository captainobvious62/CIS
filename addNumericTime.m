function station_list  = addNumericTime(station_list)
for i = 1:length(station_list)
    station_list(i).pWaveArrivalNumeric = datenum(station_list(i).pWaveArrival);
    station_list(i).sWaveArrivalNumeric = datenum(station_list(i).sWaveArrival);
end