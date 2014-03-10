%"ord2date"    -by Mark
%
% Converts ordinal, or "julian" day to month/day, for a given year.
% [Inverse of Acklam's 'dayofyear' function]
%
% function ymd = ord2date(yyyyjjj)
% INPUT: rows of vectors with first 2:[yyyy ddd ...]
% OUTPUT: half datevector ymd of [yyyy mm dd]

function ymd = ord2date(yyyyjjj)
 y = yyyyjjj(:,1);
 julday = yyyyjjj(:,2);
 
 dayCounter = [0 31 59 90 120 151 181 212 243 273 304 334]; % month days
 
 dayCounter(3:12) = dayCounter(3:12) + (...         check for leap year      
     ((mod(y,4)==0) && ((mod(y,100) ~= 0) ...       add day to months
     || (mod(y,400) == 0)))...                      after Mar if true
     );
 month = max(find(dayCounter < julday));
 day = julday - dayCounter(month);
 ymd = [y, month, day];
end
 