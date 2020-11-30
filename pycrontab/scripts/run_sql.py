#!/usr/bin/env python
#
# Author: jyoon
#
# 2017/01/13 - Collectd plugin for Oracle Dashboard - OS STAT
#
import os
import sys
import socket
import signal
import subprocess
sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Util
from database.database import Config
from database.database import Database


def main():
    configuration = Config()
    db_list = configuration.list_databases()
    hostname = socket.gethostname()

    for dbname in db_list:
        if configuration.get_attr_value(dbname, 'db_type') == 'container' or \
           configuration.get_attr_value(dbname, 'is_standby') == 'yes':
            continue 

        # Set Oracle Related Environ variables
        ora_home = configuration.get_attr_value(dbname,'oracle_home')
        try:
            os.environ['ORACLE_HOME'] = ora_home
            os.environ['LD_LIBRARY_PATH'] = ora_home + '/lib'
        except ValueError as e:
            print (e.args[0])

        # Gather all sql files.
        sql_dir = os.path.dirname(os.path.realpath(__file__)) + "/sql_2_run"
        sql_files = [ f for f in os.listdir(sql_dir) if os.path.isfile(os.path.join(sql_dir, f)) and f.endswith(".sql")]
        sql_files.sort()

        # Get Auth 
        auth = configuration.parser.get(dbname, 'sys_user').split('/')
        auth = auth[0] + '/' + Config.get_pass(auth[1]).strip()
        
        # Run each sql files
        for sql_file in sql_files:
            sqlplus = os.environ['ORACLE_HOME'] + "/bin/sqlplus"
            #print [sqlplus, "-s", auth + '@' + hostname + '/' + dbname , '@' + sql_dir + '/' + sql_file]
            s = subprocess.Popen([sqlplus, "-s", auth + '@' + hostname + '/' + dbname , '@' + sql_dir + '/' + sql_file], stdout=subprocess.PIPE)
            
            for line in s.stdout:
                print line


if __name__ == "__main__":
    main()
