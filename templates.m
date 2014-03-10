%This file controls the template event to be used for cross correlation.
%At the moment, the format is rather self explanatory, with the fields as follows:
%Station
%Network
%S Wave arrival time (Template focus time)
%Template name
%Channel list denoting channels of interest
%Move out time (will be automated, if it hasn't already been)
T01 = struct();
T01.station = 'N54A';
T01.network = 'TA';
T01.pWaveArrival = '2011-03-17 10:53:19.900';
T01.sWaveArrival = '2011-03-17 10:53:27.325';
T01.template = '17_Mar';
T01.trigger = 'S';
T01.channel_list = ['BHE';'BHN';'BHZ'];
T01.channel_list = cellstr(T01.channel_list);

T01(2).station = 'M54A';
T01(2).network = 'TA';
T01(2).pWaveArrival = '2011-03-17 10:53:25.100';
T01(2).sWaveArrival = '2011-03-17 10:53:36.650';
T01(2).template = '17_Mar';
T01(2).channel_list = ['BHE';'BHN';'BHZ'];
T01(2).channel_list = cellstr(T01(2).channel_list);

T01(3).station = 'MCWV';
T01(3).network = 'US';
T01(3).pWaveArrival = '2011-03-17 10:53:38.200';
T01(3).sWaveArrival = '2011-03-17 10:54:01.550';
T01(3).trigger = 'S';
T01(3).template = '17_Mar';
T01(3).channel_list = ['BHE';'BHN';'BHZ'];
T01(3).channel_list = cellstr(T01(3).channel_list);

T01(4).station = 'ACSO';
T01(4).network = 'US';
T01(4).pWaveArrival = '2011-03-17 10:53:43.100';
T01(4).sWaveArrival = '2011-03-17 10:54:09.100';
T01(4).template = '17_Mar';
T01(4).channel_list = ['BHE';'BHN';'BHZ'];
T01(4).channel_list = cellstr(T01(4).channel_list);

T01(5).station = 'ERPA';
T01(5).network = 'US';
T01(5).pWaveArrival = '2011-03-17 10:53:30.60';
T01(5).sWaveArrival = '2011-03-17 10:53.43.80';
T01(5).template = '17_Mar';
T01(5).channel_list = ['BHE';'BHN';'BHZ'];
T01(5).channel_list = cellstr(T01(5).channel_list);

T01(6).station = 'O56A';
T01(6).network = 'TA';
T01(6).template = '17_Mar';
T01(6).pWaveArrival = '2011-03-17 10:53:42.40';
T01(6).sWaveArrival = '2011-03-17 10:52:06.35';
T01(6).channel_list = ['BHE';'BHN';'BHZ'];
T01(6).channel_list = cellstr(T01(6).channel_list);

T02 = struct();
T02.station = 'N54A';
T02.network = 'TA';
T02.pWaveArrival = '2011-11-25 06:47:37.400';
T02.sWaveArrival = '2011-11-25 06:47:45.050';
T02.template = '25_Nov';
T02.trigger = 'S';
T02.channel_list = ['BHE';'BHN';'BHZ'];
T02.channel_list = cellstr(T02.channel_list);

T02(2).station = 'ACSO';
T02(2).network = 'US';
T02(2).pWaveArrival = '2011-11-25 06:48:01.310';
T02(2).sWaveArrival = '2011-11-25 06:48:25.900';
T02(2).template = '25_Nov';
T02(2).trigger = 'S';
T02(2).channel_list = ['BH1';'BH2';'BHZ'];
T02(2).channel_list = cellstr(T02(2).channel_list);

T02(3).station = 'O56A';
T02(3).network = 'TA';
T02(3).pWaveArrival = '2011-11-25 06:47:59.675';
T02(3).sWaveArrival = '2011-11-25 06:48:26.925';
T02(3).trigger = 'S';
T02(3).template = '25_Nov';
T02(3).channel_list = ['BHE';'BHN';'BHZ'];
T02(3).channel_list = cellstr(T02(3).channel_list);

T02(4).station = 'MCWV';
T02(4).network = 'US';
T02(4).pWaveArrival = '2011-11-25 06:47:55.730';
T02(4).sWaveArrival = '2011-11-25 06:48:17.750';
T02(4).template = '25_Nov';
T02(4).trigger = 'S';
T02(4).channel_list = ['BH1';'BH2';'BHZ'];
T02(4).channel_list = cellstr(T02(4).channel_list);

T02(5).station = 'ERPA';
T02(5).network = 'US';
T02(5).pWaveArrival = '2011-11-25 06:47:47.400';
T02(5).sWaveArrival = '2011-11-25 06:48:01.625';
T02(5).trigger = 'S';
T02(5).template = '25_Nov';
T02(5).channel_list = ['BH1';'BH2';'BHZ'];
T02(5).channel_list = cellstr(T02(5).channel_list);


T02(6).station = 'M54A';
T02(6).network = 'TA';
T02(6).pWaveArrival = '2011-11-25 06:47:42.675';
T02(6).sWaveArrival = '2011-11-25 06:47:53.875';
T02(6).trigger = 'S';
T02(6).template = '25_Nov';
T02(6).channel_list = ['BHE';'BHN';'BHZ'];
T02(6).channel_list = cellstr(T02(6).channel_list);



template_list = {T01;T02};

