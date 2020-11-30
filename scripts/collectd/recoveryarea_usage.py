import os
import sys
import socket
import signal

from stats import Stats

sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Util
from database.database import Config
from database.database import Database


class RecoveryArea(Stats):
    def __init__(self, database, stat_name=None):
        self.RECOVERY_AREA_INFO = {}
        super(RecoveryArea, self).__init__(database, stat_name)

    def retrieve_recoveryarea_info(self, connection):
        sql = """select area.value/1024/1024/1024,
                        lower(replace(file_type,' ','_')), percent_space_used/100*area.value/1024/1024/1024,
                        lower(replace(file_type,' ','_'))||'_reclamable', percent_space_reclaimable/100*area.value/1024/1024/1024
                   from v$flash_recovery_area_usage, (select value from v$parameter where name = 'db_recovery_file_dest_size') area"""

        try:
            cursor = Database.get_cursor(connection)
            cursor.execute(sql)
            result_set = cursor.fetchall()
            cursor.close()
       
        except BaseException as e:
            try:
                collectd.info( 'Exception on ' + self.database + ' - recoveryarea_usage.py : ' + str(e.args[0]))
            except BaseException:
                print( 'Exception on ' + self.database + ' - recoveryarea_usage.py : ' + str(e.args[0]))
            return
       
       
        for r in result_set:
            self.RECOVERY_AREA_INFO['recovery_area_size'] = r[0]
            self.RECOVERY_AREA_INFO[r[1]] = r[2]
            self.RECOVERY_AREA_INFO[r[3]] = r[4]


    def dispatch_recoveryarea_info(self):
        try:
            import collectd
        
            metric = collectd.Values()
            metric.host = socket.getfqdn()
            metric.interval = 60
            metric.type = 'gauge'
        
            for key, value in self.RECOVERY_AREA_INFO.items():
                metric.plugin = self.database + '_' + self.oracle_sid + '_recovery_area_usage'
                metric.type_instance = key
                metric.values = [value]
                metric.dispatch()
        
        except BaseException:
            print self

    def __str__(self):
        output = "<{0} : recoveryarea_usage >\n".format(self.database.upper())
        for key, value in self.RECOVERY_AREA_INFO.items():
            output += "{0} : {1}\n".format(key, value)
        return output



