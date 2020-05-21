# NordVPN wrapper

It connects to the fastest server in given country.

Based on tutorial: https://nordvpn.com/tutorials/linux/openvpn/
and code from: https://github.com/Joentje/nordvpn-proxy

# Usage

    nordvpn-wrapper.sh country

If country is not given, default country is "nl".

# Configuration

Create ``${HOME}/.config/nordvpn-auth.txt`` with two lines. 
First line is user name, second is password.

# Installation

    git clone "https://github.com/gdmn/nordvpn-wrapper.git"
    cd nordvpn-wrapper
    chmod +x nordvpn-wrapper.sh
    sudo ln -s "$(pwd)/nordvpn-wrapper.sh" /usr/local/bin/
    echo -e 'USERNAME@gmail.com\nPASSWORD' > "${HOME}/.config/nordvpn-auth.txt"
    
    sudo true; nordvpn-wrapper.sh

# One-liner

    curl -s 'https://raw.githubusercontent.com/gdmn/nordvpn-wrapper/master/nordvpn-wrapper.sh' -o /tmp/nordvpn-wrapper.sh && bash /tmp/nordvpn-wrapper.sh
