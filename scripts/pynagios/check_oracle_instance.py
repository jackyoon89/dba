#!/usr/bin/env python
#
# Author: jyoon
#
# 2016/05/23 - Check Oracle Instance
#
import os
import sys
import getopt
sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Util
from utility.util    import Monitor
from database.config import Config

import fcntl
from utility.lock      import FileLock


def main(dbname):
    configuration = Config()

    try:
        configuration.set_ora_env(dbname)
    except ValueError as e:
        print (e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])


    oracle_sid = configuration.get_attr_value(dbname, 'oracle_sid');

    if Util.is_process_running(__file__ , "ora_pmon_" + oracle_sid):
        print "OK: Oracle Instance {0} - UP".format(oracle_sid)
        sys.exit(Monitor.ERROR["OK"])
    else:
        print "CRITICAL: Oracle Instance {0} - DOWN".format(oracle_sid)
        sys.exit(Monitor.ERROR["CRITICAL"])


if __name__ == "__main__":

    # Check parameters
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'd:')
        optlist = dict([option for option in optlist])
  
        if args or len(optlist) != 1:
            raise getopt.GetoptError("Invalid parameter(s).")
  
    except getopt.GetoptError:
        print("\nUsage: check_oracle_instance.py -d <DB_NAME>\n")
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
        print("OK: Database Monitoring suspended for maintenance.")
        sys.exit(Monitor.ERROR["OK"])


