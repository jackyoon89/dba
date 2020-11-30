#!/usr/bin/env python
# 
# Author: jyoon
# 
# 2020/02/20 - Check the existance of tempfile(s)
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

    #if configuration.get_attr_value(dbname, 'is_standby') == 'yes':
    #    print "{0} is a Standby Database - Status Check deferred.".format(dbname)
    #    sys.exit(Monitor.ERROR["OK"])

    auth = configuration.parser.get(dbname, 'sys_user').split('/')
    sql = """select file#, name
               from v$tempfile
              where status = 'ONLINE'
                and enabled = 'READ WRITE'"""


    try:
        connection = Database.get_connection(auth[0], Config.get_pass(auth[1]).strip(), dbname)
        cursor = Database.get_cursor(connection)
        cursor.execute(sql)

        temp_files = [rec for rec in cursor]

    except BaseException as e:
        print(e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])

    # Check execution status
    if len(temp_files) == 0:
        print "CRITICAL: No tempfiles available on the database."
        sys.exit(Monitor.ERROR["CRITICAL"])
    else:
        tempfile_numbers = [temp_file[0] for temp_file in temp_files]
        print "OK: tempfiles(" + ', '.join([str(tempfile_number) for tempfile_number in tempfile_numbers]) + ")"
        sys.exit(Monitor.ERROR["OK"])

        

if __name__ == "__main__":

    # Check parameters
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'd:')
        optlist = dict([option for option in optlist])

        if args or len(optlist) == 0:
            raise getopt.GetoptError("Invalid parameter(s)")

    except getopt.GetoptError:
        print("\nUsage: check_oracle_scheduler_jobs.py -d <DB_NAME>\n")
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


