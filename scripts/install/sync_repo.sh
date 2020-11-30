#!/bin/sh
# deploy new scripts and configuration files

CURRENT_DIR=/home/app/oracle/admin

cd $CURRENT_DIR

rm -rf $CURRENT_DIR/DBA

svn co https://svn.eexchange.com/svn/DBA/12c/oracle DBA >/dev/null 2>&1
cp -r $CURRENT_DIR/DBA/config/.servers/`hostname`/*         $CURRENT_DIR/DBA/config/ >/dev/null 2>&1


if [ -d $CURRENT_DIR/DBA/crontab/.servers/default ]; then
    rm -rf $CURRENT_DIR/DBA/crontab/[0-9]*/*
    cp -r $CURRENT_DIR/DBA/crontab/.servers/default/*           $CURRENT_DIR/DBA/crontab/
    rm -rf $CURRENT_DIR/DBA/crontab/[0-9]*/.svn
fi

if [ -d $CURRENT_DIR/DBA/crontab/.servers/`hostname` ];  then
    cp -r $CURRENT_DIR/DBA/crontab/.servers/`hostname`/*        $CURRENT_DIR/DBA/crontab/
    rm -rf $CURRENT_DIR/DBA/crontab/[0-9]*/.svn
fi

if [ -d $CURRENT_DIR/DBA/pycrontab/.servers/default ]; then
    rm -rf $CURRENT_DIR/DBA/pycrontab/[0-9]*/*
    cp -r $CURRENT_DIR/DBA/pycrontab/.servers/default/*           $CURRENT_DIR/DBA/pycrontab/
    rm -rf $CURRENT_DIR/DBA/pycrontab/[0-9]*/.svn
fi

if [ -d $CURRENT_DIR/DBA/pycrontab/.servers/`hostname` ];  then
    cp -r $CURRENT_DIR/DBA/pycrontab/.servers/`hostname`/*        $CURRENT_DIR/DBA/pycrontab/
    rm -rf $CURRENT_DIR/DBA/pycrontab/[0-9]*/.svn
fi

python $CURRENT_DIR/DBA/scripts/utility/database_ini_config.py > $CURRENT_DIR/DBA/config/database.ini
cp $CURRENT_DIR/DBA/config/.servers/`hostname`/database.ini $CURRENT_DIR/DBA/config/database.ini >/dev/null 2>&1
python $CURRENT_DIR/DBA/scripts/utility/collectd_config.py > $CURRENT_DIR/DBA/config/collectd/oracle.conf
python $CURRENT_DIR/DBA/scripts/utility/nagios_config.py > $CURRENT_DIR/DBA/config/nagios/`hostname`.cfg
python $CURRENT_DIR/DBA/crontab/setup/run_sql.py > $CURRENT_DIR/DBA/crontab/setup/sql/output/run_sql.out
python $CURRENT_DIR/DBA/crontab/setup/run_rman.py > $CURRENT_DIR/DBA/crontab/setup/rman/output/run_rman.out
