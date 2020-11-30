set line 180

select sid, type, id1, id2, lmode, request, block, 
       to_char(trunc(id1/power(2,16))) USN,
       bitand(id1, to_number('ffff','xxxx')) + 0 SLOT,
       id2 SQN
  from v$lock
 where type = 'TX';

