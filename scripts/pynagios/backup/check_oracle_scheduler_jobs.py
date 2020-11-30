#!/usr/bin/env python
# 
# Author: jyoon
# 
# 2016/06/27 - Check failed scheduler jobs
#
import sys
import os
import re
import getopt
sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Util
from utility.util    import Monitor 
from database.database import Config
from database.database import Database

import fcntl
from utility.lock      import FileLock


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

    auth = configuration.parser.get(dbname, 'sys_user').split('/')
    sql = """select owner||'.'||job_name||'('||nvl(status,'N/A')||' - '||
                    to_char(log_date, 'mm/dd/yyyy,hh24:mi:ss')|| decode(status,NULL, ' - '||additional_info, NULL)||')' mesg
               from ( select log_date, owner, job_name, status, additional_info, 
                             row_number() over (partition by owner, job_name order by log_date desc) rn
                        from dba_scheduler_job_log
                       where log_date >= sysdate - 1
                         and job_name in (select job_name from dba_scheduler_jobs where enabled = 'TRUE')
                    )
              where rn = 1
              order by log_date desc"""

    try:
        connection = Database.get_connection(auth[0], Config.get_pass(auth[1]).strip(), dbname)
        cursor = Database.get_cursor(connection)
        cursor.execute(sql)

        failed_jobs = [str(rec[0]) for rec in cursor if re.search(r'FAILED', str(rec[0]))] 

    except BaseException as e:
        print(e.args[0])
        sys.exit(Monitor.ERROR["CRITICAL"])

    # Check execution status
    if len(failed_jobs) == 0:
        print "OK: All scheduler jobs are fine."
        sys.exit(Monitor.ERROR["OK"])
    else:
        print "CRITICAL: " + ', '.join(failed_jobs)
        sys.exit(Monitor.ERROR["CRITICAL"])

        

if __name__ == "__main__":

    # Check parameters
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'd:')
        optlist = dict([option for option in optlist])

        if args or len(optlist) == 0:
            raise getopt.GetoptError("Invalid parameter(s)")

    except getopt.GetoptError:
        print("\nUsage: check_oracle_scheduler_jobs.py -d <DB_NAME>\n")
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


