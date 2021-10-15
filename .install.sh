#!/bin/bash
myip=$(hostname -I | awk '{print $1}')
randstr=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c10)
randpass=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c6)
XSTARTUP=$(echo '-xstartup xfce4-session')
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
unset XSTARTUP
apt update && apt install xfce4 tightvncserver expect -y;
cp /etc/apt/sources.list /root/sources.list.bak -r;
echo deb http://kali.download/kali kali-rolling main contrib non-free >/etc/apt/sources.list;
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys ED444FF07D8D0BF6;
apt update && apt install -y novnc;
cp /root/sources.list.bak /etc/apt/sources.list -r;
else yum groupinstall xfce -y && yum install tigervnc-server expect novnc -y; fi;
if [ ! -f ~/.vnc/passwd ]; then
/usr/bin/expect <<EOF
spawn /usr/bin/vncserver :55 -localhost $XSTARTUP
expect "Password:"
send "$randpass\r"
expect "Verify:"
send "$randpass\r"
expect "Would you like to enter a view-only password (y/n)?"
send "n\r"
expect eof
EOF
else
vncserver :55 -localhost $XSTARTUP
fi
if [ -f /usr/bin/apt ]; then /usr/share/novnc/utils/launch.sh --listen $randport --vnc localhost:5955 & fi;
if [ -f /usr/bin/yum ]; then novnc_server --listen $randport --vnc localhost:5955 --web /usr/share/novnc & fi;
echo "You can now go to http://${myip}:${randport}/vnc.html password: $randpass" >~/.secret
DISPLAY=:55 xfce4-session &
sleep 4
cat ~/.secret
exit
