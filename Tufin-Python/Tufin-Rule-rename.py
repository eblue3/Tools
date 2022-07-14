import csv
import os
for file in os.listdir("/media/Windows-Storage/Working-Folder/Self/Coding/Tufin/Shadowed Rule"):
    if file.startswith("SecureTrack"):
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
                    print(newname)
                    os.rename(file,newname)
                    break #Only take the first value row.
            csvfile.close()
