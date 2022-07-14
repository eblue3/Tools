#!/usr/bin/python3
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
# This is the Integration Tool between OBM HP & Solarwinds API
# Customer: Vietnam Prosperity Joint‑Stock Commercial Bank
# OS: Redhat Linux
# Language & Version: Python 3.6
# For higher version, please check out the github repository
# Default main folder: /home/pkhangtt4/Solarwinds/
# Run with /home/pkhangtt4/Solarwinds/slwAPI
# Default crontab interval run: 5 minutes
__author__ = "Do Hoang Anh"
__credits__ = ["Do Hoang Anh", "Phan Hoang Viet"]
__version__ = "1.6"
__maintainer__ = "Do Hoang Anh"
__email__ = "anh-dh1@hipt.vn"
__status__ = "Completed"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

import json
from datetime import datetime, timedelta
import requests
import os
from os import path
import re

# ---------- R E Q U E S T 4 F A S T E R C H E C K -----------------------------
EventChangeList_Url = "http://dc-obm.vpbank.com.vn/opr-web/rest/9.10/event_change_list?format=json"
username = "admin"
password = "Itom@itom1"
resp = requests.get(EventChangeList_Url, auth=(username, password), verify=False)
# ------------------------------------------------------------------------------

# ---------- R E Q U I R E M E N T S -------------------------------------------
if path.exists("./EventDetail-log") == True:
    pass
else:
    os.system("mkdir EventDetail-log")

if path.exists("./Query-log") == True:
    pass
else:
    os.system("mkdir Query-log")
# ------------------------------------------------------------------------------

print("[DEBUG] START SESSION.")
# ---------- S E T U P ---------------------------------------------------------
# Set Time
now = datetime.now().strftime("%Y-%m-%d"+"T"+"%H:%M:%S.%f"+"+07:00")
curtime = datetime.strptime(now, "%Y-%m-%d"+"T"+"%H:%M:%S.%f"+"+07:00")
filecurtime = datetime.strftime(curtime, "%Y-%m-%d_%H:%M:%S.%f")
prevtime = datetime.strptime(now, "%Y-%m-%d"+"T"+"%H:%M:%S.%f"+"+07:00") - timedelta(minutes = 5)
print("[DEBUG] Current Time: ",curtime)
print("[DEBUG] 5 Mins Before: ",prevtime)

# Create Variable:
EventDetail_URL = []
ACV = []
alertObjectID = []
# ------------------------------------------------------------------------------

# ---------- F U N C T I O N 1 -------------------------------------------------
os.system("mv event-change.json event-change-old.json")
os.system("touch event-change.json")

# Write data to event-change.json
EventFile = open("event-change.json",'a')
for line in resp:
    EventFileData = line.decode('utf-8')
    EventFile.write(EventFileData)
EventFile.close()

# Get json data from event-change.json
with open("event-change.json") as ecjson:
    data = json.loads("["+ecjson.read()+"]")
    for keynum in range(len(data[0]["event_change_list"]["event_change"])):
        EventTimestr = data[0]["event_change_list"]["event_change"][keynum]["time_changed"]
        EventTime = datetime.strptime(EventTimestr, "%Y-%m-%d"+"T"+"%H:%M:%S.%f"+"+07:00")

        # Check Event Time is in range of (-5 mins, Now)
        if prevtime <= EventTime <= curtime:
            EventChange = data[0]["event_change_list"]["event_change"][keynum]["changed_properties"]
            # Check if Annotation Value is exist in event_change

            if "annotation_property_change" in EventChange:
                # Grab Annotation Change Value (str):
                # ADD ANNOTATION VALUE *-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-*
                ACV.append("Annotation:"+data[0]["event_change_list"]["event_change"][keynum]["changed_properties"]["annotation_property_change"][0]["current_value"]["value"])
                # Take the target_href into EventDetail_URL variable
                EventDetail_URL.append(data[0]["event_change_list"]["event_change"][keynum]["event_ref"]["target_href"]+"?format=json")
            elif "group_property_change" in EventChange and "user_property_change" in EventChange:
                annodata = data[0]["event_change_list"]["event_change"][keynum]["changed_properties"]["group_property_change"][0]["current_group_name"]+":"+data[0]["event_change_list"]["event_change"][keynum]["changed_properties"]["user_property_change"][0]["current_user_display_label"]
                ACV.append(annodata)
                EventDetail_URL.append(data[0]["event_change_list"]["event_change"][keynum]["event_ref"]["target_href"]+"?format=json")
            elif "group_property_change" in EventChange:
                annodata = data[0]["event_change_list"]["event_change"][keynum]["changed_properties"]["group_property_change"][0]["current_group_name"]
                ACV.append(annodata)
                EventDetail_URL.append(data[0]["event_change_list"]["event_change"][keynum]["event_ref"]["target_href"]+"?format=json")
            elif "user_property_change" in EventChange:
                annodata = data[0]["event_change_list"]["event_change"][keynum]["changed_properties"]["user_property_change"][0]["current_user_display_label"]
                ACV.append(annodata)
                EventDetail_URL.append(data[0]["event_change_list"]["event_change"][keynum]["event_ref"]["target_href"]+"?format=json")
            else:
                pass
        else:
            pass

