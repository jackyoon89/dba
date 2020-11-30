import os
import fcntl

class FileLock:
    def __init__(self, filename, lock_type):
        self.fh = open(filename, "a")
        self.lock_type = lock_type


    def __enter__(self):
        #print "Acquiring lock"
        fcntl.flock(self.fh.fileno(), self.lock_type)


    def __exit__(self, type, value, tb):
        #print "Releasing lock"
        fcntl.flock(self.fh.fileno(), fcntl.LOCK_UN)
        self.fh.close()
        os.remove(self.fh.name)

