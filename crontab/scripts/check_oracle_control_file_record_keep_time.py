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

control_file_record_keep_time = 31

def main():
    configuration = Config()
    db_list = configuration.list_databases()
    hostname = socket.gethostname()

    sql = """select value
               from v$parameter
              where name = 'control_file_record_keep_time'"""


    for dbname in db_list:
        message = "Our standard control_file_record_keep_time is {0}.  Please review and fix.\n\n".format(control_file_record_keep_time)

        #if  configuration.get_attr_value(dbname, 'db_type') == 'pdb' or configuration.get_attr_value(dbname, 'is_standby') == 'yes':
        if  configuration.get_attr_value(dbname, 'db_type') == 'pdb':
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
            if int(i[0]) < control_file_record_keep_time:
                #print dbname + " : " + str(i[0])
                message += "control_file_record_keep_time : {0}\n".format(i[0])


                mail = Mail()
                mail.send('dba', "WARNING : {0} - control_file_record_keep_time : {1}".format(dbname, i[0]), message )



if __name__ == "__main__":
    main()

