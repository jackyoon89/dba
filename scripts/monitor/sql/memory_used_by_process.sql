SELECT spid, username, program, background, 
            pga_max_mem      max,
            pga_alloc_mem    alloc,
            pga_used_mem     used,
            pga_freeable_mem free
FROM V$PROCESS
where spid = &SPID
/
