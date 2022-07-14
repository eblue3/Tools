# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
# Optimization Tool for Tufin
# Customer: Vietnam Prosperity Joint‑Stock Commercial Bank
# OS: Windows
# Language & Version: Python 3.9.2
__author__ = "Do Hoang Anh"
__credits__ = ["Do Hoang Anh"]
__version__ = "1.1"
__maintainer__ = "Do Hoang Anh"
__email__ = "blue3.do@gmail.com"
__status__ = "In Progess"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

# Library & Modules Import------------------------------------------------------
import getpass
import os
import base64
from datetime import datetime
import requests
import urllib3
urllib3.disable_warnings()
import xml.etree.ElementTree as ET
# Custom Modules
import LastMod
import NoHit
import NoLog
import Shadowed
# ------------------------------------------------------------------------------

# Logging in Tufin -------------------------------------------------------------
print("Login to Tufin.\n- - - - - - - - - -")
TufinIP = input("Tufin IP Address: ")
# Check login with response
while True:
    # Username / Password
    username = input("Username: ")
    password = getpass.getpass('Password:')
    usrPass = "{}:{}".format(username, password).encode("utf-8")
    userpassencoded = base64.b64encode(usrPass).decode("utf-8")
    url = "https://{}/securetrack/api/devices/".format(TufinIP)
    headers = {
        'Authorization': "Basic %s" %userpassencoded
        }
    response = requests.get(url, headers=headers, verify=False)
    if response:
        now = datetime.now()
        curtime = now.strftime("%H:%M-%d-%m-%Y")
        os.system("clear")
        break
    else:
        os.system("clear")
        print("[!!!] Login Failed! Please input again.")
        pass
print("[D] Login Successfully!\n[D] Current Time: {}\n# Optimization Tool for Tufin\n# Customer: Vietnam Prosperity Joint‑Stock Commercial Bank\n# OS: Windows\n# Language & Version: Python 3.9.2".format(curtime))
curtime = now.strftime("%H%M_%d-%m-%Y")
# ------------------------------------------------------------------------------

# List all Device --------------------------------------------------------------
allDeviceID = []
allDeviceName = []
allDeviceType = []
deviceID = []
deviceName = []
deviceType = []
tree = ET.fromstring(response.content)
for child in tree:
    for x in child:
        if x.tag == "model":
            allDeviceType.append(x.text)        # Device Type
        elif x.tag == "id":
            allDeviceID.append(x.text)          # Device ID
        elif x.tag == "name":
            allDeviceName.append(x.text)        # Device Name
            # Check & Create directory for each Firewall
            if os.path.isdir(x.text):
                pass
            else:
                os.mkdir(x.text)
# ------------------------------------------------------------------------------

# Choose Device Function -------------------------------------------------------
def chooseDev(moduleText):
    global allDeviceID, allDeviceName, allDeviceType, deviceID, deviceName, deviceType
    errorDev = 0
    while True:
        print(moduleText)
        if deviceID == []:
            print("Choose Device to optimize:")
        else:
            print("Current chosen devices:")
            for a in deviceName:
                print("[+] {}".format(a))
            print("\nChoose Device to optimize:")
        for x in range(0, len(allDeviceID)):
            print("[{}]".format(x+1), allDeviceName[x],)
        print("[{}]".format(len(allDeviceID)+1), "Clear all.")
        print("[{}]".format(len(allDeviceID)+2), "Done.")
        if errorDev == 0:
            pass
        elif errorDev == 1:
            print("[!!!] Already chosen.")
            errorDev = 0
        elif errorDev == 2:
            print("[!!!] Wrong Input.")
            errorDev = 0
        else:
            pass
        choice = int(input("Your Choice: "))
        choice = choice-1
        if choice in range(0, len(allDeviceID)):
            if allDeviceID[choice] in deviceID:
                os.system("clear")
                errorDev = 1
            else:
                os.system("clear")
                deviceID.append(allDeviceID[choice])
                deviceName.append(allDeviceName[choice])
                deviceType.append(allDeviceType[choice])
        elif choice == (len(allDeviceID)):
            os.system("clear")
            deviceID.clear()
            deviceName.clear()
        elif choice == (len(allDeviceID)+1):
            break
        else:
            os.system("clear")
            errorDev = 2
    os.system("clear")
    print("\nDevice to Optimize:")
    for x in range(0, len(deviceID)):
        print("[+] Name: {}, DeviceID: {}, Model: {}".format(deviceName[x], deviceID[x], deviceType[x]))
# ------------------------------------------------------------------------------

# Main Program -----------------------------------------------------------------
errorOpt = 0
while True:
    os.system("clear")
    print("Main Menu")
    print("""Tufin Policy Optimization Options:
[1] Optimize Shadowed Rules [Not Supported yet].
[2] Optimize No Log Rules.
[3] Optimize No Hit Rules.
[4] Export Rules Created X Days ago.
[5] Exit.""")
    if errorOpt == 0:
        pass
    elif errorOpt == 1:
        print("[!!!] Wrong Input.")
        errorOpt = 0
    else:
        pass
    Options = int(input("Choose Option: "))
    if Options == 1:
        os.system("clear")
        print("============================\n= Optimize Shadowed Rules. [Not Supported yet] =\n============================\n")
        pass
        #moduleText = "============================\n= Optimize Shadowed Rules. [Not Supported yet] =\n============================\n"
        #chooseDev(moduleText)
    elif Options == 2:
        os.system("clear")
        moduleText = "==========================\n= Optimize No Log Rules. =\n==========================\n"
        chooseDev(moduleText)
        NoLog.OptimizeNoLog(TufinIP, userpassencoded, deviceID, deviceName, deviceType, curtime)
    elif Options == 3:
        os.system("clear")
        moduleText = "==========================\n= Optimize No Hit Rules. =\n==========================\n"
        chooseDev(moduleText)
        NoHit.OptimizeNoHit(TufinIP, userpassencoded, deviceID, deviceName, deviceType, curtime)
    elif Options == 4:
        os.system("clear")
        moduleText = "=========================\n= Export Request Rules. =\n=========================\n"
        chooseDev(moduleText)
        LastMod.ExportLastModified(TufinIP, userpassencoded, deviceID, curtime)
    elif Options == 5:
        break
    else:
        os.system("clear")
        errorOpt = 1
        pass

exit("All done.")
# ------------------------------------------------------------------------------
