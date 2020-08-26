#!/bin/bash
# Fix Timezone error
# => hwclock --hctosys
echo "Checking 192.168.1.55 connection ..."
while ! ping -c6 192.168.1.55 &>/dev/null
        do echo "Fail to connect. Please check your DNS configuration. Checking again..."
done
echo "OK"

# Install Kerberos first. And input the required Domain for Kerberos.
echo "= = = = = = = = = = = = = = = = = = = = = = = =
=              Begin Initializing             =
= = = = = = = = = = = = = = = = = = = = = = = =
= = = = = = = = = = = = = = = = = = = = = = = =
=         Configure Resolvconf Service        =
= = = = = = = = = = = = = = = = = = = = = = = ="
sleep 1
echo "Installing packages: resolvconf, dnsutils
..."
apt-get -y install resolvconf dnsutils &>/dev/null
# Append /etc/resolv.conf
echo "Configure /etc/resolv.conf :"
echo "nameserver  192.168.1.55" > /etc/resolv.conf
cat /etc/resolv.conf
echo "Create /etc/resolvconf/resolv.conf.d/head :"
# Create /etc/resolvconf/resolv.conf.d/head
echo "nameserver  192.168.1.55" > /etc/resolvconf/resolv.conf.d/head
cat /etc/resolvconf/resolv.conf.d/head
echo "Restart and Enable resolvconf Service:"
service resolvconf restart
systemctl enable resolvconf.service
echo "
Done."

echo "
---Installing Kerberos..."
cd /tmp
apt-get install -y krb5-user
# apt-get -o Dpkg::Options::="--force-confmiss" install --reinstall krb5.conf
krb5path=$(find /etc/ -name "krb5.conf" | grep krb5.conf)
# Get the required domain name.
domainname=$(grep -m 1 "default_realm" $krb5path | cut -d "=" -f2- | cut -d " " -f2- | tr [:upper:] [:lower:])
domainnamecap=$(echo $domainname | tr [:lower:] [:upper:])
joinname="join@$domainnamecap"
hostname=$(cat /etc/hostname)
echo "
Done."

# Print all the Information collected.
echo "
= = = = = = = = = = = = = = = = = = = = = = = =
=                 INFORMATION                 =
= = = = = = = = = = = = = = = = = = = = = = = ="
sleep 2
echo "Domain Name: $domainname
CAP Domain Name: $domainnamecap
Join Domain Name: $joinname
Hostname: $hostname"
osname=$(grep "PRETTY_NAME" /etc/os-release | cut -d "=" -f2-)
osnamereplace=$(echo os-name = ${osname:1:-1})
osversion=$(grep -m 1 "VERSION" /etc/os-release | cut -d "=" -f2-)
osversionreplace=$(echo os-version = ${osversion:1:-1})
ostype=$(uname -o)
echo "$osnamereplace
$osversionreplace
OS-type: $ostype"
echo "
Done."

# Install all required package for all next steps.
echo "
= = = = = = = = = = = = = = = = = = = = = = = =
=         Installing Required Packages        =
= = = = = = = = = = = = = = = = = = = = = = = ="
sleep 1
echo "Install packages: samba, samba-common, packagekit, samba-common-bin, samba-libs, adcli
..."
apt-get -y install samba samba-common packagekit samba-common-bin samba-libs adcli &>/dev/null
systemctl unmask samba-ad-dc
systemctl start smbd
systemctl enable smbd
systemctl start nmbd
systemctl enable nmbd
echo "
Install packages: ntp, sed, sssd, sssd-tools, realmd"
apt-get -y install ntp sed sssd sssd-tools realmd &>/dev/null
echo "Done."

# Begin configuring.
echo "---Done Initializing...

---Begin Configuring Step...
= = = = = = = = = = = = = = = = = = = = = = = =
=         Checking Domain Connections         =
= = = = = = = = = = = = = = = = = = = = = = = ="
sleep 1
echo "Lookup with new DNS:"
echo $domainname | nslookup
sleep 1
echo "
Test Connection:"
dig -t SRV _ldap._tcp.$domainname | grep -A2 "ANSWER SECTION"
echo "Done."

echo "
= = = = = = = = = = = = = = = = = = = = = = = =
=            Configure NTP Service            =
= = = = = = = = = = = = = = = = = = = = = = = ="
sleep 1
sed -i "s/#pool/pool/g" /etc/ntp.conf
sed -i "s/pool/#pool/g" /etc/ntp.conf
echo "DC-AD01.ntq-solution.com.vn
DC-AD02.ntq-solution.com.vn" >> /etc/ntp.conf
sleep 1
echo "
NTP configure:"
cat /etc/ntp.conf
service ntp restart
systemctl enable ntp
echo "
Done."

