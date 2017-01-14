import requests
import time

def getRunningApp(submission_url):
    try:
        all_app = requests.get(submission_url + '/api/v1/applications?status=running')
        for app in all_app.json():
            if app['attempts'][0]['completed'] == False:
                return app['id'],app['name']
            return None
    except:
        #print "No application found"
        return None

app = None
submission_url = 'http://192.168.122.94:4040'


for i in range(0,50):
    #print 'Attempt %s' % i
    application = getRunningApp(submission_url)
    if application is not None:
        app = application
        break
    time.sleep(5)

start_time = time.time()
#print "timestamp,progress"

if app is not None:
    app_id = app[0]
    all_progress = []
    while True:
        try:
            job_request = requests.get(submission_url+'/api/v1/applications/'+app_id+'/jobs')
            for result in job_request.json():
                output = time.strftime("%c") + ";" + app_id + ";" + app[1]+ ";"
                output += str(result['numCompletedTasks']/float(result['numTasks']))
                progress = str(result['numCompletedTasks']/float(result['numTasks']))
                stage = str(result['numCompletedStages'])
                print "%s,%s,%s" % (time.time() - start_time, progress, stage)
                time.sleep(1)
        except:
            #print "end"
            break
else:
    print "Application not found"
