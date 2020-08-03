import json
import csv

with open('INVENTORY.json', 'r') as myfile:
    #data = json.load(myfile) # Other way to Express
    data = json.loads(myfile.read())

csvf = csv.writer(open("INVENTORY.csv", "w"))

csvf.writerow(["| Owner",
                "| Project",
                "| CreationDate",
                "| CopyRights",
                "| License",
                "| Email",
                "| Status"])

csvf.writerow(["| ---",
               "| ---",
               "| ---",
               "| ---",
               "| ---",
               "| ---",
               "| ---",])

csvf.writerow(["| "+data['Owner'],
               "| "+data['Project'],
               "| "+data['CreationDate'],
               "| "+data['Copyrights'],
               "| "+data['License'],
               "| "+data['Email'],
               "| "+data['Status']])

csvf.writerow(["INVENTORY--- Device"])

csvf.writerow(["| No.",
                "| Name",
                "| Type",
                "| OS",
                "| Status",
                "| Location",
                "| ParentHost",
                "| LocalIP",
                "| Access: Web",
                "| Access: API",
                "| Access: SSH",
                "| Access: Remote", ])

csvf.writerow(["| ---",
               "| ---",
               "| ---",
               "| ---",
               "| ---",
               "| ---",
               "| ---",
               "| ---",
               "| ---",
               "| ---",
               "| ---",
               "| ---"])

NumD = 2    # Number of Devices in the List.
RowNum = NumD * 2
for a in range(RowNum):
    if a % 2 == 1:
        csvf.writerow(["| ---",
                    "| ---",
                    "| ---",
                    "| ---",
                    "| ---",
                    "| ---",
                    "| ---",
                    "| ---",
                    "| ---",
                    "| ---",
                    "| ---",
                    "| ---"])
    else:
        i = int(a / 2)
        csvf.writerow([i+1,
                        "| "+data['INVENTORY'][i]['Name'],
                        "| "+data['INVENTORY'][i]['Device']['Type'],
                        "| "+data['INVENTORY'][i]['Device']['OS'],
                        "| "+data['INVENTORY'][i]['Device']['Status'],
                        "| "+data['INVENTORY'][i]['Device']['Location'],
                        "| "+data['INVENTORY'][i]['Device']['ParentHost'],
                        "| "+data['INVENTORY'][i]['Device']['LocalIP'],
                        "| "+data['INVENTORY'][i]['Device']['PublicAccess']['Web'],
                        "| "+data['INVENTORY'][i]['Device']['PublicAccess']['API'],
                        "| "+data['INVENTORY'][i]['Device']['PublicAccess']['SSH'],
                        "| "+data['INVENTORY'][i]['Device']['PublicAccess']['RemoteAccess']])
