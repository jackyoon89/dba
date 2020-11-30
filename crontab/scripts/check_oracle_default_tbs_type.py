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

default_tbs_type = 'BIGFILE'

def main():
    configuration = Config()
    db_list = configuration.list_databases()
    hostname = socket.gethostname()

    sql = """select property_value 
               from database_properties
              where property_name = 'DEFAULT_TBS_TYPE'"""


    for dbname in db_list:
        message = "Our standard DEFAULT_TBS_TYPE is {0}.  Please review and fix.\n\n".format(default_tbs_type)

        if  configuration.get_attr_value(dbname, 'db_type') == 'pdb' or configuration.get_attr_value(dbname, 'is_standby') == 'yes':
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


        for i in rec:
            if i[0] <> default_tbs_type:
                message += "DEFAULT_TBS_TYPE : {0}\n".format(i[0])


                mail = Mail()
                mail.send('dba', "WARNING : {0} - Standard Tablespace Type : {1}".format(dbname, i[0]), message )



if __name__ == "__main__":
    main()

