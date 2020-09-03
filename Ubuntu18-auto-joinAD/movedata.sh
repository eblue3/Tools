# Change older user path:
olduserhome=$olduserhome/*
echo -e $YELLOW"= = = = = = = = = = = = = = = = = = = = = = = =
=             Begin Moving Profile            =
= = = = = = = = = = = = = = = = = = = = = = = ="
echo -e $GREEN"Move Current User data to New User Data:
Please standby ..."
shopt -s dotglob nullglob
mv $olduserhome $newuserhome
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
