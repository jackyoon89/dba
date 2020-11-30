import os
import sys
import socket
import signal

from stats import Stats

sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Util
from database.database import Config
from database.database import Database


class AshEtc(Stats):
    def __init__(self, database, stat_name=None):
        self.ASH = {}
        super(AshEtc, self).__init__(database, stat_name)

    def retrieve_ash_etc_info(self, connection):
        sql = """select /*+ opt_param('_optimizer_partial_join_eval','false') */
                        count(blocking_session), nvl(sum(pga_allocated),0), nvl(sum(temp_space_allocated),0)
                   from v$active_session_history
                  where sample_time > (select max(sample_time) - 1/(24*60)
                                         from v$active_session_history)"""
        try:
            cursor = Database.get_cursor(connection)
            cursor.execute(sql)
            result_set = cursor.fetchall()
            cursor.close()

        except BaseException as e:
            try:
                collectd.info( 'Exception on ' + self.database + ' - ash_etc.py : ' + str(e.args[0]))
            except BaseException:
                print('Exception on ' + self.database + ' - ash_etc.py : ' + str(e.args[0]))
            return

        for r in result_set:
            self.ASH['blocking_sessions']    = r[0]
            self.ASH['pga_allocated']        = r[1]
            self.ASH['temp_space_allocated'] = r[2]


    def dispatch_ash_etc_info(self):
        try:
            import collectd

            metric = collectd.Values()
            metric.host = socket.getfqdn()
            metric.interval = 60
            metric.type = 'gauge'

            for key, value in self.ASH.items():
                metric.plugin = self.database + '_' + self.oracle_sid + '_ash_etc'
                metric.type_instance = key
                metric.values = [value]
                #collectd.info('---------------->' + key + ", " + str(value))
                metric.dispatch()

        except BaseException:
            print self


    def __str__(self):
        output = "<{0}: ash_etc >\n".format(self.database.upper())
        for key, value in self.ASH.items():
            output += "{0} : {1}\n".format(key, value)

        return output





