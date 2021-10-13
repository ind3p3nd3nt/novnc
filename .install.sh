#!/bin/bash
myip=$(hostname -I | awk '{print $1}')
randstr=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c10)
randpass=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c6)
function EPHEMERAL_PORT() {
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
apt update && apt install xfce4 tightvncserver -y;
cp /etc/apt/sources.list /root/sources.list.bak -r;
echo deb http://kali.download/kali kali-rolling main contrib non-free >/etc/apt/sources.list;
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys ED444FF07D8D0BF6;
apt update && apt install -y novnc;
cp /root/sources.list.bak /etc/apt/sources.list -r;
else yum groupinstall xfce -y && yum install tigervnc-server novnc -y;
fi;
mkdir -p ~/.vnc;
echo $randpass | vncpasswd -f
echo xfce4-session >~/.vnc/xstartup;
vncserver :55 -localhost;
if [ -f /usr/bin/apt ]; then /usr/share/novnc/utils/launch.sh --listen $randport --vnc localhost:5955 & fi;
if [ -f /usr/bin/yum ]; then novnc_server --listen $randport --vnc localhost:5955 --web /usr/share/novnc & fi;
echo "http://${myip}:${randport}/vnc.html pass: $randpass"
