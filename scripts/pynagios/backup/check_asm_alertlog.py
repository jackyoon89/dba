#!/usr/bin/env python

import sys
import os
import re
import subprocess
import socket

sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Monitor 
from database.database import Config

import fcntl
from utility.lock      import FileLock


def get_asm_env():
    s = subprocess.Popen(["ps","axw"], stdout=subprocess.PIPE)

    for out in s.stdout:
        p = re.compile("(\d+).*asm_pmon_(.*)")
        result = p.search(out)

        if result <> None:
            # Process number
            proc_id = result.group(1)
  
            # Oracle_SID
            sid = result.group(2) 

            # Find ORACLE_HOME from /proc/process#/exe's link 
            p = re.compile("(.*)/bin/oracle")
            result = p.search(os.path.realpath("/proc/" + proc_id + "/exe"))
            home = result.group(1)

    return (sid, home)


def get_current_num_errors(err_cnt_file):
    try:
        with open( err_cnt_file , 'r') as f:
            err_cnt = int( f.read())
    except IOError:
        return 0

    return err_cnt


def main():
    mesg = ''
    (sid, home) = get_asm_env()

    # Setup environment variable
    configuration = Config()
    try:
        configuration.set_env('ORACLE_SID', sid)
        configuration.set_env('ORACLE_HOME', home)
        configuration.set_env('LD_LIBRARY_PATH', home + "/lib")
    except ValueError as e:
        print (e.args[0])
    

    err_cnt_file ='/tmp/ERR_CNT_{0}'.format(sid) 
    log_file ='/home/app/grid/grid_base/diag/asm/+asm/{0}/trace/alert_{0}.log'.format(sid)

    
    with open( log_file, 'r') as trcfile:
        file_contents = trcfile.read()
        new_err_cnt = file_contents.count("ORA-")
        old_err_cnt = get_current_num_errors(err_cnt_file)
        err_num = new_err_cnt - old_err_cnt

        with open(err_cnt_file, 'w') as f:
            f.write(str(new_err_cnt))

        if ( err_num > 0 ):
            errors = re.findall(r'^.*ORA-.*', file_contents, re.MULTILINE)
            error_mesg = errors[len(errors)-1]

            print "{0}".format(error_mesg)
            sys.exit(Monitor.ERROR["CRITICAL"])
        else:
            print "OK: No Errors found"
            sys.exit(Monitor.ERROR["OK"])



if __name__ == "__main__":

   # Check instance lock
    try:
        lock_file = '/tmp/' + os.path.realpath(__file__).split('/')[-1].split('.')[0] + ".lck"
        with FileLock(lock_file, fcntl.LOCK_EX|fcntl.LOCK_NB):

            # Check parameters
            main()

    except IOError:
        print "Another instance of the same monitoring script is currently running..."
        sys.exit(Monitor.ERROR["WARNING"])

