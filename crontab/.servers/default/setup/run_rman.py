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
        #if configuration.get_attr_value(dbname, 'db_type') == 'pdb' or \
        #   configuration.get_attr_value(dbname, 'is_standby') == 'yes':
        if configuration.get_attr_value(dbname, 'db_type') == 'pdb': 
            continue 

        print "\n\n######### DB Name : " + dbname + " #########" 

        # Set Oracle Related Environ variables
        ora_home = configuration.get_attr_value(dbname,'oracle_home')
        try:
            os.environ['ORACLE_HOME'] = ora_home
            os.environ['LD_LIBRARY_PATH'] = ora_home + '/lib'
        except ValueError as e:
            print (e.args[0])

        # Gather all rman files.
        rman_dir = os.path.dirname(os.path.realpath(__file__)) + "/rman"
        rman_files = [ f for f in os.listdir(rman_dir) if os.path.isfile(os.path.join(rman_dir, f)) and f.endswith(".rman")]
        rman_files.sort()

        # Get Auth 
        auth = configuration.parser.get(dbname, 'sys_user').split('/')
        auth = auth[0] + '/' + Config.get_pass(auth[1]).strip()
        
        unique_name = configuration.get_attr_value(dbname, 'db_unique_name')
        
        # Skip if the database type is pdb
        if configuration.get_attr_value(dbname, 'db_type') == 'pdb':
            continue

        # Run each rman files
        for rman_file in rman_files:

            # Grep the first line and interpret as regular expression
            header = re.sub(".+\:\S*(.+).*", r"\1", Util.get_file_contents(rman_dir + '/' + rman_file)[0]).strip()
            #print header

            if not re.match(header, dbname):
                # Go to next database if not matches
                continue

            print '---------------------------------'
            print rman_file
            print '---------------------------------'

            rman = os.environ['ORACLE_HOME'] + "/bin/rman"
            s = subprocess.Popen([rman, "target", auth + '@' + hostname + '/' + dbname, 'cmdfile',  rman_dir + '/' + rman_file, 'using ' + unique_name], stdout=subprocess.PIPE)
            
            for line in s.stdout:
                print line


if __name__ == "__main__":
    main()
