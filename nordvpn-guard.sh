#! /usr/bin/env bash

# The script runs nordvpn-wrapper.sh and guards openvpn connection.
# If openvpn process is not present or ping fails, connection is restarted.

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit 1
fi

command -v screen >/dev/null 2>&1 || { echo >&2 "screen is not installed."; exit 1; }
command -v dig >/dev/null 2>&1 || { echo >&2 "dig (dnsutils) is not installed."; exit 1; }
command -v wc >/dev/null 2>&1  || { echo >&2 "wc is not installed."; exit 1; }
command -v wget >/dev/null 2>&1  || { echo >&2 "wget is not installed."; exit 1; }
command -v unzip >/dev/null 2>&1 || { echo >&2 "unzip is not installed."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo >&2 "jq is not installed."; exit 1; }
command -v openvpn >/dev/null 2>&1 || { echo >&2 "openvpn is not installed."; exit 1; }
command -v sudo >/dev/null 2>&1 || { echo >&2 "sudo is not installed."; exit 1; }

show_ip() {
	dig +short myip.opendns.com @resolver1.opendns.com
}

vpn_start() {
	echo 'VPN start'
	if (! pidof openvpn>/dev/null ); then
		screen -m -d -S nordvpn bash -c "d=/tmp/nordvpn-wrapper-r.sh; [ -e \$d ] || curl 'https://raw.githubusercontent.com/gdmn/nordvpn-wrapper/master/nordvpn-wrapper.sh' -o \$d; bash \$d NL; sleep 5"
		sleep 10
	else
		echo 'VPN process is already running'
	fi
}

vpn_stop() {
	echo 'VPN stop'
	while pidof openvpn; do
		for p in $( pidof openvpn ); do
			echo "kill openvpn process $p"
			kill $p
		done
		sleep 5
	done
}

vpn_restart() {
	vpn_stop
	vpn_start
}

vpn_check() {
	if (! pidof openvpn>/dev/null ); then
		echo "openvpn is not running"
		vpn_start
		sleep 20
	fi
	if (! ip a s tun0 up>/dev/null 2>&1); then
		echo "tun0 is not up"
		vpn_restart
		sleep 20
	fi
	if (! ping -W 1 -c 5 1.1.1.1 2>/dev/null 1>&2); then
		echo "ping failed"
		vpn_restart
		sleep 20
	fi
}

last_ip=`show_ip`
echo "IP: $last_ip"

vpn_start

while sleep 10; do
	current_ip=`show_ip`
	if [ "$last_ip" != "$current_ip" ]; then
		echo "New IP: $current_ip. Old: $last_ip"
		last_ip=$current_ip
	fi
	vpn_check
done
