#!/usr/bin/env python
# 
# Author: jyoon
#
# 2016/06/25 - Check databases which are not configured in database.ini file
#
import os
import re
import sys
import subprocess
sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Util
from utility.util    import Monitor
from database.database import Config

import fcntl
from utility.lock      import FileLock


def main():
    configuration = Config()

    db_list = configuration.list_databases()
    none_configured_db_list = []

    s = subprocess.Popen(["ps", "axw"], stdout=subprocess.PIPE)
    for x in s.stdout:
        match = re.search(r'\S+\s+ora_pmon_(?P<sid>\S+)\s+', x)
        if match:
            sid= match.group('sid')

            if sid == '-MGMTDB':
                continue

            sid_list = [ configuration.get_attr_value(db, 'oracle_sid') for db in db_list ]

            if sid not in sid_list:
                #none_configured_db_list.append(db)
                none_configured_db_list.append(sid)

    if none_configured_db_list:
        print 'CRITIAL: Unknown DB list: ' + ', '.join(none_configured_db_list) + "."
        sys.exit(Monitor.ERROR["CRITICAL"]) 
    else:
        print 'OK: All databases are monitored.'
        sys.exit(Monitor.ERROR["OK"])

if __name__ == "__main__":

    # Check instance lock
    try:
        lock_file = '/tmp/' + os.path.realpath(__file__).split('/')[-1].split('.')[0] + ".lck"
        with FileLock(lock_file, fcntl.LOCK_EX|fcntl.LOCK_NB):

            # Check parameters
            main()

    except IOError:
        print "Another instance of the same monitoring script is currently running..."
        sys.exit(Monitor.ERROR["WARNING"])

