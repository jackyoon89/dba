#!/usr/bin/env python
#
# Author: jyoon
# 
# 2016/06/29 - Check Oracle Connection
#
import os
import sys
import getopt
sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Util
from utility.util    import Monitor 
from database.database import Config
from database.database import Database

import fcntl
from utility.lock      import FileLock


def main(dbname):
    ''' Check database connectivity using the database name provided.
    This script returns Monitor.ERROR["OK"] or Monitor.ERROR["CRITICAL"]
    '''
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

    sql = """select logins from v$instance"""

    try:
        connection = Database.get_connection(auth[0], Config.get_pass(auth[1]).strip(), dbname)
        cursor = Database.get_cursor(connection)
        cursor.execute(sql)
        result = cursor.fetchall()

    except BaseException as e:
        print(e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])

  
    for r in result:
        if r[0] == 'ALLOWED':
            print "OK : Database logins - " + r[0]
            sys.exit(Monitor.ERROR["OK"])
        else:
            print "CRITICAL : Database logins - " + r[0]
            sys.exit(Monitor.ERROR["CRITICAL"])

        

if __name__ == "__main__":

    # Check parameters
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'd:')
        optlist = dict([option for option in optlist])

        if args or len(optlist) != 1:
            raise getopt.GetoptError("Invalid parameter(s).")

    except getopt.GetoptError:
        print("\nUsage: check_oracle_connection.py -d <DB_NAME>\n")
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


