#!/usr/bin/env python

import sys
import os
import re
import subprocess
import cx_Oracle
import getopt

sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Monitor 
from database.database import Config

import fcntl
from utility.lock      import FileLock


critical_threshold=90
warning_threshold=80

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
    err_cnt = 0
    critical_msg = ''
    warning_msg = ''

    # connect asm
    try:
        sql = """select name, case when total_mb <> 0 then round((total_mb - free_mb)/total_mb*100,2) end
                   from v$asm_diskgroup
                  where voting_files = 'N'"""

        connection = cx_Oracle.connect('/', mode=cx_Oracle.SYSDBA)
        cursor = connection.cursor()
        cursor.execute(sql)
        rec = cursor.fetchall()
        
        for r in rec:
            if r[1] > critical_threshold:
                critical_msg += "{0}({1}%),".format(r[0], r[1]) 
                err_cnt += 1
            elif r[1] < critical_threshold and r[1] >= warning_threshold:
                warning_msg += "{0}({1}%),".format(r[0], r[1])  
                err_cnt += 1

        connection.close() 
        
    except BaseException as e:
        print(e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])

    if err_cnt == 0:
        print "OK: ASM has enough space."
        sys.exit(Monitor.ERROR["OK"])
    else:
        if critical_msg == '':
            print "WARNING:{0}".format(warning_msg[:-1])
            sys.exit(Monitor.ERROR["WARNING"])
        else:
            if warning_msg == '':
                print "CRITICAL:{0}".format(critical_msg[:-1])
            else:
                print "CRITICAL:{0}/WARNING:{1}".format(critical_msg[:-1], warning_msg[:-1])
            sys.exit(Monitor.ERROR["CRITICAL"]) 
 

if __name__ == "__main__":

    # Check instance lock
    try:
        lock_file = '/tmp/' + os.path.realpath(__file__).split('/')[-1].split('.')[0] + ".lck"
        with FileLock(lock_file, fcntl.LOCK_EX|fcntl.LOCK_NB):

            # Check parameters
            try:
                optlist, args = getopt.getopt(sys.argv[1:], 'w:c:')
                optlist = dict([option for option in optlist])
                if args or len(optlist) == 0:
                    raise getopt.GetoptError("Invalid parameter(s)")
  
            except getopt.GetoptError:
                print("\nUsage: check_asm_space.py -w <warning_threshold> -c <critical_threshold>\n")
                sys.exit(Monitor.ERROR["UNKNOWN"])
  
  
            warning_threshold = int(optlist.get('-w'))
            critical_threshold = int(optlist.get('-c'))
  
            main()

    except IOError:
        print "Another instance of the same monitoring script is currently running..."
        sys.exit(Monitor.ERROR["WARNING"])

