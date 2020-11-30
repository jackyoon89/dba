import re
import os
import sys
import socket
import subprocess
import cx_Oracle
#from pathlib import Path

sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))
from database.database import Config


class DatabaseInfo(object):
    """
    Database informtion which will make a section of $ORACLE_BASE/admin/DBA/config/database.ini file.
    """

    def set_db_name(self, db_name):
        self.db_name = db_name

    def set_is_standby(self, is_standby="no"):
        self.is_standby = is_standby

    def set_is_asm(self, is_asm="no"):
        self.is_asm = is_asm

    # database type - container, pdb, stand_alone, standby
    def set_db_type(self, db_type="stand_alone"):
        self.db_type = db_type

    def set_hostname(self, hostname):
        self.hostname = hostname

    def set_port(self, port=1521):
        self.port = port

    def set_ora_sid(self, ora_sid):
        self.ora_sid = ora_sid

    def set_ora_base(self, ora_base):
        self.ora_base = ora_base

    def set_ora_home(self, ora_home):
        self.ora_home = ora_home

    def set_db_unique_name(self, db_unique_name):
        self.db_unique_name = db_unique_name

    def set_auth(self, db_type):
        if db_type == 'stand_alone':
            self.sys_user = 'crontab/Ef5AxKDMjgwReE4bvo3dWA'
        else:
            self.sys_user = 'c##admin/Ef5AxKDMjgwReE4bvo3dWA'

    # backup_type : (Daily:Weekly)
    def set_backup_type(self, backup_type="NONE:NONE"):
        self.backup_type = backup_type
 
    def set_run_exp(self, is_run_exp="no"):
        self.is_run_exp = is_run_exp

    # String representation of all values in the database section
    def __str__(self):
        ini_string = "[{0}]\n\
; Environment variables\n\
is_standby={1}\n\
is_asm={2}\n\
db_type={3}\n\
hostname={4}\n\
port={5}\n\
oracle_sid={6}\n\
oracle_base={7}\n\
oracle_home={8}\n\
db_unique_name={9}\n\n\
; Set encrypt_seed = 0 to disable encryption \n\
encrypt_seed=3\n\
sys_user={10}\n\n\
; Rman Backup\n\
; rman_backup_type = DAILY:WEEKLY\n\
; Examples of backup_type : COLD|HOT|ARCHIVELOG|PURGEONLY|NONE\n\
rman_backup_type={11}\n\
\n\
; Export Backup\n\
run_export={12}\n\
\n\
; Audit Report\n\
audit_report_recipient=NONE\n\
\n\n"
               
        return ini_string.format(self.db_name, self.is_standby, self.is_asm, self.db_type, self.hostname, self.port, self.ora_sid, self.ora_base, self.ora_home, self.db_unique_name, self.sys_user, self.backup_type, self.is_run_exp)
          


