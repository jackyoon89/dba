import os
import sys
import socket
import signal

from stats import Stats

sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Util
from database.database import Config
from database.database import Database


class ArchiveLag (Stats):
    def __init__(self, database, stat_name=None):
        self.archive_lag = {}
        super(ArchiveLag, self).__init__(database, stat_name)

    def retrieve_archivelag_info(self, connection):
        sql = """select 'dest_'||dest_id, round((sysdate-max(completion_time))*24*60,2)
                   from v$archived_log
                  where applied = 'YES'
                    and dest_id <> 1
                  group by dest_id"""
        try:
            cursor = Database.get_cursor(connection)
            cursor.execute(sql)
            result_set = cursor.fetchall()
            cursor.close()
        except BaseException as e:
            try:
                collectd.info( 'Exception on ' + self.database + ' - tablespace.py : ' + str(e.args[0]))
            except BaseException:
                print( 'Exception on ' + self.database + ' - tablespace.py : ' + str(e.args[0]))
            return

        for r in result_set:
            self.archive_lag[r[0]] = r[1]


    def dispatch_archivelag_info(self):
        try:
            import collectd
            
            metric = collectd.Values()
            metric.host = socket.getfqdn()
            metric.interval = 60
            metric.type = 'gauge'
            
            for key, value in self.archive_lag.items():
                 metric.plugin = self.database + '_' + self.oracle_sid + '_archivelag_time'
                 metric.type_instance = key
                 metric.values = [value]
                 metric.dispatch()

        except BaseException:
            print self


    def __str__(self):
        output = "<{0} : Archive_Lag_time(min)>\n".format(self.database.upper())
        for key, value in self.archive_lag.items():
            output += "{0} : {1}\n".format(key, value)

        return output
    
