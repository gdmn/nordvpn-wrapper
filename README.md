# NordVPN wrapper

It connects to recommended server in given country.

Based on tutorial: https://nordvpn.com/tutorials/linux/openvpn/
and code from: https://github.com/Joentje/nordvpn-proxy.

The most complete NordVPN API documentation:
https://blog.sleeplessbeastie.eu/2019/02/18/how-to-use-public-nordvpn-api/.

## Usage

    nordvpn-wrapper.sh country

If country is not given, default country is "NL".

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

