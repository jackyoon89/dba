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
    parameters = {}

    sql = """SELECT NAME, nvl(VALUE,'NULL')
               FROM V$PARAMETER
              WHERE NAME IN ('audit_trail','audit_sys_operations','audit_syslog_level')"""

    for dbname in db_list:
        # Run the script only for production database
        if not re.match("P\d+.*", dbname) and not re.match("O01\d+.*", dbname):
            continue

        message = """Below audit parameters are our standard. 
Please fix accordingly.

NAME                           VALUE              
------------------------------ ------------------------------
audit_trail                    DB 
audit_sys_operations           TRUE                         
audit_syslog_level                                            
\n\n"""


        if  configuration.get_attr_value(dbname, 'is_standby') == 'yes' or configuration.get_attr_value(dbname, 'db_type') == 'pdb':
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
                    parameters[i[0]] = i[1]
   
                if parameters.get('audit_trail') <> 'DB' or parameters.get('audit_syslog_level') <> 'NULL' or parameters.get('audit_sys_operations') <> 'TRUE':
                    message += "These are the current values on the database.\n"
                    message += "---------------------------------------------\n"
                    message += "audit_trail : " + parameters.get('audit_trail') + "\n"
                    message += "audit_sys_operations : " + parameters.get('audit_sys_operations') + "\n"
                    message += "audit_syslog_level: " + parameters.get('audit_syslog_level') + "\n"

                    mail = Mail()
                    mail.send('dba', 'WARNING : Database Audit Parameters. - (' +  dbname + ')', message )
                    #print message

        except BaseException as e:
            print(e.args[0])




if __name__ == "__main__":
    main()

