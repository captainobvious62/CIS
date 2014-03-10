%For running in the matlab terminal, not via qsub
clear all


for id = {'402'}
    for STA = {'M54A','N54A','MCWV'} %'M54A','N54A','ACSO','MCWV'}
        for YEAR = {'2011'}
            for DAY=243 %001:365
                strDAY=num2str(DAY,'%03d');
                disp(['Processing day ',strDAY,' of year ',char(char(YEAR)),' for station ',char(STA),', template ',char(id)])
                ccc_STA=[];
                [time,ccc_STA]=station_day_ccc(char(id),char(STA),char(YEAR),strDAY);              
                save(['./',char(STA),'/CCC/',char(id),'/cccSum.',char(YEAR),'.',strDAY,'.mat'],'ccc_STA');
            end
        end
    end
end
