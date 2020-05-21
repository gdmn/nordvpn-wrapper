#! /usr/bin/env bash

set -e

help() {
cat <<EOF
NordVPN wrapper. It connects to the fastest server in given country.

Based on tutorial: https://nordvpn.com/tutorials/linux/openvpn/
and code from: https://github.com/Joentje/nordvpn-proxy

Usage:
	`basename $0` country

If country is not given, default country is "nl".
EOF
}

fail() {
	echo $*
	echo "Run `basename $0` --help for help."
	exit 2
}

if [[ "$1" == '-h' || "$1" == '--help' ]]; then
	help
	exit 0
fi

command -v wc >/dev/null 2>&1  || { echo >&2 "wc is not installed."; exit 1; }
command -v wget >/dev/null 2>&1  || { echo >&2 "wget is not installed."; exit 1; }
command -v unzip >/dev/null 2>&1 || { echo >&2 "unzip is not installed."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo >&2 "jq is not installed."; exit 1; }
command -v openvpn >/dev/null 2>&1 || { echo >&2 "openvpn is not installed."; exit 1; }
command -v sudo >/dev/null 2>&1 || { echo >&2 "sudo is not installed."; exit 1; }

auth_file="${HOME}/.config/nordvpn-auth.txt"
if [ ! -f "$auth_file" ] || [[ $(wc -l "$auth_file") != "2 "* ]]; then
    fail "Please create ${auth_file} with two lines. First line is user name, second is password."
fi

if pidof openvpn > /dev/null 2>&1; then
    echo "WARNING: found running openvpn process"
    current_state="$(curl -s https://api.nordvpn.com/vpn/check/full)"
    if [[ $( echo "$current_state" | jq -r '.["status"]' ) = "Protected" ]] ; then
        current_host_ip=$( echo "$current_state" | jq -r '.["ip"]' )
        current_host_country=$( echo "$current_state" | jq -r '.["country"]' )
        current_host_country_code=$( echo "$current_state" | jq -r '.["code"]' )
        echo "You are currently connected to $current_host_ip in $current_host_country [$current_host_country_code]"
        exit 3
    fi
fi

ovpn_zip='/tmp/nordvpn-ovpn.zip'
if [ ! -f "$ovpn_zip" ]; then
    wget 'https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip' -O "$ovpn_zip"
fi

country="${1:-nl}"
countries='/tmp/nordvpn-countries.json'
if [ ! -f "$countries" ]; then
    wget 'https://nordvpn.com/wp-admin/admin-ajax.php?action=servers_countries' -O "$countries"
fi
country_code=$(cat $countries | jq '.[]  | select(.code == "'${country^^}'") | .id')
echo "Selected country: $country -> $country_code"

trecomendations=$(mktemp)
wget --quiet --header 'cache-control: no-cache' --output-document=$trecomendations 'https://nordvpn.com/wp-admin/admin-ajax.php?action=servers_recommendations&filters={%22country_id%22:'$country_code'}'
host_name="$(jq -r '.[0].hostname' $trecomendations)"
host_description="$(jq -r '.[0].name' $trecomendations)"
host_load="$(jq -r '.[0].load' $trecomendations)"
recommendation_updated_at="$(jq -r '.[0].updated_at' $trecomendations)"
host_ip="$(jq -r '.[0].station' $trecomendations)"
echo "Connecting to: $host_name $host_ip ($host_description)"
echo "               because at $recommendation_updated_at load was only ${host_load}%"
echo ''
rm "$trecomendations"

tdir=$(mktemp -d)
vpn_config=$(unzip -l "$ovpn_zip" "*tcp.ovpn" | sed -E 's/.* //g' | grep -E '.*/[a-z]+[0-9]+.*ovpn' | grep "$host_name" | sort -R | head -n 1)
echo "Extracting file: $vpn_config"
unzip -o "$ovpn_zip" "$vpn_config" -d "$tdir/"
echo "auth-user-pass $auth_file" >> "$tdir/$vpn_config"
echo ''

echo "Running openvpn $tdir/$vpn_config"

sudo openvpn "$tdir/$vpn_config"
