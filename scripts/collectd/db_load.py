import os
import sys
import socket
import signal

from stats import Stats

sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Util
from database.database import Config
from database.database import Database


class DB_Load(Stats):
    def __init__(self, database, stat_name=None):
        self.DB_LOAD = {}
        super(DB_Load, self).__init__(database, stat_name)

    def retrieve_db_load_info(self, connection):
        sql = """select stat_name,
                        decode(stat_name, 'VM_IN_BYTES', round(value/1024/1024,2),
                                          'VM_OUT_BYTES', round(value/1024/1024,2),
                                          'PHYSICAL_MEMORY_BYTES', round(value/1024/1024/1024,2),
                                          'FREE_MEMORY_BYTES', round(value/1024/1024/1024,2),
                                          'INACTIVE_MEMORY_BYTES', round(value/1024/1024/1024,2), value)
                   from v$osstat
                  where stat_name in ('LOAD','VM_IN_BYTES','VM_OUT_BYTES','NUM_CPUS','NUM_CPU_CORES','NUM_CPU_SOCKETS',
                                      'PHYSICAL_MEMORY_BYTES','FREE_MEMORY_BYTES','INACTIVE_MEMORY_BYTES')"""

        try:
            cursor = Database.get_cursor(connection)
            cursor.execute(sql)
            result_set = cursor.fetchall()
            cursor.close()

        except BaseException as e:
            try:
                collectd.info( 'Exception on ' + self.database + ' - db_load.py : ' + str(e.args[0]))
            except BaseException:
                print('Exception on ' + self.database + ' - db_load.py : ' + str(e.args[0]))
            return

        for r in result_set:
            self.DB_LOAD[r[0].lower()] = r[1]


    def dispatch_db_load_info(self):
        try:
            import collectd

            metric = collectd.Values()
            metric.host = socket.getfqdn()
            metric.interval = 60
            metric.type = 'gauge'

            #collectd.info(str(self.DB_LOAD))
            for key, value in self.DB_LOAD.items():
                metric.plugin = self.database + '_' + self.oracle_sid + '_db_load'
                metric.type_instance = key
                metric.values = [value]
                metric.dispatch()

        except BaseException:
            print self


    def __str__(self):
        output = "<{0} : db_load >\n".format(self.database.upper())
        for key, value in self.DB_LOAD.items():
            output += "{0} : {1}\n".format(key, value)

        return output



