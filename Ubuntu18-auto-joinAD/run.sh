#!/bin/bash
cu=$(whoami)
scriptpath=$(pwd)
if [ ! $cu = "root" ];then
	echo "Please run as root!
Run command: sudo -i
Run the script again at: $scriptpath/run.sh"
  exit
else
	echo "Current User: root
Proceed to next step..."
fi

echo "Checking Internet connection ..."
while ! ping -c4 8.8.8.8 &>/dev/null
        do echo "Fail to connect. Please check your Internet connection. Checking again..."
done

echo "Download & Run Join AD script."
wget https://raw.githubusercontent.com/eblue3/Tools/master/Ubuntu18-auto-joinAD/linux-ad.sh -O linux-ad.sh &>/dev/null
chmod +x linux-ad.sh
./linux-ad.sh | tee -a join-log.txt
