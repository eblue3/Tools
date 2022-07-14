YELLOW='\033[1;93m'
GREEN='\033[1;92m'
RED='\033[1;91m'
RESETCOLOR='\033[0m'
# Disk checking
echo -e $GREEN"Listing Disk Usage of /home (Large > Small):"$RESETCOLOR
du -h $olduserhome -d 1 | sort -h
echo -e $GREEN"Listing Total Disk Allocation:"$RESETCOLOR
df -h | grep Filesystem
df -h | grep sd
# ------------------------------------------------------------------------------
olddisk=$(du $olderuserhome -d 0 | sort -rh | awk '{print $1;}')
echo -e "Usage of $olduserhome:$GREEN $olddisk bytes"
if df -l | grep sd | grep /home; then
  alldisk=$(df -l | grep sd | grep /home | awk '{print $4;}')
  echo -e "Usage of /home:$GREEN $alldisk bytes"$RESETCOLOR
else
  alldisk=$(df -l | grep sd | sort -k6 | head -1 | awk '{print $4;}')
  echo -e "Usage of /:$GREEN $alldisk bytes"$RESETCOLOR
fi

remaindisk=$(echo $alldisk-$olddisk | bc)
echo -e "Remain Disk:$GREEN $remaindisk bytes"$RESETCOLOR
remaindiskGB=$(echo $remaindisk/1024/1024 | bc)
echo -e "Convert to GB:$GREEN $remaindiskGB GB"$RESETCOLOR
echo -e "Needed disk:$GREEN $(echo $olddisk/1024/1024 | bc) GB +$RED 10 GB reserved"$RESETCOLOR
remaindisk2=$(echo "($alldisk-$olddisk*2)" | bc)
remaindisk2GB=$(echo $remaindisk2/1024/1024 | bc)
if [ "$remaindiskGB" -gt "10" ]; then
    echo -e $GREEN"There is enough disk to copy.$RESETCOLOR
Continue action: Full Copy automatically"
else
    echo -e $RED"There is not enough disk to copy.$RESETCOLOR
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
--------------------------------------------------------------------------------"$RESETCOLOR
# Change older user path:
olduserhome=$olduserhome/.
echo -e $YELLOW"= = = = = = = = = = = = = = = = = = = = = = = =
=             Begin Copying Profile           =
= = = = = = = = = = = = = = = = = = = = = = = ="$RESETCOLOR
echo -e $GREEN"Copy Current User data to New User Data:$RESETCOLOR
Please standby ..."
cp -R -a $olduserhome $newuserhome
echo -e $GREEN"Change owner of files on New User Home Directory"$RESETCOLOR
groupadd $newuser
usermod -aG $newuser $newuser
chown -R $newuser:$newuser $newuserhome
echo -e $GREEN"Done."$RESETCOLOR
echo -e $YELLOW"Cleaning folder ..."$RESETCOLOR
rm ./linux-ad.sh
rm ./run.sh
echo -e $GREEN"Log is written to join-log.txt"$RESETCOLOR
echo -e $YELLOW"
= = = = = = = = = = = = = = = = = = = = = = = =
=                     DONE                    =
= = = = = = = = = = = = = = = = = = = = = = = ="$RESETCOLOR
# ------------------------------------------------------------------------------
