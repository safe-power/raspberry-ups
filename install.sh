#!/bin/bash
if [ “$(id -u)” != “0” ]; then
echo “This script must be run as root” 2>&1
exit 1
fi

cd /bin
cat > safe-power.py << EOF
#!/usr/bin/env python  
#script to shutdown the raspberry by safe-power raspberry UPS
#save this script as root under /bin/safe-power.py  
#add this script AS LAST LINE of root's crontab in the following way
#  @reboot /bin/safe-power.py & 
# important!! dont forget the "&"  in the end!!
#the script will be started in the background at reboot 
#and safe power will be operational
import RPi.GPIO as GPIO  
GPIO.setmode(GPIO.BCM)  
import os   
import time
# GPIO 11 = pin23 set up as input. It is pulled up to stop false signals  
GPIO.setup(11, GPIO.IN, pull_up_down=GPIO.PUD_UP)
# now the program will do nothing until the shutdown signal on pin 23   
# gets LOW.     
#During this waiting time, your raspberry is not 
#wasting resources by polling the pin
  
try:  
    GPIO.wait_for_edge(11, GPIO.FALLING)
 
# warn all logged users of the shutdown event
    os.system("wall shutdown by UPS")
#now the system will shut down
    os.system("sudo poweroff")  
#except if this script will be cancelled by the user explicitely
except KeyboardInterrupt:  
    GPIO.cleanup()       # clean up GPIO on CTRL+C exit  
    GPIO.cleanup()           # clean up GPIO on normal exit 
EOF
chmod +x /bin/safe-power.py 
 

line="@reboot /bin/safe-power.py & "
(crontab -l; echo "$line" ) | crontab -
