import csv
import os
with open("LogEmptyDC.csv", newline='') as csvfile:
    spamreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
    for row in spamreader:
        if any("DC-Core-FW" in a for a in row):
            valuematch = "".join(row[0])
            valuematch = valuematch.replace('"','')
            valuematch = valuematch.replace(',,,,',',')
            valuematch = valuematch.replace(',,,',',')
            valuematch = valuematch.replace(',,',',')
            valuematch = valuematch.split(",")
            result_file = open('DCLogEmp.txt','a')
            result_file.write("set security policies from-zone " +valuematch[3]+ " to-zone " +valuematch[4]+ " policy " +valuematch[7]+ " then log session-init\n")
            result_file.write("set security policies from-zone " +valuematch[3]+ " to-zone " +valuematch[4]+ " policy " +valuematch[7]+ " then log session-close\n")
with open("LogEmptyDR.csv", newline='') as csvfile:
    spamreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
    for row in spamreader:
        if any("DR-Core-Firewall" in a for a in row):
            valuematch = "".join(row[0])
            valuematch = valuematch.replace('"','')
            valuematch = valuematch.replace(',,,,',',')
            valuematch = valuematch.replace(',,,',',')
            valuematch = valuematch.replace(',,',',')
            valuematch = valuematch.split(",")
            result_file = open('DRLogEmp.txt','a')
            result_file.write("set security policies from-zone " +valuematch[3]+ " to-zone " +valuematch[4]+ " policy " +valuematch[7]+ " then log session-init\n")
            result_file.write("set security policies from-zone " +valuematch[3]+ " to-zone " +valuematch[4]+ " policy " +valuematch[7]+ " then log session-close\n")
