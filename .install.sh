#!/bin/bash
myip=$(hostname -I | awk '{print $1}')
randstr=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c10)
randpass=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c6)
XSTARTUP=$(echo '-xstartup xfce4-session')
LOCALHOST=$(echo '-localhost')
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
XSTARTUP=$(echo '-x xfce4-session')
apt update && apt install xfce4 net-tools dbus-x11 xorg tightvncserver expect novnc -y;
else yum groupinstall xfce -y && yum install tigervnc-server expect novnc -y; fi;
vncserver -kill :55
rm -rf /tmp/.X*
if [ ! -f ~/.vnc/passwd ]; then
rm -rf ~/.secret
/usr/bin/expect <<EOF
spawn /usr/bin/vncserver :55 $LOCALHOST -geometry 1920x1080 $XSTARTUP 
expect "Password:"
send "$randpass\r"
expect "Verify:"
send "$randpass\r"
expect "Would you like to enter a view-only password (y/n)?"
send "n\r"
expect eof
EOF
fi
rm -rf /tmp/.X*
vncserver :55 $LOCALHOST -geometry 1920x1080 $XSTARTUP
if [ -f /usr/bin/apt ]; then /usr/share/novnc/utils/launch.sh --listen $randport --vnc localhost:5955 & fi;
if [ -f /usr/bin/yum ]; then novnc_server --listen $randport --vnc localhost:5955 --web /usr/share/novnc & fi;
if [ ! -f ~/.secret ]; then echo "You can now go to http://${myip}:${randport}/vnc.html password: $randpass" >~/.secret ; fi;
DISPLAY=:55 xfce4-session &
sleep 5
cat ~/.secret
