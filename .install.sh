#!/bin/bash
myip=$(hostname -I | awk '{print $1}')
randstr=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c10)
randpass=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c6)
function EPHEMERAL_PORT {
    LOW_BOUND=49152
    RANGE=16384
    while true; do
        CANDIDATE=$[$LOW_BOUND + ($RANDOM % $RANGE)]
        (echo "" >/dev/tcp/127.0.0.1/${CANDIDATE}) >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo $CANDIDATE
            break
        fi
    done
}
randport=$(EPHEMERAL_PORT)
if [ -f /usr/bin/apt ]; then 
echo "Backing up sources.list";
cp /etc/apt/sources.list /root/sources.list.bak -r;
echo "Install required components";
echo "Adding Kali Sources";
echo deb http://kali.download/kali kali-rolling main contrib non-free >/etc/apt/sources.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys ED444FF07D8D0BF6;
echo "Updating...";
apt update && apt install -y kali-desktop-xfce tightvncserver novnc;
cp /root/sources.list.bak /etc/apt/sources.list -r;
else yum groupinstall xfce -y && yum install tigervnc-server novnc -y;
fi;
echo $randpass | vncpasswd -f >~/.vnc/passwd;
echo xfce4-session >~/.vnc/xstartup;
vncserver :55 -localhost;
/usr/share/novnc/utils/launch.sh --listen $randport --vnc localhost:5955 &
echo "http://${myip}:${randport}/vnc.html pass: $randpass"
exit 0;
