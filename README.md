# NordVPN wrapper

It connects to recommended server in given country.

Based on tutorial: https://nordvpn.com/tutorials/linux/openvpn/
and code from: https://github.com/Joentje/nordvpn-proxy.

The most complete NordVPN API documentation:
https://blog.sleeplessbeastie.eu/2019/02/18/how-to-use-public-nordvpn-api/.

## Usage

    nordvpn-wrapper.sh country

If country is not given, default country is "NL".

## Alternative usage

If for some reason connection to automatically selected server is not desired, server number can be specified as the second argument:

    nordvpn-wrapper.sh country serverNumber

E.g.

    nordvpn-wrapper.sh nl 934

## Configuration

Create ``${HOME}/.config/nordvpn-auth.txt`` with two lines.
First line is user name, second is password.

## Dependency list

- wc
- wget
- unzip
- jq
- sudo
- openvpn

## Installation

    echo -e 'USERNAME@gmail.com\nPASSWORD' > "${HOME}/.config/nordvpn-auth.txt"

    git clone "https://github.com/gdmn/nordvpn-wrapper.git"
    cd nordvpn-wrapper
    sudo ln -s "$(pwd)/nordvpn-wrapper.sh" /usr/local/bin/

    sudo true && nordvpn-wrapper.sh

## One-liner

    curl -s 'https://raw.githubusercontent.com/gdmn/nordvpn-wrapper/master/nordvpn-wrapper.sh' -o /tmp/nordvpn-wrapper.sh && bash /tmp/nordvpn-wrapper.sh

## Connection guard (optional)

The script runs nordvpn-wrapper.sh and guards openvpn connection.
If openvpn process is not present or ping fails, connection is restarted.

	curl -s 'https://raw.githubusercontent.com/gdmn/nordvpn-wrapper/master/nordvpn-guard.sh' -o /tmp/nordvpn-guard.sh && sudo bash /tmp/nordvpn-guard.sh

