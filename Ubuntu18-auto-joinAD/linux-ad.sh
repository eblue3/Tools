#/bin/bash

# Install Kerberos first. And input the required Domain for Kerberos.
echo "= = = = = = = = = = = = = = = = = = = = = = = =
=              Begin Initializing             =
= = = = = = = = = = = = = = = = = = = = = = = =
= = = = = = = = = = = = = = = = = = = = = = = =
=         Configure Resolvconf Service        =
= = = = = = = = = = = = = = = = = = = = = = = ="
apt-get -y install resolvconf dnsutils
read -p "Nameserver1: " nameserver1
read -p "Nameserver2: " nameserver2
echo "Nameserver: $nameserver1 + $nameserver2"
# Append /etc/resolv.conf
echo "Configure /etc/resolv.conf :"
echo "nameserver  $nameserver1
nameserver  $nameserver2" >> /etc/resolv.conf
cat /etc/resolv.conf
echo "Create /etc/resolvconf/resolv.conf.d/head :"
# Create /etc/resolvconf/resolv.conf.d/head
echo "nameserver  $nameserver1
nameserver  $nameserver2" >> /etc/resolvconf/resolv.conf.d/head
cat /etc/resolvconf/resolv.conf.d/head
echo "Restart and Enable resolvconf Service:"
service resolvconf restart
systemctl enable resolvconf.service
echo "
Done."
sleep 2

echo "
---Installing Kerberos..."
cd /tmp
apt-get install -y krb5-user
apt-get -o Dpkg::Options::="--force-confmiss" install --reinstall krb5.conf
krb5path=$(find /etc/ -name "krb5.conf" | grep krb5.conf)
# Get the required domain name.
domainname=$(grep -m 1 "default_realm" $krb5path | cut -d "=" -f2- | cut -d " " -f2-)
domainnamecap=$(echo $domainname | tr [:lower:] [:upper:])
joinname="join@$domainnamecap"
hostname=$(cat /etc/hostname)
echo "
Done."
sleep 2

# Print all the Information collected.
echo "
= = = = = = = = = = = = = = = = = = = = = = = =
=                 INFORMATION                 =
= = = = = = = = = = = = = = = = = = = = = = = ="
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
sleep 2

# Install all required package for all next steps.
echo "
= = = = = = = = = = = = = = = = = = = = = = = =
=         Installing Required Packages        =
= = = = = = = = = = = = = = = = = = = = = = = ="
apt-get -y install samba samba-common packagekit samba-common-bin samba-libs adcli
systemctl unmask samba-ad-dc
service start smbd
service start nmbd
apt-get -y install ntp sed sssd sssd-tools realmd
echo "
Done."
sleep 2

# Begin configuring.
echo "---Done Initializing...

---Begin Configuring Step...
= = = = = = = = = = = = = = = = = = = = = = = =
=         Checking Domain Connections         =
= = = = = = = = = = = = = = = = = = = = = = = ="
echo "nslookup:"
echo $domainname | nslookup
echo "Test Connection:"
dig -t SRV _ldap._tcp.$domainname | grep -A2 "ANSWER SECTION"
echo "
Done."
sleep 2

echo "
= = = = = = = = = = = = = = = = = = = = = = = =
=            Configure NTP Service            =
= = = = = = = = = = = = = = = = = = = = = = = ="
sed -i "s/#pool/pool/g" /etc/ntp.conf
sed -i "s/pool/#pool/g" /etc/ntp.conf
echo "DC-AD01.ntq-solution.com.vn
DC-AD02.ntq-solution.com.vn" >> /etc/ntp.conf
echo "NTP configure:"
cat /etc/ntp.conf
service ntp restart
systemctl enable ntp
echo "
Done."
sleep 2

echo "
= = = = = = = = = = = = = = = = = = = = = = = =
=            Configure Realmd.conf            =
= = = = = = = = = = = = = = = = = = = = = = = ="
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
echo "Realmd config:"
cat /etc/realmd.conf
echo "
Done."
sleep 2

echo "
= = = = = = = = = = = = = = = = = = = = = = = =
=             Configure sssd.conf             =
= = = = = = = = = = = = = = = = = = = = = = = ="
echo "[sssd]
domains = ntq-solution.com.vn
config_file_version = 2
services = nss, pam

[domain/ntq-solution.com.vn]
ad_domain = ntq-solution.com.vn
krb5_realm = NTQ-SOLUTION.COM.VN
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
echo "
Done."
sleep 2

echo "Adding session option to /etc/pam.d/common-session."
echo "session required pam_unix.so
> session optional pam_winbind.so
> session optional pam_sss.so
> session optional pam_systemd.so
> session required pam_mkhomedir.so skel=/etc/skel/ umask=0077" >> /etc/pam.d/common-session
sleep 1
echo "OK"
sleep 2

# Begin joining Domain.
echo "---Done Configuring...

---Beginning Join Domain Step...
= = = = = = = = = = = = = = = = = = = = = = = =
=                 Join Domain                 =
= = = = = = = = = = = = = = = = = = = = = = = ="
kinit $joinname
realm --verbose join $domainname --user-principal=$hostname/$joinname --unattended

service sssd restart

echo "
---Checking if user \"join\" is domain user or not..."
id join

echo "Add user \"join\" to group: adm, sudo, cdrom, plugdev, lpadmin, sambashare, dip"
usermod -aG adm join
usermod -aG sudo join
usermod -aG cdrom join
usermod -aG plugdev join
usermod -aG lpadmin join
usermod -aG sambashare join
usermod -aG dip join
