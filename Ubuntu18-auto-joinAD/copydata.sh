# Copy
# Change older user path:
olduserhome=$olduserhome/.
echo "Copy Current User data to New User Data:
Please standby ..."
cp -R -a $olduserhome $newuserhome
echo "Change owner of files on New User Home Directory"
groupadd $newuser
usermod -aG $newuser $newuser
chown -R $newuser:$newuser $newuserhome
echo "Done."

echo "
= = = = = = = = = = = = = = = = = = = = = = = =
=                     END                     =
= = = = = = = = = = = = = = = = = = = = = = = ="
echo "Rebooting in 30s."
sleep 10
echo "Rebooting in 20s."
sleep 10
echo "Rebooting in 10s."
sleep 5
echo "Rebooting in 5s."
sleep 5
echo "Reboot!"
sleep 1
reboot
