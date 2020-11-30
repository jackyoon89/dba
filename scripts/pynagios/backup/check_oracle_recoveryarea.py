#!/usr/bin/env python

import re
import os
import sys
import getopt
sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Monitor 
from database.database import Config
from database.database import Database

import fcntl
from utility.lock      import FileLock


critical_threshold = 0
warning_threshold = 0

def main(dbname):
    percentage_usage = 0

    configuration = Config()

    try:
        configuration.set_ora_env(dbname)
    except ValueError as e:
        print (e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])

    #if configuration.get_attr_value(dbname, 'is_standby') == 'yes':
    #    print "{0} is a Standby Database - Status Check deferred.".format(dbname)
    #    sys.exit(Monitor.ERROR["OK"])

    auth = configuration.parser.get(dbname, 'sys_user').split('/')
    sql  = 'select (sum(percent_space_used)  - sum(percent_space_reclaimable)) percent_usage from v$flash_recovery_area_usage'
 
    try:
        connection = Database.get_connection(auth[0], Config.get_pass(auth[1]).strip(), dbname)
        cursor = Database.get_cursor(connection)
        cursor.execute(sql)

        for r in cursor.fetchall():
            percentage_usage = r[0]             

    except BaseException as e:
        print(e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])


    if percentage_usage > critical_threshold:
        print "CRITICAL: Recovery Area Usage({0}%)".format(percentage_usage)
        sys.exit(Monitor.ERROR["CRITICAL"])

    elif percentage_usage > warning_threshold and percentage_usage < critical_threshold:
        print "WARNING: Recovery Area Usage({0}%)".format(percentage_usage)
        sys.exit(Monitor.ERROR["WARNING"])

    else:
        print "OK: Recovery Area Usage({0}%)".format(percentage_usage)
        sys.exit(Monitor.ERROR["OK"])
        

if __name__ == "__main__":

    # Check parameters
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'd:w:c:')
        optlist = dict([option for option in optlist])
        if args or len(optlist) == 0:
            raise getopt.GetoptError("Invalid parameter(s)")

    except getopt.GetoptError:
        print("\nUsage: check_oracle_recoveryarea.py -d <DB_NAME> -w <warning_threshold> -c <critical_threshold>\n")
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