echo "
= = = = = = = = = = = = = = = = = = = = = = = =
=            Configure Realmd.conf            =
= = = = = = = = = = = = = = = = = = = = = = = ="
sleep 1
echo "[users]
default-home = /home/%U
default-shell = /bin/bash
[active-directory]
default-client = sssd
$osnamereplace
$osversionreplace
[service]
automatic-install = no
[$domainname]
fully-qualified-names = no
automatic-id-mapping = yes
user-principal = yes
manage-system = no" > /etc/realmd.conf
sleep 1
echo "
Realmd config:"
cat /etc/realmd.conf
echo "
Done."

# Begin joining Domain.
echo "---Done Configuring...

---Beginning Join Domain Step...
= = = = = = = = = = = = = = = = = = = = = = = =
=                 Join Domain                 =
= = = = = = = = = = = = = = = = = = = = = = = ="
sleep 1
echo "123456a@" | kinit $joinname
realm --verbose join $domainname --user-principal=$hostname/$joinname --unattended

echo "
= = = = = = = = = = = = = = = = = = = = = = = =
=             Configure sssd.conf             =
= = = = = = = = = = = = = = = = = = = = = = = ="
sleep 1
echo "[sssd]
domains = $domainname
config_file_version = 2
services = nss, pam

[domain/ntq-solution.com.vn]
ad_domain = $domainname
krb5_realm = $domainnamecap
realmd_tags = joined-with-adcli
cache_credentials = True
id_provider = ad
krb5_store_password_if_offline = True
default_shell = /bin/bash
ldap_sasl_authid = $hostname
ldap_id_mapping = True
use_fully_qualified_names = False
fallback_homedir = /home/%u
simple_allow_users = \$
access_provider = ad" > /etc/sssd/sssd.conf
chmod 600 /etc/sssd/sssd.conf
#sed -i "s/simple/ad/g" /etc/sssd/sssd.conf
#sed -i "s/use_fully_qualified_names = True/use_fully_qualified_names = False/g" /etc/sssd/sssd.conf
#echo "sssd config:"
cat /etc/sssd/sssd.conf
service sssd restart
systemctl enable sssd
echo "
Done."

echo "
---Checking if user join is domain user or not..."
id join

echo "Adding session option to /etc/pam.d/common-session."
echo "session required pam_unix.so
session optional pam_winbind.so
session optional pam_sss.so
session optional pam_systemd.so
session required pam_mkhomedir.so skel=/etc/skel/ umask=0077" >> /etc/pam.d/common-session
sleep 1
echo "OK"
echo "Restart smbd & nmbd service:"
systemctl restart smbd
systemctl restart nmbd
echo "OK"
sleep 2

echo "
= = = = = = = = = = = = = = = = = = = = = = = =
=               Config New User               =
= = = = = = = = = = = = = = = = = = = = = = = ="
sleep 1
# List all user inside /home directory
echo "Listing all user in /home:"
cat /etc/passwd | grep "/home/" | cut -d ":" -f1 > userlist.txt
declare -i x=1
cat userlist.txt | while read lines
do
  echo "User [$x]: $lines"
  x=x+1
done

echo "Configure Timezone to Asia/Ho_Chi_Minh:"
timedatectl set-timezone Asia/Ho_Chi_Minh

echo "Input CAREFULLY your Current-Username and your New-Username.
The Tool will copies Current User Home to New User Home"
read -p "Your Current User: " olduser
olduserhome="/home/"$olduser
read -p "New Username: " newuser
newuserhome="/home/"$newuser

# Create new user home directory
echo "Create newuser home directory"
echo exit | su - $newuser

# Add New User to new Group
echo "Add Newuser to Current User Groups"
oldgroup=$(groups $olduser | cut -d ":" -f2 | tr " " ",")
oldgroup=${oldgroup#?}
usermod -aG $oldgroup $newuser

# Check
echo "Check if New User is on Current User's groups:"
cat /etc/group | grep $olduser
echo "Check User informations:
Current User: $olduser
Current User Home Directory: $olduserhome
`cd $olduserhome`
New User: $newuser
New User Home Directory: $newuserhome
`cd $newuserhome`"

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
