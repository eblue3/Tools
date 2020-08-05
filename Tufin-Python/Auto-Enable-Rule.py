import csv
import os
for file in os.listdir("."):
    if file.startswith("Device"):
        print(file)
        with open(file, newline='') as csvfile:
            spamreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
            for row in spamreader:
                if any("Core-" in a for a in row): #Get the first value row. Because it has "Core-" word.
                    valuematch = "".join(row[0])
                    valuematch = valuematch.replace('"','')
                    valuematch = valuematch.replace(',,,,',',')
                    valuematch = valuematch.replace(',,,',',')
                    valuematch = valuematch.replace(',,',',')
                    valuematch = valuematch.split(",")
                    newname = "Device " +valuematch[0]+ " From " +valuematch[3]+ " To " +valuematch[4]+ " with Rule No. " +valuematch[5]+ ".csv"
                    #result_file = open('enableDC.txt','a')
                    #result_file.write("set security policies from-zone " +valuematch[3]+ " to-zone " +valuematch[4]+ " policy " +valuematch[7]+ " then log session-init\n")
                    print("activate security policies from-zone " +valuematch[3]+ " to-zone " +valuematch[4]+ " policy " +valuematch[7])
            csvfile.close()
