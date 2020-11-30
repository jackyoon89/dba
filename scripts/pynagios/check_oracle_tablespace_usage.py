#!/usr/bin/env python

import os
import re
import sys
import getopt
sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Monitor
from database.database import Config
from database.database import Database

import fcntl
from utility.lock      import FileLock


critical_threshold=90
warning_threshold=80

def main(dbname):
    configuration = Config()

    try:
        configuration.set_ora_env(dbname)
    except ValueError as e:
        print (e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])


    # skip the check if the database is standby 
    if configuration.get_attr_value(dbname, 'is_standby') == 'yes':
        print "{0} is a standby Database - Status Check is deferred.".format(dbname)
        sys.exit(Monitor.ERROR["OK"])


    auth = configuration.parser.get(dbname, 'sys_user').split('/')
    sql = """select ddf.tablespace_name, 
                     case 
                         when ddf.bytes > ddf.maxbytes then round((ddf.bytes - dfs.bytes)/ddf.bytes*100,2) 
                         else round((ddf.bytes - dfs.bytes)/ddf.maxbytes*100,2) 
                     end
               from (select tablespace_name, sum(bytes) bytes, sum(decode(maxbytes,0,bytes,maxbytes)) maxbytes
                       from dba_data_files 
                      group by tablespace_name) ddf,
                    (select tablespace_name, sum(bytes) bytes 
                       from dba_free_space 
                      group by tablespace_name) dfs 
              where ddf.tablespace_name = dfs.tablespace_name"""
 
    try:
        connection = Database.get_connection(auth[0], Config.get_pass(auth[1]).strip(), dbname)
        cursor = Database.get_cursor(connection)
        cursor.execute(sql)

        err_cnt =0
        critical_msg = ''
        warning_msg = ''

        result = cursor.fetchall()

    except BaseException as e:
        print(e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])
 
   
    
    for r in result:
        if r[1] > critical_threshold:
            critical_msg += "{0}({1}%),".format(r[0], r[1])
            err_cnt = err_cnt + 1
        elif r[1] < critical_threshold and r[1] > warning_threshold:
            warning_msg += "{0}({1}%),".format(r[0], r[1])
            err_cnt = err_cnt +1

    critical_msg = critical_msg.rstrip(',')
    warning_msg = warning_msg.rstrip(',')

    if err_cnt == 0:  
        print "OK: All tablespaces have enough free space."
        sys.exit(Monitor.ERROR["OK"])
    else:
        if critical_msg == '':
            print "WARNING:{0}".format(warning_msg)
            sys.exit(Monitor.ERROR["WARNING"])
        else:
            if warning_msg == '':
                print "CRITICAL:{0}".format(critical_msg)
            else:
                print "CRITICAL:{0}/WARNING:{1}".format(critical_msg, warning_msg) 
            sys.exit(Monitor.ERROR["CRITICAL"])


if __name__ == "__main__":

    # Check parameters
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'd:w:c:')
        optlist = dict([option for option in optlist])
        if args or len(optlist) == 0:
            raise getopt.GetoptError("Invalid parameter(s)")

    except getopt.GetoptError:
        print("\nUsage: check_oracle_tablespace_usage.py -d <DB_NAME> -w <warning_threshold> -c <critical_threshold>\n")
        sys.exit(Monitor.ERROR["UNKNOWN"])

    dbname = optlist.get('-d')
    warning_threshold = int(optlist.get('-w')) 
    critical_threshold = int(optlist.get('-c'))

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


