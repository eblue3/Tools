# Disk checking
echo -e $GREEN"Listing Disk Usage of /home (Large > Small):"
du -h $olduserhome -d 1 | sort -h
echo -e $GREEN"Listing Total Disk Allocation:"
df -h | grep Filesystem
df -h | grep sd
# ------------------------------------------------------------------------------
olddisk=$(du $olderuserhome -d 0 | sort -rh | awk '{print $1;}')
echo -e "Usage of $olduserhome:$GREEN $olddisk bytes"
if df -l | grep sd | grep /home; then
  alldisk=$(df -l | grep sd | grep /home | awk '{print $4;}')
  echo -e "Usage of /home:$GREEN $alldisk bytes"
else
  alldisk=$(df -l | grep sd | sort -k6 | head -1 | awk '{print $4;}')
  echo -e "Usage of /:$GREEN $alldisk bytes"
fi

remaindisk=$(echo $alldisk-$olddisk | bc)
echo -e "Remain Disk:$GREEN $remaindisk bytes"
remaindiskGB=$(echo $remaindisk/1024/1024 | bc)
echo -e "Convert to GB:$GREEN $remaindiskGB GB"
echo -e "Needed disk:$GREEN $(echo $olddisk/1024/1024 | bc) GB +$RED 10 GB reserved"
remaindisk2=$(echo "($alldisk-$olddisk*2)" | bc)
remaindisk2GB=$(echo $remaindisk2/1024/1024 | bc)
if [ "$remaindiskGB" -gt "10" ]; then
    echo -e $GREEN"There is enough disk to copy.
Continue action: Full Copy automatically"
else
    echo -e $RED"There is not enough disk to copy.
Recommend action:
1, Move automatically (Using ./movedata.sh)
2, Copy manually
Exited."
    exit
fi
# ------------------------------------------------------------------------------
echo -e $YELLOW"Note ---------------------------------------------------------------------------
To check all the Directory on a folder, run:
du - h /home/<user> -d 2 | sort -rh
You can increase/decrease -d <number> to see number of recursive folders.
--------------------------------------------------------------------------------"
# Change older user path:
olduserhome=$olduserhome/.
echo -e $YELLOW"= = = = = = = = = = = = = = = = = = = = = = = =
=             Begin Copying Profile           =
= = = = = = = = = = = = = = = = = = = = = = = ="
echo -e $GREEN"Copy Current User data to New User Data:
Please standby ..."
cp -R -a $olduserhome $newuserhome
echo -e $GREEN"Change owner of files on New User Home Directory"
groupadd $newuser
usermod -aG $newuser $newuser
chown -R $newuser:$newuser $newuserhome
echo -e $GREEN"Done."
echo -e $YELLOW"Cleaning folder ..."
rm ./linux-ad.sh
rm ./run.sh
echo -e $GREEN"Log is written to join-log.txt"
echo -e $YELLOW"
= = = = = = = = = = = = = = = = = = = = = = = =
=                     DONE                    =
= = = = = = = = = = = = = = = = = = = = = = = ="
# ------------------------------------------------------------------------------
