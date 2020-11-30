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


    message = ""
    for dbname in db_list:
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
            is_initialized = cursor.callfunc('DBMS_AUDIT_MGMT.is_cleanup_initialized', bool, [15])

        except BaseException as e:
            print(e.args[0])

        if is_initialized == True:
            message += "Database : " + dbname + "\n"
            message += "DBMS_AUDIT_MGMT is initialized: OK\n\n"
        else:
            message += "Database : " + dbname  + "\n"
            message += "DBMS_AUDIT_MGMT is not initialized: WARNING\n\n"


    if re.findall(r'.*WARNING.*', message):
        mail = Mail()
        mail.send('dba', 'WARNING : DBMS_AUDIT_MGMT Configuration missed.', message )



if __name__ == "__main__":
    main()

