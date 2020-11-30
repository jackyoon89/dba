#!/usr/bin/env python

import sys
import os
import fcntl
import time

sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))
from utility.util    import Monitor
from utility.lock import FileLock 

def main(): 
 
    try: 
        with FileLock("/tmp/check_test.lck", fcntl.LOCK_EX|fcntl.LOCK_NB): 
            print "Start: %s" % time.ctime() 
            print "PID: %s" % os.getpid() 
            time.sleep(10) 
            print "Finish: %s" % time.ctime() 
    except IOError:
        print "Another instance is currently running..."
        sys.exit(Monitor.ERROR['WARNING'])
 
    sys.exit(Monitor.ERROR['OK'])
 
if __name__ == '__main__': 
    main() 

