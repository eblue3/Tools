# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
# Module of Optimization Tool for Tufin
# OS: Windows
# Language & Version: Python 3.9.2
__author__ = "Do Hoang Anh"
__credits__ = ["Do Hoang Anh"]
__maintainer__ = "Do Hoang Anh"
__email__ = "blue3.do@gmail.com"
__status__ = "Completed"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

# Library & Modules Import------------------------------------------------------
import requests
import urllib3
urllib3.disable_warnings()
import xml.etree.ElementTree as ET
# ------------------------------------------------------------------------------

# Main Function ----------------------------------------------------------------
def ExportLastModified(TufinIP, userpassencoded, deviceID, deviceName, curtime):
    daysreq = int(input("Input Days ago to export (Ex: 7 = 1 week, 30 = 1 month/30 days ago): "))
    ruledesc = "Request: Last modified to {} days ago on {}".format(daysreq, curtime)
    daysChange = daysreq
    testDate = ""
    # Access the deviceID
    for x in deviceID:
        print("[D] Device ID:", x, "------------------")
        # List all rules by Devices ID
        url = "https://{}/securetrack/api/devices/{}/rules".format(TufinIP, x)
        headers = {
            'Authorization': "Basic %s" %userpassencoded
            }
        response = requests.get(url, headers=headers, verify=False)
        tree = ET.fromstring(response.content)
        print("[D] Successfully get rules, working on optimization...\n------------------")
        # Get Rule Documentation
        for child in tree:
            for y in child:
                if y.tag == "id":
                    url = "https://{}/securetrack/api/devices/{}/rules/{}/documentation".format(TufinIP, x, y.text)
                    headers = {
                        'Authorization': "Basic %s" %userpassencoded
                        }
                    response = requests.get(url, headers=headers, verify=False)
                    tree = ET.fromstring(response.content)
                    # Check last_modified field
                    for z in tree:
                        if z.tag == "last_modified":
                            testDate = z.text
                            if testDate == "Yesterday":
                                testDate == 1
                            elif testDate == "Today":
                                testDate == 0
                            else:
                                testDate = testDate.split(" ", 1)[0]
                                daysChange = int(testDate) - daysChange
                        if daysChange <= 0:
                            payload = "<rule_documentation>\n  <comment>{}</comment>\n</rule_documentation>".format(ruledesc)   # Rule Description
                            headers = {
                                'Content-Type': "application/xml",
                                'Authorization': "Basic %s" %userpassencoded
                                }
                            # Add Rule Description
                            response = requests.put(url, data=payload, headers=headers, verify=False)
                            print("+[D] RuleID:",y.text, "-",z.text ,"\t// Status Code:", response.status_code)
                            daysChange = daysreq

    # Export with Specific Description in all Device
    url = "https://{}/securetrack/api/rule_search/export?search_text=ruledescription:{}".format(TufinIP, ruledesc)
    headers = {
        'Authorization': "Basic %s" %userpassencoded
        }
    print("[D] Done Optimization.\n[D] Exporting!")
    response = requests.get(url, headers=headers, verify=False)
    print("[D] Done.\n[D] Please check your Tufin Report Repository [Dashboard > Report > Reports Repository].\n")
    out = input("Press any key: Clear output & Exit to menu.")
# ------------------------------------------------------------------------------
