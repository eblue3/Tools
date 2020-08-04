#/bin/bash

# Install Kerberos first. And input the required Domain for Kerberos.
echo "= = = = = = = = = = = = = = = = = = = = = = = =
=              Begin Initializing             =
= = = = = = = = = = = = = = = = = = = = = = = =
---Installing Kerberos..."
cd /tmp
apt-get -o Dpkg::Options::="--force-confmiss" install --reinstall krb5.conf
krb5path=$(find /etc/ -name "krb5.conf" | grep krb5.conf)
# Get the required domain name.
domainname=$(grep -m 1 "default_realm" $krb5path | cut -d "=" -f2- | cut -d " " -f2-)
domainnamecap=$(echo $domainname | tr [:lower:] [:upper:])
joinname="join@$domainnamecap"

# Print all the Information collected.
echo "
= = = = = = = = = = = = = = = = = = = = = = = =
=                 INFORMATION                 =
= = = = = = = = = = = = = = = = = = = = = = = ="
echo "Domain Name: $domainname
CAP Domain Name: $domainnamecap
Join Domain Name: $joinname"
osname=$(grep "PRETTY_NAME" /etc/os-release | cut -d "=" -f2-)
osnamereplace=$(echo os-name = ${osname:1:-1})
osversion=$(grep -m 1 "VERSION" /etc/os-release | cut -d "=" -f2-)
osversionreplace=$(echo os-version = ${osversion:1:-1})
ostype=$(uname -o)
echo "$osnamereplace
$osversionreplace
OS-type: $ostype"
nameserver1="10.0.64.2"
nameserver2="10.0.64.3"
echo "Nameserver: $nameserver1 + $nameserver2"

# Install all required package for all next steps.
echo "
= = = = = = = = = = = = = = = = = = = = = = = =
=         Installing Required Packages        =
= = = = = = = = = = = = = = = = = = = = = = = ="
apt-get -y install resolvconf realmd sssd sssd-tools samba-common krb5-user packagekit samba-common-bin samba-libs adcli ntp dnsutils sed

# Begin configuring.
echo "---Done Initializing...

---Begin Configuring Step...
= = = = = = = = = = = = = = = = = = = = = = = =
=         Configure Resolvconf Service        =
= = = = = = = = = = = = = = = = = = = = = = = ="
echo "Configure /etc/resolv.conf :"
echo "nameserver  $nameserver1
nameserver  $nameserver2" >> /etc/resolv.conf
cat /etc/resolv.conf
echo "Configure /etc/resolvconf/resolv.conf.d/head :"
echo "nameserver  $nameserver1
nameserver  $nameserver2" >> /etc/resolvconf/resolv.conf.d/head
cat /etc/resolvconf/resolv.conf.d/head
echo "Restart and Enable resolvconf Service:"
service resolvconf restart
systemctl enable resolvconf.service

echo "
= = = = = = = = = = = = = = = = = = = = = = = =
=         Checking Domain Connections         =
= = = = = = = = = = = = = = = = = = = = = = = ="
echo "nslookup:"
echo $domainname | nslookup
echo "Test Connection:"
dig -t SRV _ldap._tcp.$domainname | grep -A2 "ANSWER SECTION"

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
= = = = = = = = = = = = = = = = = = = = = = = =
=             Configure sssd.conf             =
= = = = = = = = = = = = = = = = = = = = = = = ="
sed -i "s/simple/ad/g" /etc/sssd/sssd.conf
sed -i "s/use_fully_qualified_names = True/use_fully_qualified_names = False/g" /etc/sssd/sssd.conf
echo "sssd config:"
cat /etc/sssd/sssd.conf
service sssd restart
systemctl enable sssd

echo "Adding session option to /etc/pam.d/common-session."
echo "session required pam_unix.so
> session optional pam_winbind.so
> session optional pam_sss.so
> session optional pam_systemd.so
> session required pam_mkhomedir.so skel=/etc/skel/ umask=0077" >> /etc/pam.d/common-session
echo "OK"

# Begin joining Domain.
echo "---Done Configuring...

---Beginning Join Domain Step...
= = = = = = = = = = = = = = = = = = = = = = = =
=                 Join Domain                 =
= = = = = = = = = = = = = = = = = = = = = = = ="
echo "12345a@" | kinit $joinname
realm --verbose join $domainname --user-principal=$hostname/$joinname --unattended

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
