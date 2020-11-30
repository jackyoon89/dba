#!/usr/bin/env python
#
# Author: jyoon
#
# 2020/02/14 - Check if the database has configured dbms_audit_mgmt
#
import sys
import os
import re
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
    hostname = socket.getfqdn().split('.')
    group_name = hostname[1] + '.' + hostname[2]

    message = ""
    for dbname in db_list:
        if   configuration.get_attr_value(dbname, 'is_standby') == 'yes':
            continue

        # Set Oracle Related Environ variables
        ora_home = configuration.get_attr_value(dbname,'oracle_home')
        ora_sid  = configuration.get_attr_value(dbname,'oracle_sid')
        try:
            os.environ['ORACLE_HOME'] = ora_home
            os.environ['LD_LIBRARY_PATH'] = ora_home + '/lib'
        except ValueError as e:
            print (e.args[0])


        auth = configuration.parser.get(dbname, 'sys_user').split('/')
        sql = """select :dbname, :ora_sid, sample_id, to_char(sample_time,'yyyy/mm/dd hh24:mi:ss') sample_time, session_id, session_serial#, 
                        session_type, (select username from dba_users u where u.user_id = a.user_id) username, sql_id, sql_plan_hash_value, event, p1text, p1, 
                        p2text, p2, p3text, p3, wait_class, wait_time, session_state, time_waited, blocking_session_status, blocking_session, blocking_session_serial#, 
                        time_model, program, module, action, machine, pga_allocated, temp_space_allocated, :group_name
                   from v$active_session_history a
                  where to_char(sysdate,'yyyy/mm/dd hh24:mi:ss') = to_char(current_timestamp,'yyyy/mm/dd hh24:mi:ss')
                    and sample_time > sysdate - 5/1440
                    and con_id = sys_context('userenv','con_id')
                   union all
                 select :dbname, :ora_sid, sample_id, to_char(new_time(sample_time,'EDT','GMT'),'yyyy/mm/dd hh24:mi:ss') sample_time, session_id, session_serial#, 
                        session_type, (select username from dba_users u where u.user_id = a.user_id) username, sql_id, sql_plan_hash_value, event, p1text, p1, 
                        p2text, p2, p3text, p3, wait_class, wait_time, session_state, time_waited, blocking_session_status, blocking_session, blocking_session_serial#, 
                        time_model, program, module, action, machine, pga_allocated, temp_space_allocated, :group_name
                   from v$active_session_history a
                  where to_char(sysdate,'yyyy/mm/dd hh24:mi:ss') <> to_char(current_timestamp,'yyyy/mm/dd hh24:mi:ss')
                    and con_id = sys_context('userenv','con_id')
                    and sample_time > sysdate - 5/1440"""
 
        try:
            connection = Database.get_connection (auth[0], Config.get_pass(auth[1]).strip(), dbname)
            cursor = Database.get_cursor(connection)
            cursor.execute(sql, (dbname, ora_sid, group_name))

        except BaseException as e:
            print(e.args[0])
            return


        #for rec in cursor:
        #    csv_str = ','.join([str(r) for r in rec])
        #    print csv_str

        with open('/tmp/oracle_ash.csv.tmp','a') as fh:
            for rec in cursor:
                csv_str = ','.join([str(r) for r in rec])
                fh.write(csv_str)
                fh.write("\n")

    os.rename('/tmp/oracle_ash.csv.tmp', '/tmp/oracle_ash.csv')

if __name__ == "__main__":
    main()

