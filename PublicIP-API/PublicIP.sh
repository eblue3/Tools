NewIP=`curl https://api.ipify.org`
echo "{\"PublicIP\": \"$NewIP\"}" > /root/Atom/API/PublicIP/PublicIPsh.txt
curl -i -H "Content-Type: application/json" -X PUT -d "@/root/Atom/API/PublicIP/PublicIPsh.txt" http://www.hipt.vn:3500/api/devices/3
