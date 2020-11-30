#!/usr/bin/env python

import os
import sys
import re
import getopt
sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Monitor 
from database.database import Config
from database.database import Database

import fcntl
from utility.lock      import FileLock



critical_threshold = 20
warning_threshold = 10 

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

#    sql="""select sum(to_number(substr(value,2,2))*24*60 + to_number(substr(value,5,2))*60 + to_number(substr(value,8,2)) ||'.'|| to_number(substr(value,11,2)))
#             from v$dataguard_stats
#            where name in ('transport lag','apply lag')"""
    sql = """select sum(to_number(substr(value,2,2))*24*60 + to_number(substr(value,5,2))*60 + to_number(substr(value,8,2)) ||'.'|| to_number(substr(value,11,2)))
               from (select nvl(value, '+00 00:00:00') value
                       from v$dataguard_stats
                      where name in ('transport lag','apply lag'))"""


    auth = configuration.parser.get(dbname, 'sys_user').split('/')

    try:
        connection = Database.get_connection(auth[0], Config.get_pass(auth[1]).strip(), dbname)
        cursor = Database.get_cursor(connection)
        cursor.execute(sql)
        rec = cursor.fetchall()

    except BaseException as e:
        print(e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])

    for r in rec:
        if r[0] > critical_threshold:
            print "CRITICAL: {0} Standby database lagged {1} min.".format(dbname, r[0])
            sys.exit(Monitor.ERROR["CRITICAL"])

        elif warning_threshold <= r[0] < critical_threshold:
            print "WARNING: {0} Standby database lagged {1} min.".format(dbname, r[0])
            sys.exit(Monitor.ERROR["WARNING"])

        elif r[0] == None:
            print "OK: {0} database is not a standby database".format(dbname) 
        else:
            print "OK: {0} Standby database lagged {1} min.".format(dbname, r[0])
            sys.exit(Monitor.ERROR["OK"])

        

if __name__ == "__main__":

    # Check parameters 
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'd:w:c:')
        optlist = dict([option for option in optlist])

        if args or len(optlist) == 0:
            raise getopt.GetoptError("Invalid parameter(s)")

    except getopt.GetoptError:
        print("\nUsage: check_oracle_standby_lagtime.py -d DB_NAME -w warning_threshold -c critical_threshold \n")
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


