#!/usr/bin/env python
#
# Author: jyoon
#
# 2020/02/14 - Check if the database has configured dbms_audit_mgmt
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

    sql = """select TABLESPACE_NAME, DECODE(BIGFILE,'YES','BIGFILE','SMALLFILE') from dba_tablespaces
              where TABLESPACE_NAME = (select value from v$parameter where name = 'undo_tablespace')
                and BIGFILE = 'NO'
              union
             select TABLESPACE_NAME, DECODE(BIGFILE,'YES','BIGFILE','SMALLFILE') from dba_tablespaces
              where TABLESPACE_NAME = (select PROPERTY_VALUE from database_properties where property_name = 'DEFAULT_TEMP_TABLESPACE')
                and BIGFILE = 'NO'"""

    for dbname in db_list:
        message = "Please review below tablespace and convert them to bigfile tablespace.\n\n"
        if   configuration.get_attr_value(dbname, 'is_standby') == 'yes':
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
            rec = cursor.fetchall() 

        except BaseException as e:
            print(e.args[0])

        if len(rec) <> 0:
            for i in rec:
                message += i[0] + '(' + i[1]  + ')\n';  

            mail = Mail()
            mail.send('dba', 'WARNING : ' +  dbname + ' - SMALLFILE TEMP/UNDO tablespace found..', message )
            #print message



if __name__ == "__main__":
    main()

