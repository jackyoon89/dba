SELECT  floor(((sysdate-max(NEXT_TIME))*24*60*60)/3600)|| ' Hour(s) ' ||
          floor((((sysdate-max(NEXT_TIME))*24*60*60) -
          floor(((sysdate-max(NEXT_TIME))*24*60*60)/3600)*3600)/60) || ' Minute(s) ' ||
          round((((sysdate-max(NEXT_TIME))*24*60*60) -
          floor(((sysdate-max(NEXT_TIME))*24*60*60)/3600)*3600 -
          (floor((((sysdate-max(NEXT_TIME))*24*60*60) -
          floor(((sysdate-max(NEXT_TIME))*24*60*60)/3600)*3600)/60)*60) ))|| ' Second(s) ' "Standby ARCHIVELOG GAP/LAG"
from gv$archived_log where applied ='YES';

