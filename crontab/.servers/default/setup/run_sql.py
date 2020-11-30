#!/usr/bin/env python
#
# Author: jyoon
#
# 2017/01/13 - Collectd plugin for Oracle Dashboard - OS STAT
#
import re
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
        print "######### DB Name : " + dbname + " #########"
        #if configuration.get_attr_value(dbname, 'db_type') == 'container' or \
        if   configuration.get_attr_value(dbname, 'is_standby') == 'yes':
            continue 

        # Set Oracle Related Environ variables
        ora_home = configuration.get_attr_value(dbname,'oracle_home')
        try:
            os.environ['ORACLE_HOME'] = ora_home
            os.environ['LD_LIBRARY_PATH'] = ora_home + '/lib'
        except ValueError as e:
            print (e.args[0])

        # Gather all sql files.
        sql_dir = os.path.dirname(os.path.realpath(__file__)) + "/sql"
        sql_files = [ f for f in os.listdir(sql_dir) if os.path.isfile(os.path.join(sql_dir, f)) and f.endswith(".sql")]
        sql_files.sort()

        # Get Auth 
        auth = configuration.parser.get(dbname, 'sys_user').split('/')
        auth = auth[0] + '/' + Config.get_pass(auth[1]).strip()
        
        unique_name = configuration.get_attr_value(dbname, 'db_unique_name')

        # Run each sql files
        for sql_file in sql_files:

            # Grep the first line and interpret as regular expression
            header = re.sub(".+\:\S*(.+).*", r"\1", Util.get_file_contents(sql_dir + '/' + sql_file)[0]).strip()
            if not re.match(header, dbname):
                # Go to next database if not matches
                continue

            print '---------------------------------'
            print sql_file
            print '---------------------------------'

            sqlplus = os.environ['ORACLE_HOME'] + "/bin/sqlplus"
            s = subprocess.Popen([sqlplus, "-s", auth + '@' + hostname + '/' + dbname + ' as sysdba', '@' + sql_dir + '/' + sql_file, sql_dir, unique_name, unique_name + '_' + dbname ], stdout=subprocess.PIPE)
            
            for line in s.stdout:
                print line


if __name__ == "__main__":
    main()
