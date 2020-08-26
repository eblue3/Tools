#!/bin/bash
echo "Listing Disk Usage of /home (Large > Small):"
du -h /home -d 1 | sort -rn
echo "Listing Total Disk Allocation:"
df -h | grep Filesystem
df -h | grep sd