""" ---------------------------------
    CLASS: DatabaseINI
           Generate database.ini file
------------------------------------- """
class DatabaseINI(object):
    """
    This class uses DatabaseInfo class to generate $ORACLE_BASE/admin/DBA/database.ini file.
    """

    def generate_contents(self):

        # List to hold DatabaseInfo objects
        self.databases = []

        with open('/etc/oratab') as fp:
            for line in fp:
                oratab_entry = line.rstrip().split(':')

                if len(oratab_entry) == 3:
                       
                    #if re.match(r'[^(\+ASM(\d+)|\-MGMTDB)]', oratab_entry[0]) and re.match(r'[^#]', oratab_entry[0]):
                    if not re.match(r'^\+ASM(\d+)', oratab_entry[0]) and not re.match(r'^\-MGMTDB', oratab_entry[0]) and not re.match(r'^#', oratab_entry[0]):
                        self.sid = oratab_entry[0]
                        home = oratab_entry[1]

                        s = subprocess.Popen(["ps","axw"], stdout=subprocess.PIPE)
                        for line in s.stdout:
                            p = re.compile("(\d+).*ora_pmon_"+self.sid+"$")
                            cols = p.search(line)
             
                            if cols <> None:
                                # Setup environment variables
                                configuration = Config()

                                try:
                                    configuration.set_env('ORACLE_SID', self.sid)
                                    configuration.set_env('ORACLE_HOME', home)
                                    configuration.set_env('LD_LIBRARY_PATH', home + "/lib")
                                except ValueError as e:
                                    print (e.args[0])



                                #print "#######################"
                                #print os.environ['ORACLE_SID']
                                #print os.environ['ORACLE_HOME']
                                #print os.environ['LD_LIBRARY_PATH']

                                # connect / as sysdba
                                try:
                                    self.connection = cx_Oracle.connect("/", mode=cx_Oracle.SYSDBA)
                                except ValueError as e:
                                    print (e.args[0])

                                # Instantiate a Section value of database.ini file
                                db_info = DatabaseInfo()
                                db_info.set_db_name(self.get_dbname())
                                db_info.set_is_standby(self.get_is_standby())
                                db_info.set_is_asm("no")
                                db_info.set_db_type(self.get_db_type())
                                db_info.set_hostname(socket.getfqdn())
                                db_info.set_port(1521)
                                db_info.set_ora_sid(self.sid)
                                db_info.set_ora_base("/home/app/oracle")
                                db_info.set_ora_home(home)
                                db_info.set_db_unique_name(self.get_db_unique_name())
                                db_info.set_auth(self.get_db_type())
                                db_info.set_backup_type(self.get_backup_type())
                                db_info.set_run_exp(self.get_run_exp())

                                # Put the database(stand_alone or container) in the list
                                self.databases.append(db_info)
 
                                # If the database is container, check pdbs in the container
                                if db_info.db_type == "container":
                                    pdb_list = self.get_pdb_list()
 
                                    # iterate through each pdb from the pdb_list
                                    for pdb in pdb_list:
 
                                        # Instantiate a section value of database.ini file for a pdb.
                                        db_info = DatabaseInfo()
                                        db_info.set_db_name(pdb)
                                        db_info.set_is_standby(self.get_is_standby())
                                        db_info.set_is_asm("no")
                                        db_info.set_db_type("pdb")
                                        db_info.set_hostname(socket.getfqdn())
                                        db_info.set_port(1521)
                                        db_info.set_ora_sid(self.sid)
                                        db_info.set_ora_base("/home/app/oracle")
                                        db_info.set_ora_home(home)
                                        db_info.set_db_unique_name(self.get_db_unique_name())
                                        db_info.set_auth(self.get_db_type())
                                        db_info.set_backup_type("NONE:NONE")
                                        db_info.set_run_exp("no")
  
                                        # Put the database(pdb) in the list
                                        self.databases.append(db_info)


    def get_dbname(self):
        sql = """select name
                   from v$database"""

        cursor = self.connection.cursor()
        cursor.execute(sql)
        resultset = cursor.fetchall()
        cursor.close()

        for rec in resultset:
            db_name = rec[0]
        return db_name

    def get_db_unique_name(self):
        sql = """select value
                   from v$parameter
                  where name = 'db_unique_name'"""
        cursor = self.connection.cursor()
        cursor.execute(sql)
        resultset = cursor.fetchall()
        cursor.close()

        for rec in resultset:
            db_unique_name = rec[0]
        return db_unique_name


    def get_is_standby(self):
        sql = """select open_mode
                   from v$database"""

        cursor = self.connection.cursor()
        cursor.execute(sql)
        resultset = cursor.fetchall()
        cursor.close()

        for rec in resultset:
            open_mode = rec[0]
            if open_mode == "READ WRITE":
                return "no"
            else:
                return "yes"


    def get_db_type(self):
        sql = """select cdb 
                   from v$database"""
        try:
            cursor = self.connection.cursor()
            cursor.execute(sql)
            resultset = cursor.fetchall()
            cursor.close()

            for rec in resultset:
                cdb = rec[0]
       
            if cdb == "YES":
                return "container"
            else:
                return "stand_alone"
        except BaseException:
            return "stand_alone"


    def get_pdb_list(self):
        sql = """select name 
                   from v$pdbs pdb
                  where open_mode = 'READ WRITE'
                     or exists (select 'x' from v$database
                                 where open_mode = 'MOUNTED'
                                   and pdb.con_id <> 2)"""
        cursor = self.connection.cursor()
        cursor.execute(sql)
        resultset = cursor.fetchall()
        cursor.close()

        pdb_list = []
        for rec in resultset:
            pdb_list.append(rec[0])

        return pdb_list


    def get_backup_type(self):
        instance = ""
        sql = """select instance from v$thread
                  where thread# = (select max(thread#) 
                                     from v$thread 
                                    where status = 'OPEN'
                                      and instance like 'P%' or instance like 'U%' or instance like 'O01%' or instance = 'FXRPT' 
                                       or instance like 'Q%' or instance like '%UAT%') 
                                      and 1 = (select count(s.machine) from v$session s
                                                where s.sid = (select m.sid
                                                                from v$mystat m
                                                               where rownum = 1)
                                                  and s.machine not like '%hist%')"""


        try:
            cursor = self.connection.cursor()
            cursor.execute(sql)
            resultset = cursor.fetchall()
            cursor.close()

            for rec in resultset:
                instance = rec[0]

            if instance == self.sid:
                if self.get_is_standby() == "yes":
                    return "PURGEONLY:PURGEONLY"
                else:
                    return "ARCHIVELOG:HOT"
            elif self.get_is_standby() == "yes":
                return "PURGEONLY:PURGEONLY"
            else:
                return "NONE:NONE"
        except BaseException as e:
            print (e.args[0])
            return "NONE:NONE"


    def get_run_exp(self):
        instance = ""
        sql = """select instance from v$thread
                  where thread# = (select max(thread#) from v$thread)
                    and instance like 'P%INS%'
                     or instance like 'P%RET%'
                     or instance like 'P%TKFX%'
                     or instance like 'P%LDFX%'
                     or instance like 'O01%'"""
        try:
            cursor = self.connection.cursor()
            cursor.execute(sql)
            resultset = cursor.fetchall()
            cursor.close()

            for rec in resultset:
                instance = rec[0]

            if instance == self.sid:
                if self.get_is_standby() == "yes":
                    return "no"
                else:
                    return "yes"
            else:
                return "no"
        except BaseException:
            return "no"


    def __str__(self):
        ini_contents = ""
        # Concatnate ini configuration of all the databases in the list
        for db_info in self.databases:
            ini_contents += str(db_info)
        return ini_contents


if __name__ == "__main__":
    database_ini = DatabaseINI()

    database_ini.generate_contents()
    print database_ini







    
