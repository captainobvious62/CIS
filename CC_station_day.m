%
%
%
%clear all
function [time,ccc_STA] = CC_station_day(id,NET,STA,YEAR,DAY,CHA_E,CHA_N,CHA_Z,FREQ)
% id = '25_Nov'
% YEAR = 2011
% DAY = 121
% STA = 'N54A'
% NET = 'TA'
YR = YEAR;
YEAR = num2str(YEAR);
DDD = DAY;
DAY = sprintf('%03d',DAY);
%40 Hz for 1 day, in seconds
time=0:1/FREQ:86400;

%Bandpass Filter
high_bp=12;
low_bp=1;

comp = [0,0,0];
LOC = '*';



fprintf('CC Station Day %s\n',datestr(now));
fprintf('%s %s %s %s\n',NET,STA,num2str(YEAR),num2str(DDD,'%03d'));




if exist([NET,'/',STA,'/mseed/',STA,'.',CHA_E,'.',num2str(YEAR),'.',num2str(DDD,'%03d')],'file') 
    
    load([NET,'/',STA,'/Templates/E/template_',id,'.mat']);
    E_seed = rdmseed(strcat([char(NET),'/',char(STA),'/mseed/',char(STA),'.',CHA_E,'.',YEAR,'.',DAY]));
    E_time_vec=datevec(cat(1,E_seed.t));
    day=median(E_time_vec(:,3));
    good_day_E=find(E_time_vec(:,3)==day);
    E_time=sum([[zeros(length(E_time_vec(good_day_E)),1),zeros(length(E_time_vec(good_day_E)),1),...
        zeros(length(E_time_vec(good_day_E)),1),3600*ones(length(E_time_vec(good_day_E)),1),...
        60*ones(length(E_time_vec(good_day_E)),1),ones(length(E_time_vec(good_day_E)),1)]'.*E_time_vec(good_day_E,:)'])';
    [B_E,I_E,J]=unique(E_time,'first');
    temp=cat(1,E_seed.d);
    E_data=temp(intersect(good_day_E,I_E));
    clear temp
    E_bp=bandpass(E_data,low_bp,high_bp,1/E_seed(1).SampleRate,3);
    ccc_E=normxcorr2(template_E(:,2),E_bp(I_E));
    clear E_seed E_time_vec E_data E_bp;
    
    comp(1) = 1;
end
if exist([NET,'/',STA,'/mseed/',STA,'.',CHA_N,'.',num2str(YEAR),'.',num2str(DDD,'%03d')],'file') 
    load([NET,'/',STA,'/Templates/N/template_',id,'.mat']);
    
    
    %N_seed = rdmseed(strcat(ls([char(STA),'/mseed/*BH',COMP,'*',YEAR,'*',DAY])));
    N_seed = rdmseed(strcat([char(NET),'/',char(STA),'/mseed/',char(STA),'.',CHA_N,'.',YEAR,'.',DAY]));
    N_time_vec=datevec(cat(1,N_seed.t));
    good_day_N=find(N_time_vec(:,3)==day);
    N_time=sum([[zeros(length(N_time_vec(good_day_N)),1),zeros(length(N_time_vec(good_day_N)),1),...
        zeros(length(N_time_vec(good_day_N)),1),3600*ones(length(N_time_vec(good_day_N)),1),...
        60*ones(length(N_time_vec(good_day_N)),1),ones(length(N_time_vec(good_day_N)),1)]'.*N_time_vec(good_day_N,:)'])';
    [B_N,I_N,J]=unique(N_time,'first');
    temp=cat(1,N_seed.d);
    N_data=temp(intersect(good_day_N,I_N));
    clear temp;
    N_bp=bandpass(N_data,low_bp,high_bp,1/N_seed(1).SampleRate,3);
    ccc_N=normxcorr2(template_N(:,2),N_bp(I_N));
    clear N_seed N_time_vec;
    comp(2) = 1;
end
if exist([NET,'/',STA,'/mseed/',STA,'.',CHA_Z,'.',num2str(YEAR),'.',num2str(DDD,'%03d')],'file')
    load([NET,'/',STA,'/Templates/Z/template_',id,'.mat']);
    
    %Z_seed = rdmseed(strcat(ls([char(STA),'/mseed/*BH',COMP,'*',YEAR,'*',DAY])));
    Z_seed = rdmseed(strcat([char(NET),'/',char(STA),'/mseed/',char(STA),'.',CHA_Z,'.',YEAR,'.',DAY]));
    Z_time_vec=datevec(cat(1,Z_seed.t));
    good_day_z=find(Z_time_vec(:,3)==day);
    Z_time=sum([[zeros(length(Z_time_vec(good_day_z)),1),zeros(length(Z_time_vec(good_day_z)),1),...
        zeros(length(Z_time_vec(good_day_z)),1),3600*ones(length(Z_time_vec(good_day_z)),1),...
        60*ones(length(Z_time_vec(good_day_z)),1),ones(length(Z_time_vec(good_day_z)),1)]'.*Z_time_vec(good_day_z,:)'])';
    [B_Z,I_Z,J]=unique(Z_time,'first');
    temp=cat(1,Z_seed.d);
    Z_data=temp(intersect(good_day_z,I_Z));
    clear temp;
    Z_bp=bandpass(Z_data,low_bp,high_bp,1/Z_seed(1).SampleRate,3);
    ccc_Z=normxcorr2(template_Z(:,2),Z_bp(I_Z));
    clear Z_seed Z_time_vec;
    comp(3) = 1;
end
%for 40 Hz
ccc_STA = zeros(1,3456001);
if comp(1) == 1;
    ccc_STA=ccc_STA + interp1(B_E,ccc_E(1:length(B_E)),time,'nearest');
end
if comp(2) == 1;
    ccc_STA = ccc_STA + interp1(B_N,ccc_N(1:length(B_N)),time,'nearest');
end
if comp(3) == 1
    ccc_STA = ccc_STA + interp1(B_Z,ccc_Z(1:length(B_Z)),time,'nearest');
end
%end


