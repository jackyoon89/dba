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
    
    host = socket.getfqdn().split('.')[0]

    # checking asm
    s = subprocess.Popen([home + "/bin/srvctl", "status", "asm",  "-n", host], stdout=subprocess.PIPE)
    
    for out in s.stdout:
        p = re.compile("ASM is\s(.*)\son\s" + host)
        result = p.search(out)
 
        if result <> None:
            if result.group(1) == 'running':
                print "OK: ASM is " + result.group(1) + " on " + host + "." 
                sys.exit(Monitor.ERROR["OK"])
            else:
                print "ERROR: " + out
                sys.exit(Monitor.ERROR["CRITICAL"])
 
    

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

