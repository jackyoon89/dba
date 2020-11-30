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


max_file_size=32

def main(dbname):
    list_files = ()
    configuration = Config()

    try:
        configuration.set_ora_env(dbname)
    except ValueError as e:
        print (e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])


    # skip the check if its standby database and pluggable database.
    db_type    = configuration.get_attr_value(dbname, 'db_type')
    is_standby = configuration.get_attr_value(dbname, 'is_standby')


    if is_standby == 'yes':
        print "{0} is a standby Database - Status Check is deferred.".format(dbname)
        sys.exit(Monitor.ERROR["OK"])


    sql = """select * from (
                 select tablespace_name, file_id
                   from dba_data_files
                  where (( round(maxbytes/1024/1024/1024) < &&1 and maxbytes <> 0 )
                     or ( round(bytes/1024/1024/1024) < &&1 and autoextensible = 'NO' )
                     or ( round(bytes/1024/1024/1024) > &&1 and autoextensible = 'YES')
                     or ( round(maxbytes/1024/1024/1024) > &&1 and autoextensible = 'YES'))
                    and tablespace_name in (select tablespace_name 
                                              from dba_tablespaces
                                             where bigfile = 'NO')
                   union all
                 select tablespace_name, file_id
                   from dba_temp_files
                  where (( round(maxbytes/1024/1024/1024) < &&1 and maxbytes <> 0 )
                     or ( round(bytes/1024/1024/1024) < &&1 and autoextensible = 'NO' )
                     or ( round(bytes/1024/1024/1024) > &&1 and autoextensible = 'YES')
                     or ( round(maxbytes/1024/1024/1024) > &&1 and autoextensible = 'YES'))
                    and tablespace_name in (select tablespace_name
                                              from dba_tablespaces
                                             where bigfile = 'NO'))"""
              



    auth = configuration.parser.get(dbname, 'sys_user').split('/') 
    sql  = sql.replace('&&1', max_file_size)

    try:
        connection = Database.get_connection(auth[0], Config.get_pass(auth[1]).strip(), dbname)
        cursor = Database.get_cursor(connection)
        cursor.execute(sql)
        rec = cursor.fetchall()
        list_files = rec
        
    except BaseException as e:
        print(e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])


    if len(list_files)==0:
        print "OK: All datafiles are following the dbfile rule."
        sys.exit(Monitor.ERROR["OK"])
    else:
        newdir={}
        for r in list_files:
            if newdir.has_key(r[0]):
                newdir[r[0]] = str(newdir.get(r[0]))+","+str(r[1])
            else:
                newdir[r[0]]= r[1]

        msg = "WARNING: Datafile rule violation: "
        for key, value in newdir.iteritems():
            msg = msg + str(key) + "(file:" + str(value) + "), "
             
        print msg.rstrip(', ')
        sys.exit(Monitor.ERROR["WARNING"])


        

if __name__ == "__main__":

    # Check parameters
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'd:s:')
        #print "args: " args
        #print(sys.argv, len(sys.argv))
        optlist = dict([option for option in optlist])

        if args or len(optlist) == 0:
        #if args or len(optlist) != 2
            raise getopt.GetoptError("Invalid parameter(s)")

    except getopt.GetoptError:
        print("\nUsage: check_oracle_dbfile_rule.py -d <DB_NAME> -s <max_file_size>\n")
        sys.exit(Monitor.ERROR["UNKNOWN"])

    dbname = optlist.get('-d')
    max_file_size = optlist.get('-s') 

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


