set line 180
col object_name format a35
col owner       format a25
col object_type format a20

select bh.file#, bh.dbablk, bh.class, 
       decode(bh.state,0,'free',1,'xcur',2,'scur',3,'cr',4,'read',5,'mrec',6,'irec',7,'write',8,'pi',9,'memory',10,'mwrite',11,'donated') as status,
       decode(bitand(bh.flag,1),0,'N','Y') as dirty, bh.tch,o.owner,o.object_name,o.object_type
  from x$bh bh, dba_objects o
 where bh.obj = o.data_object_id
   and bh.hladdr = '&1'
 order by tch desc;

