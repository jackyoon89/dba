select 
   a.sid,
   a.type,
   decode(a.lmode,
   0, 'None',           /* Mon Lock equivalent */
   1, 'Null',           /* N */
   2, 'Row-S (SS)',     /* L */
   3, 'Row-X (SX)',     /* R */
   4, 'Share',          /* S */
   5, 'S/Row-X (SSX)',  /* C */
   6, 'Exclusive',      /* X */
   to_char(a.lmode)) mode_held,
   decode(a.request,
   0, 'None',           /* Mon Lock equivalent */
   1, 'Null',           /* N */
   2, 'Row-S (SS)',     /* L */
   3, 'Row-X (SX)',     /* R */
   4, 'Share',          /* S */
   5, 'S/Row-X (SSX)',  /* C */
   6, 'Exclusive',      /* X */
   to_char(a.request)) mode_requested,
   to_char(a.id1) lock_id1, to_char(a.id2) lock_id2
from v$lock a
   where a.type not in ('MR', 'DM', 'RT')
   and  (id1,id2) in
        (select b.id1, b.id2 from v$lock b where b.id1=a.id1 and
        b.id2=a.id2 and b.request>0)
order by a.lmode desc , a.sid
/

