##Python script for correcting date.
##Called by z.sh to check or correct date values.





import os
import sys
import time
from gps import *

print 'Set System Clock to GPS UTC time'

try:
  gpsd = gps(mode=WATCH_ENABLE)
except:
  print 'GPS connection Error'
  sys.exit()

while True:
  gpsd.next()
  if gpsd.utc != None and gpsd.utc != '':
    gpsutc = gpsd.utc[0:4] + gpsd.utc[5:7] + gpsd.utc[8:10] + ' ' + gpsd.utc[11:19]
    os.system('sudo date -u --set="%s"' % gpsutc)
    sys.exit() 
 