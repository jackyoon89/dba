import os
import sys
import socket
import signal
import pickle

sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Util
from database.database import Config
from database.database import Database


class Stats(object):

    # Set stat_name, database 
    def __init__(self, database, stat_name):

        # load configuration
        configuration = Config()

        if stat_name <> None:
            self.stat_name = stat_name.lower()
        self.database = database.lower()
       
        # retrieve oracle_sid from the configuration
        self.oracle_sid = configuration.get_attr_value(database, 'oracle_sid').lower()


    # Read from pickle and return stats
    def get_stats(self):
        try:
            with open("/tmp/." + self.stat_name + "_" + self.database, "rb") as infile:
                return pickle.load(infile)
        except:
            pass    

    # Save stats into pickle
    def set_stats(self, stats_var):
        try:
            with open("/tmp/." + self.stat_name + "_" + self.database, "wb") as outfile:
                pickle.dump(stats_var, outfile)
        except:
            pass

    def __str__(self):
        return "{}:{}".format(self.database, self.stat_name)
