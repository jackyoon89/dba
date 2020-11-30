#!/usr/bin/env python
# 
# 2016/07/08 - Jack Yoon	- 1. Added relative path for the library
#                                 2. Clean up some logic
# 2016/06/15 - Wei Tang		- initial development
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


old_error_count_file=''
# error_message =''

def get_current_num_errors(err_cnt_file):
    try:
        with open( err_cnt_file , 'r') as f:
            err_cnt = int( f.read())
    except IOError:
        return 0

    return err_cnt


def main(dbname):
    configuration = Config()
    configuration.set_ora_env(dbname)
    
    oracle_sid   = configuration.get_attr_value(dbname, 'oracle_sid')
    auth         = configuration.parser.get(dbname, 'sys_user').split('/')
    #db_uniq_name = Database.get_parameter(auth[0], Config.get_pass(auth[1]).strip(), dbname, 'db_unique_name')
    db_uniq_name = configuration.get_attr_value(dbname, 'db_unique_name')

    err_cnt_file ='/tmp/ERR_CNT_{0}'.format(oracle_sid)
    log_file ='/home/app/oracle/diag/rdbms/{0}/{1}/trace/alert_{1}.log'.format(db_uniq_name.lower() , oracle_sid)
    
    with open( log_file, 'r') as trcfile:
        file_contents = trcfile.read()
        new_err_cnt = file_contents.count("ORA-")
        old_err_cnt = get_current_num_errors(err_cnt_file)
        err_num = new_err_cnt - old_err_cnt
        
        with open(err_cnt_file, 'w') as f:
            f.write(str(new_err_cnt))
        
        if ( err_num > 0 ):
            #errors = re.findall(r'^.*ORA-.*', file_contents, re.MULTILINE) 
            errors = re.findall(r'^.*ORA-.*', file_contents, re.MULTILINE) \
                      and not re.findall(r'^.*ORA-28\D.*', file_contents, re.MULTILINE) \
                      and not re.findall(r'^.*ORA-609\D.*', file_contents, re.MULTILINE) \
                      and not re.findall(r'^.*ORA-3136\D.*', file_contents, re.MULTILINE)
            error_mesg = errors[len(errors)-1]
            
            print "{0}".format(error_mesg)
            sys.exit(Monitor.ERROR["CRITICAL"])
        else:
            print "OK: No Errors found"
            sys.exit(Monitor.ERROR["OK"])


if __name__ == "__main__":

    # Check parameters
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'd:')
        optlist = dict([option for option in optlist])

        if args or len(optlist) == 0:
            raise getopt.GetoptError("Invalid parameter(s)")

    except getopt.GetoptError:
        print("\nUsage: check_oracle_alertlog.py -d DB_NAME \n")
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
    #main(dbname.upper())


