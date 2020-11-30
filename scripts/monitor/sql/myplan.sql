set line 180
set pagesize 800

col operation format a50
col OBJECT_NAME format a40
col QBLOCK_NAME format a20

select id, CARDINALITY, lpad(' ', level*2)||operation||' '||options operation, OBJECT_NAME, QBLOCK_NAME, COST, TEMP_SPACE
 from plan_table
connect by (prior id = parent_id and prior plan_id = plan_id)
 start with plan_id = 1496
   and id = 1
/


