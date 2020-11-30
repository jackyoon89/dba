select inst_id, PROCESS, STATUS, THREAD#, SEQUENCE#, BLOCK#, BLOCKS
FROM gv$managed_standby where process<>'ARCH' ;

