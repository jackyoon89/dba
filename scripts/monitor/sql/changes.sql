Rem Creating temp tables
CREATE TABLE PAM.MHFSTCLO_OLD
TABLESPACE PAMDATA
AS SELECT * FROM PAM.MHFSTCLO;






create table pam.mhfstclo
compress for all operations
nologging
tablespace TCLODATA
partition by range(closedate)  interval( numtoyminterval(3,'MONTH'))
subpartition by hash (portfolio) subpartitions 100 
(
   partition values less than ( to_date('2002/01/01','yyyy/mm/dd')) 
)
as select * from pam.MHFSTCLO_OLD 
/

