#!/usr/bin/env python

import os
import sys
import re
import getopt
sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Monitor 
from database.database import Config
from database.database import Database


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

    sql="""select round((sysdate-max(NEXT_TIME))*24*60,2)
             from v$archived_log
            where archived = 'YES'
              and applied = 'YES'
              and dest_id = &1"""


    auth = configuration.parser.get(dbname, 'sys_user').split('/')
    sql  = sql.replace('&1', dest_id)

    try:
        connection = Database.get_connection(auth[0], Config.get_pass(auth[1]).strip(), dbname)
        cursor = Database.get_cursor(connection)
        cursor.execute(sql)
        rec = cursor.fetchall()

        if rec[0][0] == None:
            raise ValueError("Invalid log_archive_dest: log_archive_dest_{0}".format(dest_id))

    except BaseException as e:
        print(e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])

    for r in rec:
        if r[0] > critical_threshold:
            print "CRITICAL: Standby DEST_ID_{0} has {1} min delay.".format(dest_id, r[0])
            sys.exit(Monitor.ERROR["CRITICAL"])

        elif warning_threshold <= r[0] < critical_threshold:
            print "WARNING: Standby DEST_ID_{0} has {1} min delay.".format(dest_id, r[0])
            sys.exit(Monitor.ERROR["WARNING"])

        else:
            print "OK: Standby DEST_ID_{0} has {1} min delay.".format(dest_id, r[0])
            sys.exit(Monitor.ERROR["OK"])


        

if __name__ == "__main__":
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'd:i:w:c:')
        optlist = dict([option for option in optlist])

        if args or len(optlist) == 0:
            raise getopt.GetoptError("Invalid parameter(s)")

    except getopt.GetoptError:
        print("\nUsage: check_oracle_standby_lagtime.py -d DB_NAME -i DEST_ID -w warning_threshold -c critical_threshold \n")
        sys.exit(Monitor.ERROR["UNKNOWN"])

    dbname = optlist.get('-d')
    dest_id = optlist.get('-i')
    warning_threshold = int(optlist.get('-w'))
    critical_threshold = int(optlist.get('-c')) 

    if ( Monitor.is_monitor(dbname) == True ):
            main(dbname.upper())
    else:
        print("Database Monitoring suspended for maintenance. - OK")
        sys.exit(Monitor.ERROR["OK"])

