function output = filter_waveform_BP(WF,lower,upper)
%filters based upon a bandpass from 1 Hz to 80% of NYQ
freq = get(WF,'freq');
maximum = 0.8*(freq/2);
if upper > maximum;
    upper = maximum;
end
filter =  filterobject('B',[lower upper], 4);
WF = filtfilt(filter,WF);
WF = addfield(WF,'FILTER_APPLIED','YES');
WF = addfield(WF,'FILTER',filter);
output = WF;