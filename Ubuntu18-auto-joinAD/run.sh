#!/bin/bash
YELLOW='\033[1;93m'
GREEN='\033[1;92m'
RED='\033[1;91m'
RESETCOLOR='\033[0m'
cu=$(whoami)
scriptpath=$(pwd)
if [ ! $cu = "root" ];then
	echo -e $RED"Please run as root!
$RESETCOLOR Run command: sudo -i
$RESETCOLOR Run the script again at: $scriptpath/run.sh"
  exit
else
	echo -e $GREEN"Current User: root
Proceed to next step..."$RESETCOLOR
fi

echo -e $GREEN"Checking Internet connection ..."$RESETCOLOR
while ! ping -c4 8.8.8.8 &>/dev/null
        do echo -e $RED"Fail to connect. Please check your Internet connection.\
Exited."$RESETCOLOR; exit
done

echo -e $GREEN"Download & Run Join AD script."$RESETCOLOR
wget https://raw.githubusercontent.com/eblue3/Tools/master/Ubuntu18-auto-joinAD/linux-ad.sh -O linux-ad.sh &>/dev/null
chmod +x linux-ad.sh
./linux-ad.sh | tee -a join-log.txt
