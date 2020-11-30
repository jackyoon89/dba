#!/usr/bin/env python

import os
import re
import sys
import getopt
sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Monitor 
from database.database import Config
from database.database import Database


def main(dbname):
    configuration = Config()

    try:
        configuration.set_ora_env(dbname)
    except ValueError as e:
        print (e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])

    # skip the check if its pluggable database.
    if configuration.get_attr_value(dbname, 'db_type') == 'pdb':
        print "{0} is a pluggable Database - Status Check is deprecated.".format(dbname)
        sys.exit(Monitor.ERROR["OK"])

    auth = configuration.parser.get(dbname, 'sys_user').split('/')
    sql  = """SELECT DEST_NAME, decode(STATUS, 'DEFERRED','DEFERRED',ERROR) FROM V$ARCHIVE_DEST
               WHERE STATUS NOT IN ( 'VALID', 'INACTIVE' )""" 

    try:
        connection = Database.get_connection(auth[0], Config.get_pass(auth[1]).strip(), dbname)
        cursor = Database.get_cursor(connection)
        cursor.execute(sql)
        rec = cursor.fetchall()

    except BaseException as e:
        print(e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])

    if len(rec)==0:
        print "OK: All archivelog destinations are fine."
        sys.exit(Monitor.ERROR["OK"])
    else:
        print 'CRITICAL: ' + '/'.join(([ i for i in rec])[0])
        #print 'CRITICAL: ' + '/'.join(rec[0])
        sys.exit(Monitor.ERROR["CRITICAL"])


        

if __name__ == "__main__":
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'd:')
        optlist = dict([option for option in optlist])

        if args or len(optlist) == 0:
            raise getopt.GetoptError("Invalid parameter(s)")

    except getopt.GetoptError:
        print("\nUsage: check_oracle_archive_dest_status.py -d <DB_NAME> \n")
        sys.exit(Monitor.ERROR["UNKNOWN"])

    dbname = optlist.get('-d')

    if ( Monitor.is_monitor(dbname) == True ):
            main(dbname.upper())
    else:
        print("Database Monitoring suspended for maintenance. - OK")
        sys.exit(Monitor.ERROR["OK"])
    #main(dbname.upper())

