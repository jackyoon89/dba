#!/usr/bin/env python
#
# Author: jyoon
#
# 2017/01/13 - Collectd plugin for Oracle Dashboard - OS STAT
#
import os
import sys
import socket
import signal
sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

from utility.util    import Util
from database.database import Config
from database.database import Database


def python_plugin_conf():
    print """
LoadPlugin python
LoadPlugin write_graphite

<Plugin python>
        ModulePath "/home/app/oracle/admin/DBA/scripts/collectd"
        LogTraces false
        Interactive false
        Import "oracle_stats"

#       Import "spam"
#
#       <Module spam>
#               spam "wonderful" "lovely"
#       </Module>
</Plugin> """


def write_graphite_plugin_conf( server, port, prefix, dbname, instance_name):
    contents = """  <Node "{0}">
    Host "{1}"
    Port "{2}"
    Protocol "tcp"
    ReconnectInterval 0
    LogSendErrors true
    Prefix "{3}."
    Postfix ".db.{4}.{5}"
    StoreRates true
    AlwaysAppendDS false
    EscapeCharacter "_"
  </Node>"""
    print contents.format(dbname, server, port, prefix, dbname, instance_name)

def postcache_conf(dbname, instance_name):
    contents = """  <Rule "{0}">
    <Match "regex">
      Plugin "^{1}_{2}"
    </Match>
    <Target "write">
      Plugin "write_graphite/{3}"
    </Target>
    <Target "return">
    </Target>
  </Rule>"""
    print contents.format(dbname, dbname, instance_name, dbname)
  
if __name__ == '__main__':
    carbon_servers = {'ny1':'carbon01.ny1.eexchange.com:2203:collectd.ny1',
                      'ny9':'carbon01.ny1.eexchange.com:2203:collectd.ny1',
                      'va1':'carbon01.ny1.eexchange.com:2090:collectd.ny1',
                      'ny2':'carbon01.ny2.eexchange.com:2080:collectd.ny2',
                      'ny4':'carbon01.ny5.eexchange.com:2090:collectd.ny4',
                      'ny5':'carbon01.ny5.eexchange.com:2090:collectd.ny5',
                      'ch1':'carbon01.ny5.eexchange.com:2090:collectd.ch1',
                      'ld4':'carbon01.ny5.eexchange.com:2090:collectd.ld4',
                      'tk1':'carbon01.ny5.eexchange.com:2090:collectd.tk1',
                      'ny6':'carbon01.ny6.eexchange.com:2090:collectd.ny6',
                      'pr1':'carbon01.pr1.eexchange.com:2013:collectd.pr1'}

    
    # Changed the index to fix a bug in case when hostname has less than 3 pieces like (dbmon.ny9).
    #data_center = socket.gethostname().split('.')[2:][0]
    data_center = socket.gethostname().split('.')[-1:][0]

    carbon_server = carbon_servers[data_center].split(':')

    configuration = Config()
 
    python_plugin_conf()

    # print default write_graphite
    contents = """\n

<Plugin write_graphite>
  <Node "default">
    Host "{0}"
    Port "{1}"
    Protocol "tcp"
    ReconnectInterval 0
    LogSendErrors true
    Prefix "{2}."
    StoreRates true
    AlwaysAppendDS false
    EscapeCharacter "_"
  </Node>\n"""
    print contents.format(carbon_server[0], carbon_server[1], carbon_server[2])
  
    db_list = configuration.list_databases()

    for dbname in db_list:
        if configuration.get_attr_value(dbname, 'db_type') == 'container':
            continue

        #if configuration.get_attr_value(dbname, 'is_standby') == 'yes':
        #    continue

        instance_name = configuration.get_attr_value( dbname, 'oracle_sid')
    
        write_graphite_plugin_conf(carbon_server[0], carbon_server[1], carbon_server[2], dbname.lower(), instance_name.lower())

    print "</Plugin>\n\n"


    print """LoadPlugin match_regex
PostCacheChain "PostCache"
<Chain "PostCache">"""


    for dbname in db_list:
        if configuration.get_attr_value(dbname, 'db_type') == 'container':
            continue
   
        instance_name = configuration.get_attr_value( dbname, 'oracle_sid') 
        postcache_conf(dbname.lower(), instance_name.lower())

    print  """  <Target "write">
    Plugin "write_graphite/default"
  </Target>
</Chain>"""
