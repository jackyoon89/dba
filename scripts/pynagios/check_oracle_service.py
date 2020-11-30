#!/usr/bin/env python

import sys
import os
import re
import getopt
sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Monitor 
from database.database import Config
import commands

import fcntl
from utility.lock      import FileLock


def main(dbname, option, service_name):
    configuration = Config()
    configuration.set_ora_env(dbname)
    

    cmd = '{0}/bin/lsnrctl status'.format(configuration.get_attr_value(dbname, 'oracle_home'))
    output = commands.getoutput(cmd)
    matched = re.findall(r'.*Service .*'+str(service_name)+'" has .*', output, re.MULTILINE)


    if matched:
       for m in matched:
          if option == '-s': 
              print "OK: Service {0} is up.".format(service_name)
              sys.exit(Monitor.ERROR["OK"])
          else:
              print "ERROR: Service {0} is up.".format(service_name)
              sys.exit(Monitor.ERROR["CRITICAL"])
    else:
          if option == '-s':
              print "ERROR: Service {0} is Down.".format(service_name)
              sys.exit(Monitor.ERROR["CRITICAL"])
          else:
              print "OK: Service {0} is Down.".format(service_name)
              sys.exit(Monitor.ERROR["OK"])


if __name__ == "__main__":

    # Check parameters
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'd:s:e:')
        optlist = dict([option for option in optlist])

        if ('-s' in optlist.keys() and '-e' in optlist.keys()) or ('-s' not in optlist.keys() and '-e' not in optlist.keys()):
            raise getopt.GetoptError("") 

    except getopt.GetoptError:
        print("\nUsage: check_oracle_service.py -d DB_NAME [-s service_name|-e service_name]\n")
        sys.exit(Monitor.ERROR["UNKNOWN"])

    dbname = optlist.get('-d')

    #for opt in optlist.keys():
    #    if opt == '-s':
    #        option = 's'
    #        service_name = optlist.get('-s')
    #    elif opt == '-e':
    #        option = 'e'
    #        service_name = optlist.get('-e')

    option = [key for key in optlist.keys() if key not in ['-d']]
    service_name = optlist.get(option[0])

    if ( Monitor.is_monitor(dbname) == True ):
        # Check instance lock
        try:
            lock_file = '/tmp/' + os.path.realpath(__file__).split('/')[-1].split('.')[0] + '_' + dbname + '.lck'
            with FileLock(lock_file, fcntl.LOCK_EX|fcntl.LOCK_NB):
                main(dbname.upper(), option[0], service_name)
        except IOError:
            print "Another instance of the same monitoring script is currently running..."
            sys.exit(Monitor.ERROR["WARNING"])
    else:
        print("Database Monitoring suspended for maintenance. - OK")
        sys.exit(Monitor.ERROR["OK"])


