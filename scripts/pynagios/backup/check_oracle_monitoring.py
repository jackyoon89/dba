#!/usr/bin/env python

import re
import os
import sys
sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))


from utility.util    import Monitor 
from database.database import Config

import fcntl
from utility.lock      import FileLock


def main():
    monitoring_status = []
    result = ''

    configuration = Config()
 
    for db in configuration.list_databases():
        if Monitor.is_monitor(db) == True:
            monitoring_status.append(db + '(Yes)') 
        else:
            monitoring_status.append(db + '(No)') 
    
    result = ",".join(monitoring_status) 

    if re.search(r'\(No\)', result, re.M|re.I ) == None:
        print result
        sys.exit(Monitor.ERROR["OK"])
    else:
        print result
        sys.exit(Monitor.ERROR["CRITICAL"])


if __name__ == "__main__":

    # Check instance lock
    try:
        lock_file = '/tmp/' + os.path.realpath(__file__).split('/')[-1].split('.')[0] + ".lck"
        with FileLock(lock_file, fcntl.LOCK_EX|fcntl.LOCK_NB):

            main()

    except IOError:
        print "Another instance of the same monitoring script is currently running..."
        sys.exit(Monitor.ERROR["WARNING"])

