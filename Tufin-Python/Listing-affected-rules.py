import csv
import os
import shutil

for file in os.listdir('./'):
    if file.startswith("Device"):
        print(file)
        with open(file,'rt') as f:
             reader = csv.reader(f, delimiter=',') # good point by @paco
             for row in reader:
                  for field in row:
                      with open('DClist.txt') as txt:
                          for line in txt:
                              addstr = line.split('\n',1)[0]
                              if field == addstr:
                                  shutil.copy('./'+file,'./Affected/'+file)
