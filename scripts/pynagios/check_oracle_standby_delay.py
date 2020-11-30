#!/usr/bin/env python

import os
import sys
import re
import getopt
sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Monitor 
from database.database import Config
from database.database import Database

import fcntl
from utility.lock      import FileLock



critical_threshold = 90
warning_threshold = 70
dest_id = 1

def main(dbname):
    configuration = Config()

    try:
        configuration.set_ora_env(dbname)
    except ValueError as e:
        print (e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])

    if configuration.get_attr_value(dbname, 'is_standby') == 'yes':
        print "{0} is a Standby Database - Status Check deferred.".format(dbname)
        sys.exit(Monitor.ERROR["OK"])


    #sql="""select round((max(primary_time) - max(standby_time)) * 24 * 60 , 2)
    #         from ( select max(next_time) primary_time, to_date(NULL) standby_time
    #                  from v$archived_log
    #                 where archived  = 'YES'
    #                   and dest_id = 1
    #        union all
    #       select to_date(null), max(next_time)
    #         from v$archived_log
    #        where archived = 'YES'   
    #          and applied = 'YES'
    #          and dest_id = &1)"""

    sql = """select dest_id, thread#, sum(received)-sum(applied) diff
               from (
                      select dest_id, thread#, max(sequence#) Received, 0 Applied
                        from gv$archived_log
                       where archived = 'YES'
                       group by thread#, dest_id
                       union
                      select dest_id, thread#, 0 Received,  max(sequence#) Applied
                        from gv$archived_log
                       where applied = 'YES'
                       group by thread#, dest_id
                    )
              where dest_id <> 1
              group by dest_id, thread#
              order by 3 desc,1,2"""



    auth = configuration.parser.get(dbname, 'sys_user').split('/')

    try:
        connection = Database.get_connection(auth[0], Config.get_pass(auth[1]).strip(), dbname)
        cursor = Database.get_cursor(connection)
        cursor.execute(sql)
        rec = cursor.fetchall()

    except BaseException as e:
        print(e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])


    Status = 0
    message = ""
    for r in rec:
        if r[2] > critical_threshold:
            message = message + "Dest_id:{0}, Thread:{1} is lagged {2} log file(s).\n".format(r[0],r[1],r[2])
            Status = Monitor.ERROR["CRITICAL"]
    
        elif warning_threshold <= r[2] < critical_threshold:
            message = message + "Dest_id:{0}, Thread:{1} is lagged {2} log file(s).\n".format(r[0],r[1],r[2])
            if Status < Monitor.ERROR["WARNING"]:
                Status = Monitor.ERROR["WARNING"] 
     
        else:
            message = message + "Dest_id:{0}, Thread:{1} is lagged {2} log file(s).\n".format(r[0],r[1],r[2])

    print message.rstrip('\n')
    sys.exit(Status)

        

if __name__ == "__main__":

    # Check parameters 
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'd:w:c:')
        optlist = dict([option for option in optlist])

        if args or len(optlist) == 0:
            raise getopt.GetoptError("Invalid parameter(s)")

    except getopt.GetoptError:
        print("\nUsage: check_oracle_standby_delay.py -d DB_NAME -w warning_threshold -c critical_threshold \n")
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


