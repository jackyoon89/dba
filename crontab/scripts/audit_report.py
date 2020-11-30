#!/usr/bin/env python
#
# Author: jyoon
#
# 2020/06/01 - Check database.ini and send email to audit_report_recipient if it is set.
#
import sys
import os
import re
import zipfile 
import socket
from subprocess import Popen, PIPE

sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util      import Util
from utility.util      import Monitor 
from utility.util      import Mail
from database.database import Config
from database.database import Database

audit_length=7

def main():
    configuration = Config()
    db_list = configuration.list_databases()

    message = ""
    for dbname in db_list:
        
        if configuration.get_attr_value(dbname, 'is_standby') == 'yes':
            continue

        if configuration.get_attr_value(dbname, 'audit_report_recipient') != 'NONE':
            email_recipient_list = configuration.get_attr_value(dbname, 'audit_report_recipient')
          

            # Set Oracle Related Environ variables
            ora_home = configuration.get_attr_value(dbname,'oracle_home')
            try:
                os.environ['ORACLE_HOME'] = ora_home
                os.environ['LD_LIBRARY_PATH'] = ora_home + '/lib'

            except ValueError as e:
                print (e.args[0])


            auth = configuration.parser.get(dbname, 'sys_user').split('/')
            
            sql = """select to_char(TIMESTAMP,'DD-MON-YY HH24:MI:SS'),OS_USERNAME, USERHOST,USERNAME,ACTION_NAME, OBJ_NAME,
                            decode(RETURNCODE,0,'SUCCEED', 1005,'Null password given; login denied',
                                                           1017,'Invalid username/password; login denied',
                                                           28000,'The account is locked') returncode, COMMENT_TEXT
                       from dba_audit_trail
                      where timestamp >= trunc(sysdate - :audit_length)
                        and os_username not in ('apps','apache','efxapps','oagent','oracle')
                        and exists (select instance_name 
                                      from v$instance
                                     where instance_number = (select max(instance_number)
                                                                from gv$instance
                                                               where status = 'OPEN'))
                            
                      order by TIMESTAMP DESC"""
 
            try:
                connection = Database.get_connection (auth[0], Config.get_pass(auth[1]).strip(), dbname)
                cursor = Database.get_cursor(connection)
                cursor.execute(sql, (audit_length,))

                # Create /tmp/audit_DBNAME.csv file
                outfile = '/tmp/audit_' + dbname + '.csv'
                with open(outfile, 'w') as fh:
                    csv_str = "TIMESTAMP,OS_USERNAME,USERHOST,USERNAME,ACTION_NAME,OBJ_NAME,RETURNCODE, COMMENT_TEXT"
                    fh.write(csv_str)
                    fh.write("\n")

                    for rec in cursor:
                        csv_str = ','.join([str(r or '') for r in rec])
                        fh.write(csv_str)
                        fh.write("\n")

            except BaseException as e:
                print(e.args[0])

  
            zf = zipfile.ZipFile( outfile + '.zip', mode='w', compression=zipfile.ZIP_DEFLATED)
            zf.write(outfile, os.path.basename(outfile))
            zf.close()

            process = Popen(['/bin/rm','-f', outfile], stdout=PIPE, stderr=PIPE)
            process.communicate()

            email_list = email_recipient_list.split(',')

            mail = Mail()
            #for send_to in email_list:
            #    mail.send( send_to, 'Weekly Audit Report - Database(' + dbname + ')', message, outfile + ".zip" )
            mail.send( email_list, 'Weekly Audit Report - Database(' + dbname + ')', message, outfile + ".zip" )



if __name__ == "__main__":
    main()

