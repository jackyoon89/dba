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


def main(dbname):
    num_archivegap = 0

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
    #sql  = """select count(*) from v$archive_gap"""
    sql  = """select count(*) from (
           select USERENV('Instance'), high.thread#, low.lsq, high.hsq
            from
             (select a.thread#, rcvsq, min(a.sequence#)-1 hsq
              from v$archived_log a,
                   (select lh.thread#, lh.resetlogs_change#, max(lh.sequence#) rcvsq
                      from v$log_history lh, v$database_incarnation di
                     where lh.resetlogs_time = di.resetlogs_time
                       and lh.resetlogs_change# = di.resetlogs_change#
                       and di.status = 'CURRENT'
                       and lh.thread# is not null
                       and lh.resetlogs_change# is not null
                       and lh.resetlogs_time is not null
                    group by lh.thread#, lh.resetlogs_change#
                   ) b
              where a.thread# = b.thread#
                and a.resetlogs_change# = b.resetlogs_change#
                and a.sequence# > rcvsq
              group by a.thread#, rcvsq) high,
            (select srl_lsq.thread#, nvl(lh_lsq.lsq, srl_lsq.lsq) lsq
              from
                (select thread#, min(sequence#)+1 lsq
                 from
                   v$log_history lh, x$kccfe fe, v$database_incarnation di
                 where to_number(fe.fecps) <= lh.next_change# and to_number(fe.fecps) >= lh.first_change#
                   and fe.fedup!=0 and bitand(fe.festa, 12) = 12
                   and di.resetlogs_time = lh.resetlogs_time
                   and lh.resetlogs_change# = di.resetlogs_change#
                   and di.status = 'CURRENT'
                 group by thread#) lh_lsq,
                (select thread#, max(sequence#)+1 lsq
                 from
                   v$log_history
                 where (select min( to_number(fe.fecps))
                        from x$kccfe fe
                        where fe.fedup!=0 and bitand(fe.festa, 12) = 12)
                 >= next_change#
                 group by thread#) srl_lsq
              where srl_lsq.thread# = lh_lsq.thread#(+)
             ) low
            where low.thread# = high.thread#
            and lsq < = hsq and hsq > rcvsq)"""

    try:
        connection = Database.get_connection(auth[0], Config.get_pass(auth[1]).strip(), dbname)
        cursor = Database.get_cursor(connection)
        cursor.execute(sql)
        rec = cursor.fetchall()
        for r in rec:
            num_archivegap = r[0]
 
    except BaseException as e:
        print(e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])


    if num_archivegap == 0:
        print "OK: No archivelog gap found."
        sys.exit(Monitor.ERROR["OK"]) 
    else:
        print "CRITICAL: Arhive gap found ({0}/{1})".format(dbname, r[0])
        sys.exit(Monitor.ERROR["CRITICAL"])
        

if __name__ == "__main__":

    # Check parameters
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'd:')
        optlist = dict([option for option in optlist])

        if args or len(optlist) == 0:
            raise getopt.GetoptError("Invalid parameter(s)")

    except getopt.GetoptError:
        print("\nUsage: check_oracle_archivelog_gap.py -d <DB_NAME> \n")
        sys.exit(Monitor.ERROR["UNKNOWN"])

    dbname = optlist.get('-d')

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


