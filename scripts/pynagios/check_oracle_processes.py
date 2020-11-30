#!/usr/bin/env python
#
# Author: jyoon
#
# 2016/05/27 - Check Oracle process allocation vs. defined max number of processes
#
import sys
import os
import re
import getopt
sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util      import Util
from utility.util      import Monitor 
from database.database import Config
from database.database import Database

import fcntl
from utility.lock      import FileLock


def main(dbname, warning, critical):
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
    sql = """select (select count(*) from v$process) current_value,  to_number(value) max_value 
               from v$parameter where name = 'processes'"""

    try:
        connection = Database.get_connection (auth[0], Config.get_pass(auth[1]).strip(), dbname)
        cursor = Database.get_cursor(connection)
        cursor.execute(sql)

    except BaseException as e:
        print(e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])


    current, max = [processes for rec in cursor for processes in rec]

    percent_usage = round((float(current) / float(max) ) * 100, 2)

    if (percent_usage >= float(critical)):
        print "CRITICAL: Oracle Processes HWM({0}% - {1}/{2})".format(percent_usage, current, max)
        sys.exit(Monitor.ERROR["CRITICAL"])
    elif (percent_usage >= float(warning) and percent_usage < float(critical)):
        print "WARNING: Oracle Processes HWM({0}% - {1}/{2})".format(percent_usage, current, max)
        sys.exit(Monitor.ERROR["WARNING"])
    else:
        print "OK: Oracle Processes HWM({0}% - {1}/{2})".format(percent_usage, current, max)
        sys.exit(Monitor.ERROR["OK"])
        

if __name__ == "__main__":

    # Check parameters
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'd:w:c:')
        optlist = dict([option for option in optlist])
        
        if args or len(optlist) != 3:
            raise getopt.GetoptError("Invalid parameter(s).")

    except getopt.GetoptError:
        print("\nUsage: check_oracle_processes.py -d <DB_NAME> -w percentUsage -c percentUsage\n")
        sys.exit(Monitor.ERROR["UNKNOWN"])

    dbname, warning, critical   = optlist.get('-d'), optlist.get('-w'), optlist.get('-c')

    if ( Monitor.is_monitor(dbname) == True):
        # Check instance lock
        try:
            lock_file = '/tmp/' + os.path.realpath(__file__).split('/')[-1].split('.')[0] + '_' + dbname + '.lck'
            with FileLock(lock_file, fcntl.LOCK_EX|fcntl.LOCK_NB):
                main(dbname.upper(), warning, critical)
        except IOError:
            print "Another instance of the same monitoring script is currently running..."
            sys.exit(Monitor.ERROR["WARNING"])
    else:
        print("Database Monitoring suspended for maintenance. - OK")
        sys.exit(Monitor.ERROR["OK"])


