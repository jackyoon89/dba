#!/usr/bin/env python

import psutil
import os
import sys
import getopt
sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Monitor

import fcntl
from utility.lock      import FileLock


def main( warning, critical ):
    '''This program checks actual server swap usage and depends on the ussage,
       this will return Monitor.ERROR["OK"], Monitor.ERROR["WARNING"] or Monitor.ERROR["CRITICAL"].
    '''
    percent_usage = psutil.swap_memory().percent
    total_size = psutil.swap_memory().total/1024/1024/1024
    current_usage  = psutil.swap_memory().used/1024/1024/1024 

    if (percent_usage >= float(critical)):
        print "CRITICAL: System Swap Memory Usage HWM({0}% - {1}GB/{2}GB)".format(percent_usage, current_usage, total_size)
        sys.exit(Monitor.ERROR["CRITICAL"])
    elif (float(warning) <= percent_usage < float(critical)):
        print "WARNING: System Swap Memory Usage HWM({0}% - {1}GB/{2}GB)".format(percent_usage, current_usage, total_size)
        sys.exit(Monitor.ERROR["WARNING"])
    else:
        print "OK: System Swap Memory Usage HWM({0}% - {1}GB/{2}GB)".format(percent_usage, current_usage, total_size)
        sys.exit(Monitor.ERROR["OK"])


if __name__ == "__main__":
    # Check instance lock
    try:
        lock_file = '/tmp/' + os.path.realpath(__file__).split('/')[-1].split('.')[0] + ".lck"
        with FileLock(lock_file, fcntl.LOCK_EX|fcntl.LOCK_NB):

            # Check parameters
            try:
                optlist, args = getopt.getopt(sys.argv[1:], 'w:c:')
                optlist = dict([option for option in optlist])
  
                if args or len(optlist) != 2:
                    raise getopt.GetoptError("Invalid parameter(s).")
  
            except getopt.GetoptError:
                print("\nUsage: check_os_swap_usage.py -w percentUsage -c percentUsage\n")
                sys.exit(Monitor.ERROR["UNKNOWN"])
  
            warning, critical = optlist.get('-w'), optlist.get('-c')
  
            main( warning , critical )

    except IOError:
        print "Another instance of the same monitoring script is currently running..."
        sys.exit(Monitor.ERROR["WARNING"])



