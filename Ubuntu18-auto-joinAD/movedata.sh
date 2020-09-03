YELLOW='\033[1;93m'
GREEN='\033[1;92m'
RED='\033[1;91m'
RESETCOLOR='\033[0m'
# Change older user path:
olduserhome=$olduserhome/*
echo -e $YELLOW"= = = = = = = = = = = = = = = = = = = = = = = =
=             Begin Moving Profile            =
= = = = = = = = = = = = = = = = = = = = = = = ="$RESETCOLOR
echo -e $GREEN"Move Current User data to New User Data:$RESETCOLOR
Please standby ..."
shopt -s dotglob nullglob
mv $olduserhome $newuserhome
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
