#!/usr/bin/env python
# 
# Author: jyoon
# 
# 2016/06/27 - Check failed scheduler jobs
#
import sys
import os
import re
import getopt
sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Util
from utility.util    import Monitor 
from database.database import Config
from database.database import Database

import fcntl
from utility.lock      import FileLock


def main(dbname):
    configuration = Config()

    try:
        configuration.set_ora_env(dbname)
    except ValueError as e:
        print (e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])

    if configuration.get_attr_value(dbname, 'is_standby') == 'yes':
        print "{0} is a Standby Database - Status Check deferred.".format(dbname)
        sys.exit(Monitor.ERROR["OK"])

    auth = configuration.parser.get(dbname, 'sys_user').split('/')

    sql = """select * 
               from ( select START_TIME, END_TIME, INPUT_TYPE, STATUS
                        from V$RMAN_BACKUP_JOB_DETAILS
                       where end_time > trunc(sysdate - 1)
                       order by SESSION_KEY desc) 
              where rownum = 1"""

    try:
        connection = Database.get_connection(auth[0], Config.get_pass(auth[1]).strip(), dbname)
        cursor = Database.get_cursor(connection)
        cursor.execute(sql)
        result = cursor.fetchall()

    except BaseException as e:
        print(e.args[0])
        print "HERE"
        sys.exit(Monitor.ERROR["CRITICAL"])


    if len(result) == 0:
        print "CRITICAL: No backup was taken within 24 hours."
        sys.exit(Monitor.ERROR["CRITICAL"])

    for r in result:
        if r[3] <> 'COMPLETED':
            print "CRITICAL: Latest " + r[2].capitalize() + " backup status : " + r[3] + "(" + str(r[0]) + " ~ " + str(r[1]) + ")"
            sys.exit(Monitor.ERROR["CRITICAL"])
        else:
            print "OK: Latest " + r[2].capitalize() + " backup status : " + r[3] + "(" + str(r[0]) + " ~ " + str(r[1]) + ")"
            sys.exit(Monitor.ERROR["OK"])

        

if __name__ == "__main__":

    # Check parameters
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'd:')
        optlist = dict([option for option in optlist])

        if args or len(optlist) == 0:
            raise getopt.GetoptError("Invalid parameter(s)")

    except getopt.GetoptError:
        print("\nUsage: check_oracle_rman_backup.py -d <DB_NAME>\n")
        sys.exit(Monitor.ERROR["UNKNOWN"])

    dbname = optlist.get('-d')

    if ( Monitor.is_monitor(dbname) == True ):
        # Check instance lock
        try:
            lock_file = '/tmp/' + os.path.realpath(__file__).split('/')[-1].split('.')[0] + '_' + dbname + '.lck'
            with FileLock(lock_file, fcntl.LOCK_EX|fcntl.LOCK_NB):
                main(dbname.upper())
        except IOError:
            print "Another instance of the same monitoring script is currently running..."
            sys.exit(Monitor.ERROR["WARNING"])
    else:
        print("Database Monitoring suspended for maintenance. - OK")
        sys.exit(Monitor.ERROR["OK"])


