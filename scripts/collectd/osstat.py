import os
import sys
import socket
import signal
import pickle

from stats import Stats

sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Util
from database.database import Config
from database.database import Database


class Os_Stat(Stats):

    def __init__(self, database, stat_name='os_stat'):
        self.PREV_OS_STAT = {}
        self.CURR_OS_STAT = {}
        self.OS_STAT = [{},{}]

        super(Os_Stat, self).__init__(database, stat_name)


    def retrieve_os_stats(self, connection):
        sql = """select stat_name, value
                   from v$osstat
                  where stat_name in  ( 'BUSY_TIME',
                                        'USER_TIME',
                                        'SYS_TIME',
                                        'IOWAIT_TIME')"""

        try:
            cursor = Database.get_cursor(connection)
            cursor.execute(sql)
            result_set = cursor.fetchall()
            cursor.close()

        except BaseException as e:
            try:
                collectd.info( 'Exception on ' + self.database + ' - osstat.py : ' + str(e.args[0]))
            except BaseException:
                print( 'Exception on ' + self.database + ' - osstat.py : ' + str(e.args[0]))
            return

        # Retrieve previous OS Stats from pickle
        self.OS_STAT = super(Os_Stat, self).get_stats()
 
        # Assign both prev and curr stats if exits
        try:
            if len(self.OS_STAT) > 0:
                self.PREV_OS_STAT = self.OS_STAT[0]
                self.CURR_OS_STAT = self.OS_STAT[1]
        except TypeError:
            self.OS_STAT = [{},{}]

        for r in result_set:
            if self.PREV_OS_STAT.get(r[0].lower()) == None:

                # initialize dictionary variables
                self.PREV_OS_STAT[r[0].lower()] = r[1]
                self.CURR_OS_STAT[r[0].lower()] = r[1]

            else:
                # set new os stat to OS_STAT dictionary variable
                self.PREV_OS_STAT[r[0].lower()] = self.CURR_OS_STAT[r[0].lower()]
                self.CURR_OS_STAT[r[0].lower()] = r[1]

            self.OS_STAT[0] = self.PREV_OS_STAT
            self.OS_STAT[1] = self.CURR_OS_STAT
     
        # Write new OS Stats into pickle
        super(Os_Stat, self).set_stats(self.OS_STAT)

 
    def dispatch_os_stats(self):

        # Retrieve previous OS Stats from pickle
        self.OS_STAT = super(Os_Stat, self).get_stats()
        self.PREV_OS_STAT = self.OS_STAT[0]
        self.CURR_OS_STAT = self.OS_STAT[1]

        try:
            # send stats to carbon server
            import collectd
      
            metric = collectd.Values()
            metric.host = socket.getfqdn()
            metric.interval = 60
            metric.type = 'gauge'

            for key, value in self.CURR_OS_STAT.items():
                metric.plugin = self.database + '_' + self.oracle_sid + '_os_stat'
                metric.type_instance = key
                metric.values = [value - int(self.PREV_OS_STAT.get(key))]
                metric.dispatch()

        except BaseException:
            print self



    def __str__(self):
        output = "<{0}: osstat >\n".format(self.database.upper())
        for key, value in self.CURR_OS_STAT.items():
            output += "{0} {1}\n".format(key, value - int(self.PREV_OS_STAT.get(key)))
        return output




