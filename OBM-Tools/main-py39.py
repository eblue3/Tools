#!/usr/bin/python3
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
__author__ = "Do Hoang Anh"
__credits__ = ["Do Hoang Anh", "Phan Hoang Viet"]
__version__ = "1.2"
__maintainer__ = "Do Hoang Anh"
__email__ = "anh-dh1@hipt.vn"
__status__ = "[WIP] Work In Progress"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

import json
from datetime import datetime, timedelta
import requests
import os
import re

print("START SESSION.")
# ---------- S E T U P ---------------------------------------------------------
# Set Time
now = datetime.now().strftime("%Y-%m-%d"+"T"+"%H:%M:%S.%f"+"+07:00")
curtime = datetime.strptime(now, "%Y-%m-%d"+"T"+"%H:%M:%S.%f"+"+07:00")
prevtime = datetime.strptime(now, "%Y-%m-%d"+"T"+"%H:%M:%S.%f"+"+07:00") - timedelta(minutes = 5)
print("Current Time: ",curtime)
print("5 Mins Before: ",prevtime)

# Create Variable:
EventDetail_URL = []
ACV = []
# ------------------------------------------------------------------------------

# ---------- F U N C T I O N 1 -------------------------------------------------
# Access to event_change_list URL:
EventChangeList_Url = "http://dc-obm.vpbank.com.vn/opr-web/rest/9.10/event_change_list?format=json"
username = "admin"          # SPECIFIC
password = "123456"         # SPECIFIC
resp = requests.get(EventChangeList_Url, auth=(username, password), verify=False)
os.remove("Event/event-change.json")
EventFile = open("Event/event-change.json",'a')
# Write data to event-change.json
for line in resp:
    EventFileData = line.decode('utf-8')
    EventFile.write(EventFileData)
EventFile.close()
# Get json data from event-change.json
with open("Event/event-change.json") as ecjson:
    data = json.load(ecjson)
    for keynum in range(len(data["event_change_list"]["event_change"])):
        EventTimestr = data["event_change_list"]["event_change"][keynum]["time_changed"]
        EventTime = datetime.strptime(EventTimestr, "%Y-%m-%d"+"T"+"%H:%M:%S.%f"+"+07:00")
        # Check Event Time is in range of (-5 mins, Now)
        if prevtime <= EventTime <= curtime:
            EventChange = data["event_change_list"]["event_change"][keynum]["changed_properties"]
            # Check if Annotation Value is exist in event_change
            if "annotation_property_change" in EventChange:
                # Grab Annotation Change Value (str):
                # ADD ANNOTATION VALUE *-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-*
                ACV.append(data["event_change_list"]["event_change"][keynum]["changed_properties"]["annotation_property_change"][0]["current_value"]["value"])
                # If OBM change the format to "no-list". Use below:
                # ACV.append(data["event_change_list"]["event_change"][keynum]["changed_properties"]["annotation_property_change"]["current_value"]["value"])

                # Take the target_href into EventDetail_URL variable
                EventDetail_URL.append(data["event_change_list"]["event_change"][keynum]["event_ref"]["target_href"]+"?format=json")
            else:
                pass
        else:
            pass
# ------------------------------------------------------------------------------

# ---------- F U N C T I O N 2 -------------------------------------------------
os.remove("Event/event-detail.json")
os.remove("Query/update-alert-msg.sql")
count = 0
# Access to target_href in event_ref
# The target_href already filled in EventDetail_URL[]
for target_href in EventDetail_URL:
    rep = requests.get(target_href, auth=(username, password), verify=False)
    EventDetail_file = open("Event/event-detail.json",'a')
    # Write data to Event/event-detail.json
    for line in rep:
        EventDetail_Data = line.decode('utf-8')
        EventDetail_file.write(EventDetail_Data)
    EventDetail_file.close()

    # Open Event/event-detail.json to read the alertObjectID
    with open("Event/event-detail.json") as edjson:
        data = json.load(edjson)
        data = data["event"]["title"]
        # Get alertObjectID
        data = re.sub("\n", '*', data).rstrip()
        flawdata = data.split(".1.3.6.1.4.1.11307.10.1 (OctetString): ")[1]
        alertObjectID = flawdata.split("AlertObjectID: ")[1].split(" *")[0] # alertObjectID *+-+-+-+-+-+-+-*

    # Create Query
    dataAPI = "[[{}], \"{}\"]".format(alertObjectID, ACV[count])
    # Write Query to Query/update-alert-msg.sql
    Query_file = open("Query/update-alert-msg.sql",'a')
    Query_file.write(dataAPI+"\n")
    Query_file.close()
    count+=1

    # Delete current event-detail.json file so we can continue on next object
    os.remove("Event/event-detail.json")
# ------------------------------------------------------------------------------

# ---------- F U N C T I O N 3 -------------------------------------------------
slwAPI_url = "https://dc-orion.vpbank.com.vn:17778/SolarWinds/InformationService/v3/Json/Invoke/Orion.AlertActive/AppendNote"    # Change 10.36.22.14 to Hostname?
slwUser = "admin"
slwPass = "123456a@"
# Send Query to Solarwinds API
with open("Query/update-alert-msg.sql") as slwquery:
    writelog = open("./query.log".'a')
    writelog.write("START SESSION.\n")
    writelog.write("Run Time: ", curtime, "\n")
    for dataAPI in slwquery:
        x = requests.post(slwAPI_url, auth=(slwUser, slwPass), json=dataAPI, verify=False)
        writelog.write("API Data (alertObjectID + Annotation):", dataAPI, "\n")
        writelog.write(x, ":", x.reason, "\n")

    writelog.write("END SESSION.\n\n")
    writelog.close()
# ------------------------------------------------------------------------------
print("END SESSION.")
