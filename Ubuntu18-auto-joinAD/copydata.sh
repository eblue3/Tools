# Copy
# Change older user path:
olduserhome=$olduserhome/.
echo "= = = = = = = = = = = = = = = = = = = = = = = =
=             Begin Moving Profile            =
= = = = = = = = = = = = = = = = = = = = = = = ="
echo "Copy Current User data to New User Data:
Please standby ..."
cp -R -a $olduserhome $newuserhome
echo "Change owner of files on New User Home Directory"
groupadd $newuser
usermod -aG $newuser $newuser
chown -R $newuser:$newuser $newuserhome
echo "Done."
echo "Cleaning folder ..."
rm ./linux-ad.sh
rm ./run.sh
echo "Log is written to join-log.txt"
echo "
= = = = = = = = = = = = = = = = = = = = = = = =
=                     DONE                    =
= = = = = = = = = = = = = = = = = = = = = = = ="
