clear all
warning off all

id='402';
YEAR='2011';
threshold=8;  %times the MAD above 0
% fid = fopen(['template_',id,'_times_new.txt'], 'w');
% fclose(fid);
strDAY=num2str(243,'%03d');
time=0:0.025:86400;   %seconds in a day



[N54A]=load(['N54A/CCC/',id,'/cccSum.',char(YEAR),'.',strDAY,'.mat']);
load(['N54A/Templates/Z/template_',id,'.mat']);
load(['N54A/Templates/N/template_',id,'.mat']);
load(['N54A/Templates/E/template_',id,'.mat']);
%Load in the time of the start of this template
N54A_template_time=template_Z(1,1);
%Adjust the time. For this first template, I do no adjustment - every other
%template will be relative to this one.
N54A_time_adjusted=time-0;
N54A_time_unadjusted=time;
ccc_N54A=N54A.ccc_STA;

[M54A]=load(['M54A/CCC/',id,'/cccSum.',char(YEAR),'.',strDAY,'.mat']);
load(['M54A/Templates/Z/template_',id,'.mat']);
load(['M54A/Templates/N/template_',id,'.mat']);
load(['M54A/Templates/E/template_',id,'.mat']);
%Load in the time of the start of this template
M54A_template_time=template_Z(1,1);
%Adjust the time of this template relative to N54A 
M54A_time_adjusted=time-(template_Z(1,1)-N54A_template_time);
M54A_time_unadjusted=time;
ccc_M54A=M54A.ccc_STA;


[MCWV]=load(['MCWV/CCC/',id,'/cccSum.',char(YEAR),'.',strDAY,'.mat']);
load(['MCWV/Templates/Z/template_',id,'.mat']);
load(['MCWV/Templates/N/template_',id,'.mat']);
load(['MCWV/Templates/E/template_',id,'.mat']);
%Load in the time of the start of this template
MCWV_template_time=template_Z(1,1);
%Adjust the time of this template relative to N54A 
MCWV_time_adjusted=time-(template_Z(1,1)-N54A_template_time);
MCWV_time_unadjusted=time;
ccc_MCWV=MCWV.ccc_STA;


%sum the cross correlations up
%This first one uses the unadjusted time, so this is not correct
ccc_sum_unadjusted=interp1(M54A_time_unadjusted(1:length(ccc_M54A)),ccc_M54A,time,'linear')+...
    interp1(N54A_time_unadjusted(1:length(ccc_N54A)),ccc_N54A,time,'linear')+...
    interp1(MCWV_time_unadjusted(1:length(ccc_MCWV)),ccc_MCWV,time,'linear');
%This second one adjusts the time before doing the interpolation, so it is
%correct.
ccc_sum_adjusted=interp1(M54A_time_adjusted(1:length(ccc_M54A)),ccc_M54A,time,'linear')+...
    interp1(N54A_time_adjusted(1:length(ccc_N54A)),ccc_N54A,time,'linear')+...
    interp1(MCWV_time_adjusted(1:length(ccc_MCWV)),ccc_MCWV,time,'linear');

figure
subplot(4,2,1)
plot(M54A_time_unadjusted,ccc_M54A)
title('Left Column is NOT Adjusted Properly')
ylabel('Station M54A')
xlim([63400 63460])
subplot(4,2,3)
plot(N54A_time_unadjusted,ccc_N54A)
ylabel('Station N54A')
xlim([63400 63460])
subplot(4,2,5)
plot(MCWV_time_unadjusted,ccc_MCWV)
ylabel('Station MCWV')
xlim([63400 63460])
subplot(4,2,7)
plot(time,ccc_sum_unadjusted)
ylabel('Sum of 3 Stations')
xlim([63400 63460])

subplot(4,2,2)
plot(M54A_time_adjusted,ccc_M54A)
title('Right Column IS Adjusted Properly')
ylabel('Station M54A')
xlim([63400 63460])
subplot(4,2,4)
plot(N54A_time_adjusted,ccc_N54A)
ylabel('Station N54A')
xlim([63400 63460])
subplot(4,2,6)
plot(MCWV_time_adjusted,ccc_MCWV)
ylabel('Station MCWV')
xlim([63400 63460])
subplot(4,2,8)
plot(time,ccc_sum_adjusted)
ylabel('Sum of 3 Stations')
xlim([63400 63460])