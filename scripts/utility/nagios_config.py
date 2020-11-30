import re
import os
import sys
import socket
import subprocess
import cx_Oracle

sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))
from database.database import Config


class Service(object):
    """
    Generate a service check using provided information
    """
    def __init__(self, 
                 db_info, 
                 service_description, 
                 check_command, 
                 parameters, 
                 check_interval=None,
                 notification_interval=None, 
                 max_check_attempts=None, 
                 contact_groups="dba"):
        self.db_info = db_info 
        self.service_description   = service_description
        self.host_name             = socket.getfqdn()
        self.contact_groups        = contact_groups
        self.use                   = "generic-service"
        self.check_command         = check_command
        self.parameters            = parameters
        self.check_interval        = check_interval
        self.notification_interval = notification_interval
        self.max_check_attampts    = max_check_attempts
        

    def __str__(self):
        #print re.match("(.+)", self.check_command).groups()[0]
        #check_nrpe = "check_nrpe2!"

        if re.match("(.+)", self.check_command).groups()[0] in [ "check_oracle_tablespace", "check_oracle_archivelog_gap"]:
            check_nrpe = "check_nrpe2_slow!"
        else:
            check_nrpe = "check_nrpe2!"

        output = "define service {\n" 
        if self.db_info <> None:
            output += "        service_description     " + self.db_info + "_" + self.service_description + "\n" 
        else:
            output += "        service_description     " + self.service_description + "\n" 

        #output += "        host_name               " + self.host_name + "\n" \
        #"        contact_groups          " + self.contact_groups + "\n" \
        #"        use                     " + self.use + "\n" \
        #"        check_command           " + "check_nrpe2!" + self.check_command + "!"+ self.parameters + "\n" 

        output += "        host_name               " + self.host_name + "\n" \
        "        contact_groups          " + self.contact_groups + "\n" \
        "        use                     " + self.use + "\n" \
        "        check_command           " + check_nrpe + self.check_command + "!"+ self.parameters + "\n" 

        if self.check_interval <> None:
            output += "        check_interval          " + self.check_interval + "\n"
        if self.notification_interval <> None:
            output += "        notification_interval   " + self.notification_interval + "\n" 
        if self.max_check_attampts <> None:
            output += "        max_check_attempts      " + self.max_check_attampts + "\n" 
        output += "        }\n\n"

        return output
    


class Services(object):
    def __init__(self, comment, db_info, service_checks):
        self.comment = comment
        self.services = []

        for service_info in service_checks:
            # Create nagios service checks
            service = Service( db_info,
                               service_info.get('check_command'),
                               service_info.get('check_command'),
                               service_info.get('parameters'),
                               service_info.get('check_interval'),
                               service_info.get('notification_interval'),
                               service_info.get('max_check_attampts'))

            # Put the service in the list
            self.services.append(service)


    def __str__(self):
        service_list = "# " + self.comment + "\n"
        for service in self.services:
            service_list += str(service)

        return service_list

         
class Monitoring_Service(Services):
    """
    Generate Nagios checks for Oracle Monitoring check
    """
    def __init__(self):
        service_checks = [ {'check_command' : 'check_oracle_monitoring',   'parameters'   : 'FakeArg'},
                           {'check_command' : 'check_unknown_databases',   'parameters'   : 'FakeArg'},
                           {'check_command' : 'check_oracle_listener',     'parameters'    : 'LISTENER'},
                           {'check_command' : 'check_oracle_logfile_size', 'parameters'    : '500'}]
                             
        comment = "Oracle Monitoring Check"
        super(Monitoring_Service, self).__init__( comment, None, service_checks )
   

