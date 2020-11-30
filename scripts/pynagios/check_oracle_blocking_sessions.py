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


def main(dbname, blockings):
    configuration = Config()

    try:
        configuration.set_ora_env(dbname)
    except ValueError as e:
        print (e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])

    # skip the check if its standby database and pluggable database.
    db_type    = configuration.get_attr_value(dbname, 'db_type')
    is_standby = configuration.get_attr_value(dbname, 'is_standby')

    if db_type == 'pdb' and is_standby == 'yes':
        print "{0} is a pdb on a standby Database - Status Check is deferred.".format(dbname)
        sys.exit(Monitor.ERROR["OK"])


    auth = configuration.parser.get(dbname, 'sys_user').split('/')
    sql = """select username, count(blocking_session)
               from v$session
              where username is not null
              having count(blocking_session) > &1
              group by username"""
 
    sql = sql.replace('&1', blockings)

    try:
        connection = Database.get_connection (auth[0], Config.get_pass(auth[1]).strip(), dbname)
        cursor = Database.get_cursor(connection)
        cursor.execute(sql)

    except BaseException as e:
        print "aaaaaa"
        print(e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])

    blocking_sessions = ''

    for rec in cursor:
        username, no_blockings = rec
        blocking_sessions += username + '(' + str(no_blockings) + '),'

    blocking_sessions = blocking_sessions[:-1].strip()
    

    if blocking_sessions:
        print "Blocking session count: " + blocking_sessions
        sys.exit(Monitor.ERROR["CRITICAL"])
    else:
        print "Nnumber of blocking sessions: OK"
        sys.exit(Monitor.ERROR["OK"])


if __name__ == "__main__":

    # Check parameters
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'd:w:c:')
        optlist = dict([option for option in optlist])
        
        if args or len(optlist) != 2:
            raise getopt.GetoptError("Invalid parameter(s).")

    except getopt.GetoptError:
        print("\nUsage: check_oracle_blocking_sessions.py -d <DB_NAME> -c blocking_count\n")
        sys.exit(Monitor.ERROR["UNKNOWN"])

    dbname, blockings = optlist.get('-d'), optlist.get('-c')

    if ( Monitor.is_monitor(dbname) == True):
        # Check instance lock
        try:
            lock_file = '/tmp/' + os.path.realpath(__file__).split('/')[-1].split('.')[0] + '_' + dbname + '.lck'
            with FileLock(lock_file, fcntl.LOCK_EX|fcntl.LOCK_NB):
                main(dbname.upper(), blockings)
        except IOError:
            print "Another instance of the same monitoring script is currently running..."
            sys.exit(Monitor.ERROR["WARNING"])
    else:
        print("Database Monitoring suspended for maintenance. - OK")
        sys.exit(Monitor.ERROR["OK"])


