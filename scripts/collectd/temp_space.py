import os
import sys
import socket
import signal

from stats import Stats

sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Util
from database.database import Config
from database.database import Database


class Temp_space(Stats):
    def __init__(self, database, stat_name=None):
        self.TEMP_INFO = {}
        super(Temp_space, self).__init__(database, stat_name)

    def retrieve_temp_space_info(self, connection):
        sql = """select lower(tablespace_name), 
                        round(tablespace_size/1024/1024/1024,2), 
                        round((tablespace_size-free_space)/1024/1024/1024,2)
                   from dba_temp_free_space"""

        try:
            cursor = Database.get_cursor(connection)
            cursor.execute(sql)
            result_set = cursor.fetchall()
            cursor.close()

        except BaseException as e:
            try:
                collectd.info( 'Exception on ' + self.database + ' - temp_space.py : ' + str(e.args[0]))
            except BaseException:
                print( 'Exception on ' + self.database + ' - temp_space.py : ' + str(e.args[0]))
            return

        for r in result_set:
            self.TEMP_INFO[r[0]] = r[1]
            self.TEMP_INFO[r[0] + "_used"] = r[2]


    def dispatch_temp_space_info(self):
        try:
            import collectd

            metric = collectd.Values()
            metric.host = socket.getfqdn()
            metric.interval = 60
            metric.type = 'gauge'

            for key, value in self.TEMP_INFO.items():
                metric.plugin = self.database + '_' + self.oracle_sid + '_temp_space_usage'
                metric.type_instance = key
                metric.values = [value]
                metric.dispatch()

        except BaseException:
            print self


    def __str__(self):
        output = "<{0} : temp_space >\n".format(self.database.upper())
        for key, value in self.TEMP_INFO.items():
            output += "{0} : {1}\n".format(key, value) 

        return output

