import os
import sys
import socket
import signal

from stats import Stats

sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Util
from database.database import Config
from database.database import Database


class Shared_pool(Stats):
    def __init__(self, database, stat_name=None):
        self.shared_pool_usage = {}
        super(Shared_pool, self).__init__(database, stat_name)

    def retrieve_shared_pool_usage_info(self, connection):
        sql = """select *
                   from (select name, bytes
                           from v$sgastat
                          where pool = 'shared pool'
                          order by 2 desc)
                  where rownum < 10
                  union
                 select 'etc' name, sum(bytes)
                   from (select rownum no, name, bytes
                           from v$sgastat
                          where pool = 'shared pool'
                          order by 2 desc)
                  where no>= 10"""

        try:
            cursor = Database.get_cursor(connection)
            cursor.execute(sql)
            result_set = cursor.fetchall()
            cursor.close()
        except BaseException as e:
            try:
                collectd.info( 'Exception on ' + self.database + ' - shared_pool.py : ' + str(e.args[0]))
            except BaseException:
                print( 'Exception on ' + self.database + ' - shared_pool.py : ' + str(e.args[0]))
            return

        for r in result_set:
            self.shared_pool_usage[r[0]] = r[1]


    def dispatch_shared_pool_usage_info(self):
        try:
            import collectd
            
            metric = collectd.Values()
            metric.host = socket.getfqdn()
            metric.interval = 60
            metric.type = 'gauge'
            
            for key, value in self.shared_pool_usage.items():
                 metric.plugin = self.database + '_' + self.oracle_sid + '_shared_pool_usage'
                 metric.type_instance = key
                 metric.values = [value]
                 metric.dispatch()

        except BaseException:
            print self


    def __str__(self):
        output = "<{0} : Top Shared Pool usage(bytes)>\n".format(self.database.upper())
        for key, value in self.shared_pool_usage.items():
            output += "{0} : {1}\n".format(key, value)

        return output
    
