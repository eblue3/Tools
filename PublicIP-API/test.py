from flask import *
import requests
import datetime

gettime = datetime.datetime.now()
print(gettime)
AtomPiaddr = requests.get('https://api.ipify.org').text
print(AtomPiaddr)

# Link to Atom132
Atom132 = "http://hipt.vn:3592/???"  # ??? =

# My API Key
seckey = "XXXXXXXXXXXXXXXXX"

# Data sent to Atom132
POSTdata = {'API_Key': seckey,
            'RPi_Public_IP': AtomPiaddr,
            'Update_Time': gettime}

# Send POST request and saving response as "r" object
r = requests.post(url=Atom132, data=POSTdata)
rtext = r.text

# Extracting response text
print(rtext)
