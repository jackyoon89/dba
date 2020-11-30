#!/usr/bin/env python

import sys
import os
import re
import subprocess
import socket
import cx_Oracle

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


    exit_code = 0
    # connect asm
    try:
        sql = """select name, offline_disks 
                   from v$asm_diskgroup
                  where offline_disks > 0"""
        connection = cx_Oracle.connect('/', mode=cx_Oracle.SYSDBA)
        cursor = connection.cursor()
        cursor.execute(sql)
        rec = cursor.fetchall()
        
        if len(rec) == 0:
            print "OK: There is no offline disks."
            exit_code = Monitor.ERROR["OK"] 

        else:
            mesg = "ERROR: "
            for r in rec:
                mesg += r[0] + "(" + str(r[1]) + "),"

            print mesg[:-1].strip() + " offline disk(s) detected."
            exit_code = Monitor.ERROR["CRITICAL"] 
 
        connection.close() 
        
    except BaseException as e:
        print(e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])

    sys.exit(exit_code)
 

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

