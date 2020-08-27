#!/bin/bash
echo "Listing Disk Usage of /home (Large > Small):"
du -h /home -d 1 | sort -rn
echo "Listing Total Disk Allocation:"
df -h | grep Filesystem
df -h | grep sd

echo "
To check all the Directory on a folder, run:
du - h /home/<user> -d 2 | sort -rn
You can increase -d <number> to see more recursive folders."

echo "
Done. Exited."
