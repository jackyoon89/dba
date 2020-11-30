create table test
          (sno number(6),
          last_name varchar2(30),
          salary number(6))
          partition by range(sno)
          Interval  (1)
          ( partition values less than (2) );

insert into test values (2,'Michel',30000);

insert into test values (3,'Michel',35000);

insert into test values (4,'Michel',35000);

insert into test values (5,'Michel',35000);

insert into test values (6,'Michel',35000);

insert into test values (7,'Michel',35000);



select table_name, PARTITION_NAME,HIGH_VALUE,INTERVAL from user_tab_partitions
/

select table_name,partition_name,num_rows
 from user_tab_partitions
where table_name='TEST' 
order by partition_name;
