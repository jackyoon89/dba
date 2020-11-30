#!/usr/bin/env python
#
# Author: jyoon
#
# 2017/01/12 - Collectd plugin for Oracle ASH
#
import os
import sys
import socket
import signal

from ash         import Ash
from ash_etc     import AshEtc
from db_load     import DB_Load
from osstat      import Os_Stat
from temp_space  import Temp_space
from tablespace  import Tablespace
from archive_lag import ArchiveLag
from shared_pool import Shared_pool

from recoveryarea_usage import RecoveryArea

sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Util
from database.database import Config
from database.database import Database


def read_callback(data=None):

    configuration = Config()

    db_list = configuration.list_databases()


    for dbname in db_list:
        if configuration.get_attr_value(dbname, 'db_type') == 'container':
            continue

        #collectd.info('---------------- oracle_stats ---------------------')

        try:
            configuration.set_ora_env(dbname)
        except ValueError as e:
            try:
                collectd.info( 'Exception on ' + dbname + ' - oracle_stats.py : ' + str(e.args[0]))
            except BaseException:
                print('Exception on ' + dbname + ' - ash.py : ' + str(e.args[0]))
            return


        try:
            auth = configuration.parser.get(dbname, 'sys_user').split('/')
            connection = Database.get_connection(auth[0], Config.get_pass(auth[1]).strip(), dbname)
           
            if connection == None:
                collectd.info("Error: connection failed on " + dbname )
 
            # Ash Stats
            ash = Ash(dbname)
            ash.retrieve_ash_info(connection)
            ash.dispatch_ash_info()
                      
            # Ash etc.
            ash_etc = AshEtc(dbname)
            ash_etc.retrieve_ash_etc_info(connection)
            ash_etc.dispatch_ash_etc_info()

            # DB_Load 
            db_load = DB_Load(dbname)
            db_load.retrieve_db_load_info(connection)
            db_load.dispatch_db_load_info()

            # OS Stats
            os_stat = Os_Stat(dbname)
            os_stat.retrieve_os_stats(connection)
            os_stat.dispatch_os_stats()
                        
            # Temp_Space
            temp_space = Temp_space(dbname)
            temp_space.retrieve_temp_space_info(connection)
            temp_space.dispatch_temp_space_info()

            # Tablespace
            tablespace = Tablespace(dbname)
            tablespace.retrieve_tablespace_info(connection)
            tablespace.dispatch_tablespace_info()


            # Recovery_area_usage
            recoveryarea = RecoveryArea(dbname)
            recoveryarea.retrieve_recoveryarea_info(connection)
            recoveryarea.dispatch_recoveryarea_info()

 
            # Archive_apply_lag_time
            archive_lag = ArchiveLag(dbname)
            archive_lag.retrieve_archivelag_info(connection)
            archive_lag.dispatch_archivelag_info()


            # Shared Pool Usage
            shared_pool_usage = Shared_pool(dbname)
            shared_pool_usage.retrieve_shared_pool_usage_info(connection)
            shared_pool_usage.dispatch_shared_pool_usage_info()

 
            Database.disconnect(connection)

        except BaseException as e:
            try:
                collectd.info( 'Exception on ' + dbname + ' - oracle_stats.py : ' + str(e.args[0]))
            except BaseException:
                print('Exception on ' + dbname + ' - oracle_stats.py : ' + str(e.args[0]))
            return



if __name__ == '__main__':
    read_callback()
else:
    '''this runs when we're being run via collectd'''
    import collectd

    collectd.register_read(read_callback, 60)



