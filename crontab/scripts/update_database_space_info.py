#!/usr/bin/env python
#
# Author: jyoon
#
# 2020/07/18 - Check logfile size and number of groups
#
import sys
import os
import re
#import getopt
import socket
sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util      import Util
from utility.util      import Monitor 
from utility.util      import Mail
from database.database import Config
from database.database import Database


def main():
    configuration = Config()
    db_list = configuration.list_databases()
    hostname = socket.gethostname()

    sql = """DECLARE
                table_not_exist exception; 
                PRAGMA EXCEPTION_INIT(table_not_exist, -942);
               
                v_tablespace_name varchar2(30);
                table_in_users_table_tbs exception;
                PRAGMA EXCEPTION_INIT(table_in_users_table_tbs, -20001);
             
             BEGIN
                execute immediate 'merge into db_info a
                using (select (select name from v$database) name, a.assigned, (a.assigned - b.free) used 
                         from (select round(sum(bytes)/1024/1024/1024) assigned
                                 from dba_data_files) a,
                              (select round(sum(bytes)/1024/1024/1024) free
                                 from dba_free_space) b) b
                   on (a.db_name = b.name)
                when matched then
                   update set a.last_updated = sysdate,
                              a.assigned = b.assigned,
                              a.used = b.used
                when not matched then
                   insert (db_name, last_updated, assigned, used )
                   values ( b.name, sysdate, b.assigned, b.used)';

                commit;

                select tablespace_name into v_tablespace_name
                  from dba_tables where table_name = 'DB_INFO';
       
                if v_tablespace_name = 'USERS' then
                    raise table_in_users_table_tbs;
                end if;

             EXCEPTION 
             WHEN table_not_exist THEN
                execute immediate 'create table db_info ( db_name varchar2(30) not null, last_updated date, assigned number, used number )';

             WHEN table_in_users_table_tbs THEN
                execute immediate 'alter table db_info move tablespace system';
          
             WHEN others THEN
                NULL;
             END;"""


    for dbname in db_list:
        if  configuration.get_attr_value(dbname, 'is_standby') == 'yes':
            continue

        # Set Oracle Related Environ variables
        ora_home = configuration.get_attr_value(dbname,'oracle_home')
        try:
            os.environ['ORACLE_HOME'] = ora_home
            os.environ['LD_LIBRARY_PATH'] = ora_home + '/lib'
        except ValueError as e:
            print (e.args[0])


        auth = configuration.parser.get(dbname, 'sys_user').split('/')
 
        try:
            connection = Database.get_connection (auth[0], Config.get_pass(auth[1]).strip(), dbname)
            cursor = Database.get_cursor(connection)
            cursor.execute(sql)

        except BaseException as e:
            print(e.args[0])



if __name__ == "__main__":
    main()

