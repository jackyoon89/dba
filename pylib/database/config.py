import os
import subprocess
from ConfigParser import SafeConfigParser


class Config(object):
    '''This class read the configuration file and suppoert database configuration informaiton'''
    INI_FILE="{0}/../../config/database.ini".format(os.path.dirname(os.path.realpath(__file__)));
 
    def __init__(self):
        '''Read INI file and parse'''
        self.parser = SafeConfigParser()
        self.parser.read(Config.INI_FILE)

    def is_database(self, database):
    	'''Check if the database which is passed as a parameter is in the configuration'''
        return (database in self.parser.sections())

    def list_databases(self):
    	'''Return list of databases'''
        return self.parser.sections()

    def get_attr_value(self, database, attr_name):
    	'''Return parameter value for the database and attr_name(parameter)'''
        try:
            attr_value = self.parser.get(database, attr_name)
        except:
            raise ValueError("Parameter {0} is not defined on {1} database.".format(attr_name, database))
        return attr_value
    
    def set_env(self, attr_name=None, attr_value=None):
        os.environ[attr_name] = attr_value

    def set_ora_env(self, db):
        self.set_env('ORACLE_SID' , self.get_attr_value( db, 'oracle_sid'))
        self.set_env('ORACLE_HOME', self.get_attr_value( db, 'oracle_home'))
        self.set_env('LD_LIBRARY_PATH', self.get_attr_value( db, 'oracle_home') + "/lib")

    @staticmethod
    def get_pass( string ):
        cmd = os.path.dirname(os.path.realpath(__file__)) + "/keygen.pl --seed_number=3 --token=" + string
        proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (stdout, stderr) = proc.communicate()
        return stdout

#    def get_backup_info(self, database):
#    	'''Return backup configuration in the configuration for the database passed.
#    	   return tuple(daily_backup_mode, weekly_backup_mode) value'''
#        
#        backup_info = self.get_attr_name(self, database, 'rman_backup_type')
#        return backup_info.split(":")

