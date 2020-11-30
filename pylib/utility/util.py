import os
import re
import socket
import datetime
import subprocess
import xml.etree.ElementTree as ET

import smtplib
from validate_email import validate_email
from email.MIMEMultipart import MIMEMultipart
from email.MIMEBase import MIMEBase
from email.mime.text import MIMEText
from email import Encoders


class Util(object):

    @staticmethod
    def get_file_contents(filename):
        if os.path.isfile(filename):
            with open(filename) as fd:
                return fd.readlines()
        else:
            os.mknod(filename)
            return null


    @staticmethod
    def get_weekday():
        days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun']
        return days[datetime.datetime.today().weekday()]

    @staticmethod
    def get_month_number(month_name):
        month = { 'Jan':'01', 'Feb':'02', 'Mar':'03', 'Apr':'04', 'May':'05', 'Jun':'06',
                  'Jul':'07', 'Aug':'08', 'Sep':'09', 'Oct':'10', 'Nov':'11', 'Dec':'12'}
        return month.get(month_name)


    @staticmethod
    def is_process_running(current_file , process):
        s = subprocess.Popen(["ps","axw"],stdout=subprocess.PIPE)
        
        status = False 
        for x in s.stdout:
            if re.search(process,x):
                
                # Check if process is exists on any column of the splitted data
                if process in x.split() and current_file not in x.split():
                   return True
                else:
                   status = False
        return status 



class Monitor(object):
    STATUS_FILE="/tmp/.dbmonctl"
    ERROR = { "UNKNOWN":-1, "OK":0, "WARNING":1, "CRITICAL":2 }

    @staticmethod
    def is_monitor(database):
        status = {}
        file_contents = Util.get_file_contents(Monitor.STATUS_FILE)

        for line in file_contents:
            if line == "":
                continue
            (db,monitoring) = line.rstrip().split(":")
            status[db] = monitoring

        if status.get(database):
            return (status.get(database).upper() == 'YES')
        else:
            return True


class Mail(object):
    def __init__(self):
        tree = ET.parse('../../config/notification.xml')
        root = tree.getroot()
        
        self.notification = {}

        for child in root:
            if child.tag == 'group':
                for grandchild in child:
                    self.notification[grandchild.tag] = grandchild.text.split(',')
            else:
                self.notification[child.tag] = child.text
 
    def get_mailhost(self):
        return self.notification.get('mailhost')

    def get_mailfrom(self):
        #return self.notification.get('mailfrom')
        return socket.getfqdn()

    def get_mailto(self, mailto):
        return self.notification.get(mailto)

    def send(self, mailto, subject, contents, *attachments):
        msg = MIMEMultipart()
        msg['Subject'] = subject
        msg['From']    = self.get_mailfrom()

        if type(mailto) is list:
            msg['TO'] = ','.join(mailto)
        elif validate_email(mailto):
            msg['TO']  = mailto
        else:
            msg['To']  = ','.join(self.get_mailto(mailto))

        msg.attach(MIMEText(contents))

        for fname in attachments:
            part = MIMEBase('application', "octest-stream")
            part.set_payload(open(fname,"rb").read())
            Encoders.encode_base64(part)
            part.add_header('Content-Disposition','attachment; filename=' + os.path.basename(fname))
            #part.add_header('Content-Disposition','attachment; filename=' + fname)
            msg.attach(part)
        
        server = smtplib.SMTP(self.get_mailhost())
        if type(mailto) is list:
            server.sendmail(self.get_mailfrom(), mailto, msg.as_string())
        elif validate_email(mailto):
            server.sendmail(self.get_mailfrom(), mailto, msg.as_string())
        else:
            server.sendmail(self.get_mailfrom(), self.get_mailto(mailto), msg.as_string())
        server.quit()






 
