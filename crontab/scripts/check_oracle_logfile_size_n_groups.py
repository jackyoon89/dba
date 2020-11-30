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

min_size_mb = 200
min_no_groups = 5

def main():
    configuration = Config()
    db_list = configuration.list_databases()
    hostname = socket.gethostname()

    sql = """select thread#, group#, bytes/1024/1024
               from v$log
              where thread# = (select thread#
                                 from v$thread
                                where instance = (select instance_name 
                                                    from v$instance))"""


    for dbname in db_list:
        message = "Our standard online redolog size should be minumum {0}M and minimum number of log groups should be {1}.\nPlease review and fix.\n\n".format(min_size_mb, min_no_groups)

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

        number_of_groups = len(rec)
        has_smaller_logfile = False
        has_smaller_logfile = True in (i[2] < min_size_mb for i in rec)

        #print dbname + " : " + str(number_of_groups) + " : " + str(has_smaller_logfile)

        if number_of_groups < min_no_groups or has_smaller_logfile == True:
            message += "Thread#          | Group#        | Size(MB)\n" 
            message += "----------------------------------------------\n"
            
            for i in rec:
                message += "   {0}                 {1}            {2}     \n".format(i[0], i[1], i[2])  


            mail = Mail()
            mail.send('dba', 'WARNING : ' +  dbname + ' - Redo log file size or Number of groups are not meet our standard..', message )



if __name__ == "__main__":
    main()

