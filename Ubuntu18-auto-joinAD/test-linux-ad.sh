#!/bin/bash
YELLOW='\033[1;93m'
GREEN='\033[1;92m'
RED='\033[1;91m'
RESETCOLOR='\033[0m'
echo -e $GREEN"Checking 192.168.1.55 connection ..."$RESETCOLOR
while ! ping -c4 192.168.1.55 &>/dev/null
        do echo -e $RED"Fail to connect. Please check your DNS configuration.
Exited."$RESETCOLOR; exit
done
echo -e $GREEN"OK"$RESETCOLOR
scriptpath=$(pwd)
# Install Kerberos first. And input the required Domain for Kerberos.
echo -e $YELLOW"= = = = = = = = = = = = = = = = = = = = = = = =
=              Begin Initializing             =
= = = = = = = = = = = = = = = = = = = = = = = =
= = = = = = = = = = = = = = = = = = = = = = = =
=         Configure Resolvconf Service        =
= = = = = = = = = = = = = = = = = = = = = = = ="$RESETCOLOR
sleep 1
echo -e $GREEN"Install packages: resolvconf, dnsutils
..."$RESETCOLOR
apt-get -y install resolvconf dnsutils tee &>/dev/null
# Append /etc/resolv.conf
echo -e $GREEN"Configure /etc/resolv.conf :"$RESETCOLOR
echo "nameserver  192.168.1.55" > /etc/resolv.conf
cat /etc/resolv.conf
echo -e $GREEN"Create /etc/resolvconf/resolv.conf.d/head :"$RESETCOLOR
# Create /etc/resolvconf/resolv.conf.d/head
echo "nameserver  192.168.1.55" > /etc/resolvconf/resolv.conf.d/head
cat /etc/resolvconf/resolv.conf.d/head
echo -e $GREEN"Restart and Enable resolvconf Service:"$RESETCOLOR
service resolvconf restart
systemctl enable resolvconf.service
echo -e $GREEN"
Done."$RESETCOLOR
# ------------------------------------------------------------------------------
echo -e $GREEN"
Checking if Kerberos is already installed:"$RESETCOLOR
if apt list --installed | grep -q "krb5-user\|krb5-admin-server\|krb5-kdc-ldap";
then
  echo -e $RED"Kerberos is already installed. Please check again before redo.
Exited."$RESETCOLOR
  exit
else
  echo -e $GREEN"Kerberos is not installed. Continue."$RESETCOLOR
fi
echo -e $GREEN"
---Installing Kerberos..."$RESETCOLOR
cd /tmp
apt-get install -y krb5-user
# apt-get -o Dpkg::Options::="--force-confmiss" install --reinstall krb5.conf
krb5path=$(find /etc/ -name "krb5.conf" | grep krb5.conf)
# Get the required domain name.
domainname=$(grep -m 1 "default_realm" $krb5path | cut -d "=" -f2- | cut -d " " -f2- | tr [:upper:] [:lower:])
domainnamecap=$(echo $domainname | tr [:lower:] [:upper:])
joinname="join@$domainnamecap"
hostname=$(cat /etc/hostname)
echo -e $GREEN"
Done."$RESETCOLOR
# ------------------------------------------------------------------------------
# Print all the Information collected.
echo -e $YELLOW"
= = = = = = = = = = = = = = = = = = = = = = = =
=                 INFORMATION                 =
= = = = = = = = = = = = = = = = = = = = = = = ="$RESETCOLOR
sleep 2
echo -e $GREEN"Domain Name: $domainname
CAP Domain Name: $domainnamecap
Join Domain Name: $joinname
Hostname: $hostname"$RESETCOLOR
osname=$(grep "PRETTY_NAME" /etc/os-release | cut -d "=" -f2-)
osnamereplace=$(echo os-name = ${osname:1:-1})
osversion=$(grep -m 1 "VERSION" /etc/os-release | cut -d "=" -f2-)
osversionreplace=$(echo os-version = ${osversion:1:-1})
ostype=$(uname -o)
echo -e $GREEN"$osnamereplace
$osversionreplace
OS-type: $ostype"$RESETCOLOR
echo -e $GREEN"
Done."$RESETCOLOR
# ------------------------------------------------------------------------------
# Install all required package for all next steps.
echo -e $YELLOW"
= = = = = = = = = = = = = = = = = = = = = = = =
=         Installing Required Packages        =
= = = = = = = = = = = = = = = = = = = = = = = ="$RESETCOLOR
sleep 1
echo -e $GREEN"Install packages: samba, samba-common, packagekit, samba-common-bin, samba-libs, adcli $RESETCOLOR
..."
apt-get -y install samba samba-common packagekit samba-common-bin samba-libs adcli &>/dev/null
systemctl unmask samba-ad-dc
systemctl start smbd
systemctl enable smbd
systemctl start nmbd
systemctl enable nmbd
echo -e $GREEN"
Install packages: ntp, sed, sssd, sssd-tools, realmd $RESETCOLOR
..."
apt-get -y install ntp sed sssd sssd-tools realmd &>/dev/null
echo -e $GREEN"Done."$RESETCOLOR
# ------------------------------------------------------------------------------
# Begin configuring.
echo -e $YELLOW"---Done Initializing...

