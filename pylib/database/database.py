from config import Config
#import cx_Oracle
import socket
import sys

class Database(object):
    """Database class provides below methods 
          1. get_connection 
          2. disconnect
          3. get_cursor     
          4. set_oracle_home
    """
    connection=None
    cursor=None


    @staticmethod
    def get_connection(username, password, service_name):
        
        config = Config()
        config.set_ora_env(service_name)

        #hostname = socket.getfqdn()
        try:
            hostname = config.get_attr_value(service_name, hostname)
            port = config.get_attr_value(service_name, port)
        except:
            hostname = socket.getfqdn()
            port = "1521"
        
        connection = ''
        try:
            import cx_Oracle

            # Connect / as sysdba 
            # 2019/3/21 - JYOON : Changed to use Easy Connect to support PDBs.
            #connection = cx_Oracle.connect(username, password, mode=cx_Oracle.SYSDBA)
            #connection = cx_Oracle.connect(username + '/' +  password + '@' + hostname + '/' + service_name, mode=cx_Oracle.SYSDBA)
            connection = cx_Oracle.connect(username + '/' +  password + '@' + hostname + ':' + port + '/' + service_name, mode=cx_Oracle.SYSDBA)
        except Exception as e:
            print service_name + " : " +  str(e)
            try:
                import collectd
                collectd.info(service_name + " : " + str(e))
                #collectd.info( 'Failed: connection using : /@' + hostname + "/" + service_name)
            except ImportError:
                print( 'Failed: import collectd: /@' + hostname + "/" + service_name)

        return connection


    @staticmethod
    def disconnect(connection):
        if connection:
            connection.close() 

    @staticmethod
    def get_cursor(connection):
        cursor = connection.cursor()
        return cursor

    @staticmethod
    def get_parameter(username, password, service_name, parameter_name):
        sql="""select value from v$parameter where name = lower(:1)"""
        connection = Database.get_connection(username, password, service_name)
        cursor = connection.cursor()
        cursor.execute(sql, (parameter_name,)) 
        return [rec for rec in cursor][0][0]



class Task(object):
    """Task class provide below methods
       1. __init__   : Initialize database connection
       2. add_task   : Add task information to the ADMIN.TASK_MONITOR table and returns task_no sequence number.
       3. get_task_no: Provide task_no to add_task method
       4. update_task: update final task status to the record in ADMIN.TASK_MONITOR table.
       5. get_estimated_time: Provide estimated finish time to add_task method
    """

    def __init__(self):
        self.conn = Database.get_connection()

    def __del__(self):
        try:
            self.conn.close()
        except:
            pass


    def add_task(self, task_name, db_name, status ):
        sql = """insert into admin.task_monitor
                 values ( :1, :2, :3, sysdate, null, to_date(:4,'yyyy/mm/dd hh24:mi:ss'), :5, null)"""

        try:
            cursor = self.conn.cursor()
            task_no = self.get_task_no()
            est_end_time = self.get_estimated_time( task_name, db_name )
            cursor.execute( sql , (task_no, task_name, db_name, est_end_time, status))
            self.conn.commit()

        except BaseException as e:
            print(e.args[0])

        return task_no


    def get_task_no(self):
        sql = """select admin.seq_task_monitor.nextval from dual"""

        try:
            cursor = self.conn.cursor()
            cursor.execute( sql )
        except BaseException as e:
            print(e.args[0])

        return [rec for rec in cursor][0][0]


    def update_task(self, task_no, status, task_output ):
        sql = """update admin.task_monitor
                    set end_time = sysdate,
                        status = :1,
                        task_output = :2
                  where task_no = :3"""

        try:
            cursor = self.conn.cursor()
            output = cursor.var(cx_Oracle.CLOB)
            output.setvalue(0,task_output)
            cursor.execute( sql, (status, output, task_no))
            self.conn.commit()
        except BaseException as e:
            print(e.args[0])

                
    def get_estimated_time(self, task_name, db_name):
        sql = """select nvl(max(task_no),0)||','||
                        to_char(nvl(max(sysdate + (end_time - start_time) + 
                        (end_time - start_time)*1.2/(24*60)), sysdate + 2/24),'yyyy/mm/dd hh24:mi:ss')
                   from admin.task_monitor
                  where task_name = :1
                    and db_name = :2
                    and status = 'SUCCEEDED'"""
        try:
            cursor = self.conn.cursor()
            cursor.execute( sql , (task_name, db_name))

        except BaseException as e:
            print(e.args[0])
        
        return [rec for rec in cursor][0][0].split(',')[1]


    def __str__(self):
        return self.task_name + " is " + self.status + " on " + self.db_name 


