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

snapshot_interval = ('+00000 00:30:00.0','+00000 00:15:00.0')
snapshot_retention = ('+00030 00:00:00.0','+00031 00:00:00.0')

def main():
    configuration = Config()
    db_list = configuration.list_databases()
    hostname = socket.gethostname()


    sql = """select to_char(snap_interval), to_char(retention) from dba_hist_wr_control where dbid = (select dbid from v$database )"""

    for dbname in db_list:
        message = "Our standard AWR Snapshot configuratioin(interval/retention) is {0} minutes/{1} days.\nPlease review and fix.\n\n".format(snapshot_interval, snapshot_retention)

        if configuration.get_attr_value(dbname, 'is_standby') == 'yes': 
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
            #if i[0] <> snapshot_interval or i[1] <> snapshot_retention:
            if i[0] not in snapshot_interval or i[1] not in snapshot_retention:
                message += "Snapshot Interval : {0}\nSnapshot Retention : {1}\n".format(i[0], i[1])


                mail = Mail()
                mail.send('dba', 'WARNING : ' +  dbname + ' - AWR Snapshot Configuration is not meet our standard.', message )



if __name__ == "__main__":
    main()