---Begin Configuring Step...
= = = = = = = = = = = = = = = = = = = = = = = =
=         Checking Domain Connections         =
= = = = = = = = = = = = = = = = = = = = = = = ="$RESETCOLOR
sleep 1
echo -e $GREEN"Lookup with new DNS:"$RESETCOLOR
echo $domainname | nslookup
sleep 1
echo -e $GREEN"
Test Connection:"$RESETCOLOR
dig -t SRV _ldap._tcp.$domainname | grep -A2 "ANSWER SECTION"
echo -e $GREEN"Done."$RESETCOLOR
# ------------------------------------------------------------------------------
echo -e $YELLOW"
= = = = = = = = = = = = = = = = = = = = = = = =
=            Configure NTP Service            =
= = = = = = = = = = = = = = = = = = = = = = = ="$RESETCOLOR
sleep 1
sed -i "s/#pool/pool/g" /etc/ntp.conf
sed -i "s/pool/#pool/g" /etc/ntp.conf
echo "DC-AD01.ntq-solution.com.vn
DC-AD02.ntq-solution.com.vn" >> /etc/ntp.conf
sleep 1
echo -e $GREEN"
NTP configure:"$RESETCOLOR
cat /etc/ntp.conf | grep "ntq"
service ntp restart
systemctl enable ntp
echo -e $GREEN"
Done."$RESETCOLOR
# ------------------------------------------------------------------------------
echo -e $YELLOW"
= = = = = = = = = = = = = = = = = = = = = = = =
=            Configure Realmd.conf            =
= = = = = = = = = = = = = = = = = = = = = = = ="$RESETCOLOR
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
echo -e $GREEN"
Realmd config:"$RESETCOLOR
cat /etc/realmd.conf
echo -e $GREEN"
Done."$RESETCOLOR
# ------------------------------------------------------------------------------
# Begin joining Domain.
echo -e $YELLOW"---Done Configuring...

---Beginning Join Domain Step...
= = = = = = = = = = = = = = = = = = = = = = = =
=                 Join Domain                 =
= = = = = = = = = = = = = = = = = = = = = = = ="$RESETCOLOR
sleep 1
echo "123456a@" | kinit $joinname
realm --verbose join $domainname --user-principal=$hostname/$joinname --unattended

echo -e $YELLOW"
= = = = = = = = = = = = = = = = = = = = = = = =
=             Configure sssd.conf             =
= = = = = = = = = = = = = = = = = = = = = = = ="$RESETCOLOR
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
echo -e $GREEN"
Done."
# ------------------------------------------------------------------------------
echo -e $GREEN"
---Checking if user join is domain user or not..."$RESETCOLOR
if id join >/dev/null 2>&1; then
  echo -e $GREEN"Join Domain Successfully!"$RESETCOLOR
  id join
  sleep 5
else
  echo -e $RED"Join Domain: Failed.
Exiting..."$RESETCOLOR
  exit
