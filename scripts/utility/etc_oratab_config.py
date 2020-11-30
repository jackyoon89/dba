import re
import os
import sys
import subprocess
#from pathlib import Path

sys.path.append('{0}/../../pylib'.format(os.path.dirname(os.path.realpath(__file__))))

def main():
    database_info = {}
    s = subprocess.Popen(["ps","axw"], stdout=subprocess.PIPE)
    for out in s.stdout:
        p = re.compile("(\d+).*_pmon_(.*)")
        cols = p.search(out)
             
 
        if cols <> None:
           database = cols.group(2)

           database_info[database] = database + ":" + os.readlink("/proc/" + cols.group(1) + "/exe").replace("/bin/oracle","") + ":N"
           
    with open("/etc/oratab","w") as fp:
        fp.write("""# This file is used by ORACLE utilities.  It is created by root.sh
# and updated by either Database Configuration Assistant while creating
# a database or ASM Configuration Assistant while creating ASM instance.

# A colon, ':', is used as the field terminator.  A new line terminates
# the entry.  Lines beginning with a pound sign, '#', are comments.
#
# Entries are of the form:
#   $ORACLE_SID:$ORACLE_HOME:<N|Y>:
#
# The first and second fields are the system identifier and home
# directory of the database respectively.  The third field indicates
# to the dbstart utility that the database should , "Y", or should not,
# "N", be brought up at system boot time.
#
# Multiple entries with the same $ORACLE_SID are not allowed.
#
#
""")

        for i in sorted(database_info.keys()):
            fp.write(database_info[i] + "\n")


if __name__ == "__main__":
    main()







    
