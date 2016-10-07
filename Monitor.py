from pyspark.sql import SparkSession
from pyspark import SparkContext

import threading
import time

class Monitor():
    def __init__(self, context):
        self.context = context
        self.statusTracker = self.context.statusTracker()

    def job_is_running(self, jobID):
        return jobID in self.statusTracker.getActiveJobsIds()

    def get_completed_tasks(self, jobID):
        return self.statusTracker.getStageInfo(0)[5]

    def get_num_tasks(self, jobID):
        return self.statusTracker.getStageInfo(0)[3]

    def get_completion(self, jobID):
        return self.get_completed_tasks(jobID)/float(self.get_num_tasks(jobID))

class MonitoringThread(threading.Thread):
    def __init__(self, threadID, name, context, logger):
        threading.Thread.__init__(self)
        self.threadID = threadID
        self.name = name
        self.monitor = Monitor(context)
        self.log = logger

    def run(self):
        # Wait for job to start
        while not self.monitor.job_is_running(0):
            time.sleep(1)

        # Monitor until job finishes
        while self.monitor.job_is_running(0):
            time.sleep(1)
            self.log.log(str(time.time()) + "," + str(self.monitor.get_completion(0)))

