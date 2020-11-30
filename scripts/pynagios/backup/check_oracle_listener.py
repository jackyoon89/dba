#!/usr/bin/env python
#
# Author: jyoon 
#
# 2016/06/26 - Checking listener process
#
import os
import sys
import getopt
sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Util
from utility.util    import Monitor

import fcntl
from utility.lock      import FileLock


def main(listener):

    if Util.is_process_running( __file__, listener):
        print "Oracle Listener({0}) - UP(OK)".format(listener)
        sys.exit(Monitor.ERROR["OK"])
    else:
        print "Oracle Listener({0}) - DOWN(CRITICAL)".format(listener)
        sys.exit(Monitor.ERROR["CRITICAL"])


if __name__ == "__main__":

    # Check instance lock
    try:
        lock_file = '/tmp/' + os.path.realpath(__file__).split('/')[-1].split('.')[0] + ".lck"
        with FileLock(lock_file, fcntl.LOCK_EX|fcntl.LOCK_NB):

            # Check parameters
            try:
                optlist, args = getopt.getopt(sys.argv[1:], 'l:')
                optlist = dict([option for option in optlist])
  
                if args or len(optlist) != 1:
                    raise getopt.GetoptError("Invalid parameter(s).")
  
            except getopt.GetoptError:
                print("\nUsage: check_oracle_listener.py -l <LISTENER>\n")
                sys.exit(Monitor.ERROR["UNKNOWN"])
  
            listener = optlist.get('-l')
  
            main(listener.upper())

    except IOError:
        print "Another instance of the same monitoring script is currently running..."
        sys.exit(Monitor.ERROR["WARNING"])

