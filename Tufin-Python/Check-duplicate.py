import os
for f in os.listdir('./Affected/'):
    if f.startswith("Device"):
        for file in os.listdir('./'):
            if file.startswith("Device"):
                if file == f:
                    os.remove(file)
                    print(file+" has been removed!")
