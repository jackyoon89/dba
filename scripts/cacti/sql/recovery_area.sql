set heading off
set feedback off
set line 80
set pagesize 80

SELECT 'used:'||sum(PERCENT_SPACE_USED)||' reclaimable:'||sum(PERCENT_SPACE_RECLAIMABLE) FROM V$FLASH_RECOVERY_AREA_USAGE
/

exit