class ASM_Services(Services):
    """
    Generate Nagios checks for ASM instance
    """
    def __init__(self, asm_sid):
        asm_sid      = None
        #service_names = [ 'oracle_crs', 'oracle_voting', 'asm_instance', 'asm_disk' , 'asm_alertlog', 'asm_logfile_size' ]
        service_checks = [ {'check_command' : 'check_oracle_crs',       'parameters' : 'FakeArg' },
                           {'check_command' : 'check_oracle_voting',    'parameters' : 'FakeArg' },
                           {'check_command' : 'check_asm_instance',     'parameters' : 'FakeArg' }, 
                           {'check_command' : 'check_asm_disk',         'parameters' : 'FakeArg' }, 
                           {'check_command' : 'check_asm_alertlog',     'parameters' : 'FakeArg'  , 'max_check_attampts': str(1) },
                           {'check_command' : 'check_asm_logfile_size', 'parameters' : '500' } ]

        comment = "ASM Checks"
        super(ASM_Services, self).__init__( comment, asm_sid, service_checks)



class Database_Services(Services):
    def __init__(self, dbname, oracle_sid):
        service_checks = []

        #service_checks = [ {'check_command' : 'check_oracle_instance',            'parameters'    : dbname},
        #                   {'check_command' : 'check_oracle_connection',          'parameters'    : dbname},
        #                   {'check_command' : 'check_oracle_processes',           'parameters'    : '{0} 70 80'.format(dbname)},
        #                   {'check_command' : 'check_oracle_tablespace',          'parameters'    : '{0} 90 95'.format(dbname),   'check_interval': str(360),  'notification_interval' : str(1440)},
        #                   {'check_command' : 'check_oracle_recoveryarea',        'parameters'    : '{0} 70 80'.format(dbname),   'notification_interval' : str(1440)},
        #                   {'check_command' : 'check_oracle_dbfile_rule',         'parameters'    : '{0} 32'.format(dbname),      'notification_interval' : str(1440)},
        #                   {'check_command' : 'check_oracle_archivelog_gap',      'parameters'    : dbname},
        #                   {'check_command' : 'check_oracle_archive_dest_status', 'parameters'    : dbname},
        #                   {'check_command' : 'check_oracle_standby_lag_min_dest2',   'parameters'    : '{0} 2 30 60'.format(dbname)},
        #                   {'check_command' : 'check_oracle_standby_lag_min_dest3',   'parameters'    : '{0} 3 30 60'.format(dbname)},
        #                   {'check_command' : 'check_oracle_scheduler_jobs',      'parameters'    : dbname},
        #                   {'check_command' : 'check_oracle_alertlog',            'parameters'    : dbname,                       'max_check_attampts'    : str(1) },
        #                   {'check_command' : 'check_oracle_session_cursors',     'parameters'    : '{0} 70 85'.format(dbname),   'max_check_attampts'    : str(1) },
        #                   {'check_command' : 'check_oracle_blocking_sessions',   'parameters'    : '{0} 1'.format(dbname)},
        #                   {'check_command' : 'check_oracle_restore_point',      'parameters'    : dbname, 'check_interval': str(360),  'notification_interval' : str(1440)},
        #                   {'check_command' : 'check_oracle_tempfile', 'parameters'    : dbname, 'check_interval': str(360),  'notification_interval' : str(1440)} ]

        configuration = Config()
        configuration.set_ora_env(dbname)
        
        db_type    = configuration.get_attr_value(dbname, 'db_type')
        is_standby = configuration.get_attr_value(dbname, 'is_standby')


        if db_type in ['container','stand_alone']:
            service_checks.append({'check_command' : 'check_oracle_instance',            'parameters'    : dbname})
            service_checks.append({'check_command' : 'check_oracle_processes',           'parameters'    : '{0} 70 80'.format(dbname)})
            service_checks.append({'check_command' : 'check_oracle_alertlog',            'parameters'    : dbname,                       'max_check_attampts'    : str(1) })
            service_checks.append({'check_command' : 'check_oracle_archive_dest_status', 'parameters'    : dbname})
            service_checks.append({'check_command' : 'check_oracle_recoveryarea',        'parameters'    : '{0} 70 80'.format(dbname),   'notification_interval' : str(1440)})
            service_checks.append({'check_command' : 'check_oracle_session_cursors',     'parameters'    : '{0} 70 85'.format(dbname),   'max_check_attampts'    : str(1) })
            service_checks.append({'check_command' : 'check_oracle_tempfile',            'parameters'    : dbname,                       'check_interval': str(360),  'notification_interval' : str(1440)})
            service_checks.append({'check_command' : 'check_oracle_no_files',            'parameters'    : '{0} 80 90'.format(dbname),   'check_interval': str(360),  'notification_interval' : str(1440)})

            service_checks.append({'check_command' : 'check_oracle_standby_lag_min',     'parameters'    : '{0} 10 20'.format(dbname)})
            service_checks.append({'check_command' : 'check_oracle_archivelog_gap',      'parameters'    : dbname})

            host_name = socket.getfqdn()

            # Do not generate PPAM/PMIG databases
            if not re.match(".+\.(\w+)(\..*\d.*)*", host_name).groups()[0] in [ "ppam", "pmig" ] :
                service_checks.append({'check_command' : 'check_oracle_rman_backup',         'parameters'    : dbname,                       'check_interval': str(360),  'notification_interval' : str(1440)})
         
            if re.match(".+FDC\d*", dbname):
                service_checks.append({'check_command' : 'check_oracle_wallet',          'parameters'    : dbname})
        

        #if not (is_standby == 'yes' and db_type == 'pdb'):
        # checks for container, stand-aline and pdbs
        service_checks.append({'check_command' : 'check_oracle_connection',          'parameters'    : dbname})
        service_checks.append({'check_command' : 'check_oracle_blocking_sessions',   'parameters'    : '{0} 10'.format(dbname)})
        service_checks.append({'check_command' : 'check_oracle_tablespace',          'parameters'    : '{0} 90 95'.format(dbname),   'check_interval': str(360),  'notification_interval' : str(1440)})
        service_checks.append({'check_command' : 'check_oracle_dbfile_rule',         'parameters'    : '{0} 32'.format(dbname),      'notification_interval' : str(1440)})
        service_checks.append({'check_command' : 'check_oracle_scheduler_jobs',      'parameters'    : dbname})
        service_checks.append({'check_command' : 'check_oracle_restore_point',       'parameters'    : dbname, 'check_interval': str(360),  'notification_interval' : str(1440)})

        if re.match(".+FDC\d*", dbname):
            service_checks.append({'check_command' : 'check_oracle_wallet',          'parameters'    : dbname})
            
        
        comment = dbname + " Database Checks"
        #super(Database_Services, self).__init__( comment, dbname, service_names, service_parameters)
        #super(Database_Services, self).__init__( comment, oracle_sid, service_checks)
        #super(Database_Services, self).__init__( comment, dbname + '_' + oracle_sid, service_checks)
        if db_type == 'pdb':
            super(Database_Services, self).__init__( comment, oracle_sid + '_' + dbname, service_checks)
        else:
            super(Database_Services, self).__init__( comment, oracle_sid, service_checks)



 
class NagiosConfig(object):
    """
    Generate each set of monitoring components and combind together
    """
    def __init__(self):
        self.services = []
        self.services.append(Monitoring_Service())

        # Check if ASM exists
        s = subprocess.Popen(["ps","axw"], stdout=subprocess.PIPE)
        for out in s.stdout:
            p = re.compile(".*asm_pmon_(.*)")
            result = p.search(out)

            # Add ASM if exists
            if result <> None: 
                asm_sid = result.group(1)[1:]
                self.services.append(ASM_Services(asm_sid))
        
        # Databases configuration
        configuration = Config()
        db_list = configuration.list_databases()

        for dbname in db_list:
            #if configuration.get_attr_value(dbname, 'db_type') == 'container':
            #    continue

            oracle_sid = configuration.get_attr_value( dbname, 'oracle_sid')

            self.services.append(Database_Services(dbname, oracle_sid)) 
        

    def __str__(self):
        service_list = ""
        for service in self.services:
            service_list += str(service)
        return service_list


if __name__ == "__main__":
    nagios_config = NagiosConfig()
    print "# This is automatically generated by nagios_config.py script on the database server."
    print nagios_config

