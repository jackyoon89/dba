#!/usr/bin/env python
#
# Author: jyoon
#
# 2020/09/28 - Check if privileged accounts like sys and sysdba are locked.
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

    sql = """SELECT USERNAME, ACCOUNT_STATUS
               FROM DBA_USERS
              WHERE USERNAME IN ('SYS','SYSTEM')
                AND ACCOUNT_STATUS = 'OPEN'"""

    for dbname in db_list:
        message = "Please disable below auto tasks.\n\n"

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

            if len(rec) <> 0:
                for i in rec:
                    message += i[0] + ' (' + i[1]  + ')\n\n';  

                mail = Mail()
                mail.send('dba', 'WARNING : Privileged Account(s) opened. - (' +  dbname + ')', message )
                #print message

        except BaseException as e:
            print(e.args[0])




if __name__ == "__main__":
    main()