fi
# ------------------------------------------------------------------------------
echo -e $GREEN"Adding session option to /etc/pam.d/common-session."$RESETCOLOR
echo "session required pam_unix.so
session optional pam_winbind.so
session optional pam_sss.so
session optional pam_systemd.so
session required pam_mkhomedir.so skel=/etc/skel/ umask=0077" >> /etc/pam.d/common-session
sleep 1
echo -e $GREEN"OK"$RESETCOLOR
echo -e $GREEN"Restart smbd & nmbd service:"$RESETCOLOR
systemctl restart smbd
systemctl restart nmbd
echo -e $GREEN"OK"$RESETCOLOR
sleep 2
# ------------------------------------------------------------------------------
echo -e $GREEN"Configure Timezone to Asia/Ho_Chi_Minh:"$RESETCOLOR
timedatectl set-timezone Asia/Ho_Chi_Minh
# ------------------------------------------------------------------------------
echo -e $YELLOW"
= = = = = = = = = = = = = = = = = = = = = = = =
=               Config New User               =
= = = = = = = = = = = = = = = = = = = = = = = ="$RESETCOLOR
sleep 1
# List all user inside /home directory
echo -e $GREEN"Listing all user in /home:"$RESETCOLOR
cat /etc/passwd | grep "/home/" | cut -d ":" -f1 > userlist.txt
declare -i x=1
cat userlist.txt | while read lines
do
  echo "User [$x]: $lines"
  x=x+1
done
# ------------------------------------------------------------------------------
echo -e $GREEN"Input CAREFULLY your Current-Username and your New-Username.
The Tool will copies Current User Home to New User Home"$RESETCOLOR
read -p "Your Current User: " olduser
olduserhome="/home/"$olduser
read -p "New Username: " newuser
# ------------------------------------------------------------------------------
# Check $newuser input is wrong or right
while :
do
  if id $newuser >/dev/null 2>&1; then
    echo -e $GREEN"User found on AD. Adding to system."$RESETCOLOR
    break
  else
    echo -e $RED"User is not found on AD. Please recheck the username again.
"$RESETCOLOR
    read -p "New Username: " newuser
  fi
done
newuserhome="/home/"$newuser
# ------------------------------------------------------------------------------
# Create new user home directory
echo -e $GREEN"Create newuser home directory"$RESETCOLOR
echo exit | su - $newuser
# ------------------------------------------------------------------------------
# Add New User to new Group
echo -e $GREEN"Add Newuser to Current User Groups"$RESETCOLOR
oldgroup=$(groups $olduser | cut -d ":" -f2 | tr " " ",")
oldgroup=${oldgroup#?}
usermod -aG $oldgroup $newuser
# ------------------------------------------------------------------------------
# Check
echo -e $GREEN"Check if New User is on Current User's groups:"$RESETCOLOR
cat /etc/group | grep $olduser
echo -e $GREEN"Check User informations:
Current User: $olduser
Current User Home Directory: $olduserhome
`cd $olduserhome`
New User: $newuser
New User Home Directory: $newuserhome
`cd $newuserhome`"$RESETCOLOR
# ------------------------------------------------------------------------------
cd $scriptpath
echo -e $GREEN"Download script to move profile."$RESETCOLOR
wget https://raw.githubusercontent.com/eblue3/Tools/master/Ubuntu18-auto-joinAD/copydata.sh -O copy.sh &>/dev/null
echo "#!/bin/bash
newuser=$newuser
olduser=$olduser
olduserhome=$olduserhome
newuserhome=$newuserhome
$(cat copy.sh)" > ./copydata.sh
chmod +x ./copydata.sh
rm copy.sh
wget https://raw.githubusercontent.com/eblue3/Tools/master/Ubuntu18-auto-joinAD/movedata.sh -O move.sh &>/dev/null
echo "#!/bin/bash
newuser=$newuser
olduser=$olduser
olduserhome=$olduserhome
newuserhome=$newuserhome
$(cat move.sh)" > ./movedata.sh
chmod +x ./movedata.sh
rm move.sh

echo -e $GREEN"Install required packages."$RESETCOLOR
apt-get install -y head bc &>/dev/null
echo -e $GREEN"copydata.sh is downloaded in current folder. Please proceed to moving data from $olduser to $newuser by running ./copydata.sh"$RESETCOLOR
echo -e $YELLOW"

= = = = = = = = = = = = = = = = = = = = = = = =
=                     END                     =
= = = = = = = = = = = = = = = = = = = = = = = ="$RESETCOLOR
# ------------------------------------------------------------------------------
