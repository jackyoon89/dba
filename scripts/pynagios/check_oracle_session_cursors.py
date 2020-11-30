#!/usr/bin/env python

import os
import re
import sys
import getopt
sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Monitor
from database.database import Config
from database.database import Database

import fcntl
from utility.lock      import FileLock


critical_threshold=90
warning_threshold=80

def main(dbname):
    configuration = Config()

    try:
        configuration.set_ora_env(dbname)
    except ValueError as e:
        print (e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])

    # skip the check if its pluggable database.
    if configuration.get_attr_value(dbname, 'db_type') == 'pdb':
        print "{0} is a pluggable Database - Status Check is deprecated.".format(dbname)
        sys.exit(Monitor.ERROR["OK"])

    auth = configuration.parser.get(dbname, 'sys_user').split('/')
    sql = """select user_name, sid, used, allocated, round(used/allocated*100,2)
               from ( select user_name, sid, used, (select value from v$parameter where name = 'open_cursors') as allocated
                        from (select user_name, sid, count(*) used
                                from v$open_cursor
                               group by user_name, sid
                               order by 3 desc)
                        where rownum = 1)"""


    try:
        connection = Database.get_connection(auth[0], Config.get_pass(auth[1]).strip(), dbname)
        cursor = Database.get_cursor(connection)
        cursor.execute(sql)

        err_cnt =0
        critical_msg = ''
        warning_msg = ''

        result = cursor.fetchall()

    except BaseException as e:
        print(e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])
 
   
    
    for r in result:
               
        msg = "{0}(SID:{1}) - {2}/{3}({4}%)".format(r[0], r[1], r[2], r[3], r[4])

        if r[4] > critical_threshold:
            print "CRITICAL: {0}".format(msg)
            sys.exit(Monitor.ERROR["CRITICAL"])
        elif r[4] < critical_threshold and r[4] >= warning_threshold:
            print "WARNING: {0}".format(msg)
            sys.exit(Monitor.ERROR["WARNING"])
        else:
            print "OK: {0}".format(msg)
            sys.exit(Monitor.ERROR["OK"])


if __name__ == "__main__":

    # Check parameters
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'd:w:c:')
        optlist = dict([option for option in optlist])
        if args or len(optlist) == 0:
            raise getopt.GetoptError("Invalid parameter(s)")

    except getopt.GetoptError:
        print("\nUsage: check_oracle_session_cursors.py -d <DB_NAME> -w <warning_threshold> -c <critical_threshold>\n")
        sys.exit(Monitor.ERROR["UNKNOWN"])

    dbname = optlist.get('-d')
    warning_threshold = int(optlist.get('-w')) 
    critical_threshold = int(optlist.get('-c'))

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