print("[DEBUG] Process Event-Change: Done")
# ------------------------------------------------------------------------------

# ---------- F U N C T I O N 2 -------------------------------------------------
count = 0
# Access to target_href in event_ref and get data
# The target_href already filled in EventDetail_URL[]
for target_href in EventDetail_URL:
    rep = requests.get(target_href, auth=(username, password), verify=False)
    # Create ./EventDetail-log/event-detail-[count]-@curtime.json
    EventDetail_filename = "./EventDetail-log/event-detail-"+str(count)+"-@"+str(filecurtime)+".json"
    crtfile = "touch "+EventDetail_filename
    os.system(crtfile)

    # Write data to ./EventDetail-log/event-detail.json
    EventDetail_file = open(EventDetail_filename,'a')
    for line in rep:
        EventDetail_Data = line.decode('utf-8')
        EventDetail_file.write(EventDetail_Data)
    EventDetail_file.close()

    # Open ./EventDetail-log/event-detail-[count]-@curtime.json to read the alertObjectID
    with open(EventDetail_filename) as edjson:
        data = json.loads("["+edjson.read()+"]")
        alertdata = data[0]["event"]["title"]
        # Get alertObjectID
        alertdata = re.sub("\n", '*', alertdata).rstrip()
        alertObjectID.append(alertdata.split("AlertObjectID: ")[1].split(" ")[0]) # alertObjectID

    # Create Query
    dataAPI = "[[{}], \"{}\"]".format(alertObjectID[count], ACV[count])
    Query_filename = "./Query-log/update-alert-msg-@"+str(filecurtime)+".sql"
    crtfile = "touch "+Query_filename
    os.system(crtfile)
    # Write Query to ./Query-log/update-alert-msg.sql
    Query_file = open(Query_filename,'a')
    Query_file.write(dataAPI+"\n")
    Query_file.close()
    count+=1

print("[DEBUG] Process Event-Detail: Done")
# ------------------------------------------------------------------------------

# ---------- F U N C T I O N 3 -------------------------------------------------
slwAPI_url = "https://dc-orion.vpbank.com.vn:17778/Solarwinds/InformationService/v3/Json/Invoke/Orion.AlertActive/AppendNote"
slwUser = "admin"
slwPass = "123456a@"

# Send Query to Solarwinds API & Logging
writelog = open("./Query-log/query.log",'a')
writelog.write("START SESSION.\n")
writelog.write("Run Time: {}\n".format(curtime))
for i in range(count-1, -1, -1):
    # PROCESS THE DATA json=[[alertObjectID], "ACV"]
    x = requests.post(slwAPI_url, auth=(slwUser, slwPass), json=[[int(alertObjectID[i])], ACV[i]], verify=False)
    dataAPI = "[[{}], \"{}\"]".format(alertObjectID[i], ACV[i])
    writelog.write("API Data (alertObjectID + Annotation): {}\n".format(dataAPI))
    writelog.write("{} {} \n".format(x, x.reason))

writelog.write("END SESSION.\n\n")
writelog.close()
print("[DEBUG] Logging: Done.")
# ------------------------------------------------------------------------------
print("[DEBUG] END SESSION.")
