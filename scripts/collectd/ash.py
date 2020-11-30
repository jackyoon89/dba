import os
import sys
import socket
import signal

from stats import Stats

sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Util
from database.database import Config
from database.database import Database


class Ash(Stats):

    def __init__(self, database, stat_name=None):
        self.ASH = []
        super(Ash, self).__init__(database, stat_name)


    def retrieve_ash_info(self, connection):
        sql = """select (select username from dba_users d where d.user_id = s.user_id) username, sql_id,
                         machine, module, program, event, wait_class, session_state
                    from v$active_session_history s
                   where sample_time > (sysdate-1/(24*60))"""

        try:
            cursor = Database.get_cursor(connection)
            cursor.execute(sql)
            result_set = cursor.fetchall()
            cursor.close()

        except BaseException as e:
            try:
                collectd.info( 'Exception on ' + self.database+ ' - ash.py : ' + str(e.args[0]))
            except BaseException:
                print( 'Exception on ' + self.database + ' - ash.py : ' + str(e.args[0]))
            return


        for r in result_set:

            # check if the record has 8 columns. If not skip.
            if len(r) <> 8:
                continue

            """
            Below algorithm makes data structure like this:

            ASH[0]['user1':3,  ASH[1]['sql_id1':10,  ASH[2]['machine1':5,   ...
                   'user2':2,         'sql_id2':9,          'machine2':4,   ...
                   'user3':1          'sql_id3':2           'machine3':7    ...
                   ...]               ...]                  ...]            ...] etc.
            """
            for indx, col in enumerate(list(r)):
                if col == None:
                    col = "none"

                try:
                    if self.ASH[indx].get(col.lower()) == None:
                        self.ASH[indx][str(col).lower()] = 1
                    else:
                        # Add 1 for additional occurances
                        self.ASH[indx][str(col).lower()] += 1
                except:
                    # Add additional column in the list that can store dictionary type
                    self.ASH.append({str(col).lower():1})


    def dispatch_ash_info(self):
        self.column_names = ['username','sql_id','machine','module','program','event','wait_class','session_state']

        try:
            # send ash stats to the carbon server
            import collectd

            metric = collectd.Values()
            metric.host = socket.getfqdn()
            metric.interval = 60
            metric.type = 'gauge'

            for indx, column in enumerate(self.ASH):
                #collectd.info('---------------ash(' + metric.plugin + ')---------------')
                metric.plugin = self.database + '_' + self.oracle_sid + '_' + self.column_names[indx]

                for key, value in column.items():
                    #collectd.info("Key ---> " + str(key) + " value ----> " + str(value) )
                    metric.type_instance = str(key)
                    metric.values = [value]
                    metric.dispatch()

        except BaseException:
            print self


    def __str__(self):
        output = "<{0}: ash >\n".format(self.database.upper())
        for indx, column in enumerate(self.ASH):
            output += "[ " + self.column_names[indx] + " ]\n"
            for key, value in column.items():
                output += "  " + key + " : " + str(value) + "\n"

        return output
 


