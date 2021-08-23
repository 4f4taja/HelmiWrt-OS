#!/bin/bash
#=================================================
# File name: init-settings.sh
# Description: This script will be executed during the first boot
# Author: SuLingGG
# Blog: https://mlapp.cn
#=================================================

# Disable autostart by default for some packages
rm -f /etc/rc.d/S98udptools || true
rm -f /etc/rc.d/S99dockerd || true
rm -f /etc/rc.d/S99dockerman || true
rm -f /etc/rc.d/S30stubby || true
rm -f /etc/rc.d/S90stunnel || true


#-----------------------------------------------------------------------------
#   Start of @helmiau additionals menu
#-----------------------------------------------------------------------------

# Set default theme to luci-theme-argon
uci set luci.main.mediaurlbase='/luci-static/argon'
uci commit luci

# Set Argon theme to light on first boot
uci set argon.@global[0].mode='light'

# Set hostname to HelmiWrt
uci set system.@system[0].hostname='HelmiWrt'

# Set Timezone to Asia/Jakarta
uci set system.@system[0].timezone='WIB-7'
uci set system.@system[0].zonename='Asia/Jakarta'
uci commit system

# Add shadowsocksr shortcut
chmod +x /bin/ssr-rst
chmod +x /bin/ssr-start
chmod +x /bin/ssr-stop

# Added neofetch on oh-my-zsh
echo "neofetch" > /root/.oh-my-zsh/custom/example.zsh
chmod +x /bin/neofetch
./bin/neofetch #run neofetch

# Vmess creator shortcut
chmod +x /bin/vmess

# Add ram checker from wegare123
# run "ram" using terminal to check ram usage
chmod +x /bin/ram

# Add fix download file.php for xderm and libernet
# run "fixphp" using terminal for use
chmod +x /bin/fixphp

# Add IP Address Info Checker
# run "myip" using terminal for use
chmod +x /bin/myip

# Add Samba Allowed Guest Setup
# run "sambaset" using terminal to set it up
chmod +x /bin/sambaset

# Add refresh IP Address for QMI Modems, such as LT4220
# Script by Rudi Hartono https://www.facebook.com/rud18
chmod +x /bin/ipqmi

# Fix luci-app-atinout-mod by 4IceG
chmod +x /usr/bin/luci-app-atinout

# Fix for xderm mini gui if trojan is not installed
ln -sf /usr/sbin/trojan /usr/bin/trojan

# Add language changer to auto !
chmod +x /bin/changelang
changelang
/bin/changelang
sh changelang
sh /bin/changelang
sed -i 's#exit 0#chmod +x /bin/changelang#g' /etc/rc.local
echo 'changelang' >> /etc/rc.local
echo '/bin/changelang' >> /etc/rc.local
echo 'sh changelang' >> /etc/rc.local
echo 'sh /bin/changelang' >> /etc/rc.local
echo 'exit 0' >> /etc/rc.local

# QMI modem reconnect interface without reboot /lib/netifd/proto/qmi.sh
# source docs.google.com/document/d/10ldzikC9EdvXT43LEtct0qSwi5qWJk-LHFZFsl8_69E
if [ -f /lib/netifd/proto/qmi.sh ];then
	if [[ $(grep -c helmiau /lib/netifd/proto/qmi.sh) = "2" ]];then
		echo "  helmilog : qmi.sh file already patched. Skipping..."		
	else
		echo "  helmilog : qmi.sh file available, patching..."
		sed -i 's$local uninitialized_timeout=0$local uninitialized_timeout=0\n#------ Patched by Helmi Amirudin a.k.a helmiau------\n		helmiau1\n		helmiau2\n		helmiau3\n#------ Patched by Helmi Amirudin a.k.a helmiau ------$g' /lib/netifd/proto/qmi.sh
		sed -i 's#helmiau1#uqmi -s -d "$ device" --get-pin-status \&#g' /lib/netifd/proto/qmi.sh
		sed -i 's#helmiau2#sleep 3#g' /lib/netifd/proto/qmi.sh
		sed -i 's#helmiau3#killall uqmi || echo "UQMI works fine!"#g' /lib/netifd/proto/qmi.sh
		echo "  helmilog : patching qmi.sh done..."
	fi
else
	echo "  helmilog : qmi.sh file is not available. Skipping..."
fi

# Patch english language for luci-app-fileassistant
chmod +x /bin/patch-fileassistant
patch-fileassistant

# Skip confirmation screen when start speedtest
if [ ! -d /root/.config/ookla ]; then
  mkdir -p /root/.config/ookla;
fi
cat << 'EOF' > /root/.config/ookla/speedtest-cli.json
{
    "Settings": {
        "LicenseAccepted": "604ec27f828456331ebf441826292c49276bd3c1bee1a2f65a6452f505c4061c"
    }
}
EOF

# Add reboot, poweroff, shutdown, shadowsocksr++ restart/stop, mwan3 restart to LuCI -> System -> Custom Command
if [ ! -f /etc/config/luci ]; then
  cat "\n\n" > /etc/config/luci;
fi
cat << "EOF" >> /etc/config/luci

config command
	option name 'Shutdown'
	option command 'halt'

config command
	option name 'Power Off'
	option command 'poweroff'

config command
	option name 'Reboot'
	option command 'reboot'

config command
	option name 'ShadowsocksR Restart'
	option command '/etc/init.d/shadowsocksr restart'

config command
	option name 'ShadowsocksR Stop'
	option command '/etc/init.d/shadowsocksr stop'

config command
	option name 'Restart Load Balance'
	option command 'mwan3 restart'

EOF

# Add my Load Balance settings
chmod +x /bin/helmilb
#helmilb


# LuCI -> System -> Terminal (a.k.a) luci-app-ttyd without login
cat << "EOF" > /etc/config/ttyd

config ttyd
	option interface '@lan'
	option command '/bin/login -f root'

EOF

# Add clashcs script : OpenClash Core switcher
chmod +x /bin/clashcs

# Add helmiwrt script : lists of command lines provided by helmiau.com
chmod +x /bin/helmiwrt

# Add USB Hilink Interface by default
# Add my Load Balance network interfaces to default network config
if [[ $(grep -c 'ueth1' /etc/config/network) = "0" ]];then
	echo "  helmilb_log : network config file available, patching..."
	cat << "EOF" >> /etc/config/network


config interface 'l2tp'
	option proto 'l2tp'
	option auto '0'
	option ipv6 'auto'

config interface 'qmi'
	option proto 'qmi'
	option device '/dev/cdc-wdm0'
	option auth 'none'
	option apn 'home'

config interface 'vpn'
	option proto 'none'
	option ifname 'tun0'

config interface 'libernet'
	option proto 'none'
	option ifname 'tun1'

config interface 'xderm'
	option proto 'none'
	option ifname 'tun2'

config interface 'ueth1'
	option proto 'dhcp'
	option ifname 'eth1'
	option metric '10'

config interface 'wwan'
	option proto 'dhcp'
	option metric '50'

EOF
	echo "  helmilb_log : patching network for my loadbalance settings is done..."
else
	echo "  helmilb_log : network config file already patched. Skipping..."
fi

# Add my Load Balance network interfaces to firewall
if [[ $(grep -c 'fweth1\|wan' /etc/config/firewall) = "0" ]];then
	echo "  helmilb_log : firewall config file available, patching..."
	cat << "EOF" >> /etc/config/firewall


config zone
	option name 'libernet'
	option masq '1'
	option mtu_fix '1'
	option input 'REJECT'
	option forward 'REJECT'
	option output 'ACCEPT'
	option network 'libernet'

config forwarding
	option src 'lan'
	option dest 'libernet'

config zone
	option output 'ACCEPT'
	option name 'xderm'
	option input 'REJECT'
	option forward 'REJECT'
	option masq '1'
	option mtu_fix '1'
	option network 'xderm'

config forwarding
	option dest 'xderm'
	option src 'lan'

config zone
	option name 'fweth1'
	option forward 'REJECT'
	option output 'ACCEPT'
	option network 'ueth1'
	option input 'REJECT'
	option masq '1'
	option mtu_fix '1'

config forwarding
	option dest 'fweth1'
	option src 'lan'

config forwarding
	option dest 'wan'
	option src 'lan'

EOF
	sed -i 's#wan wan6#wan wan6 qmi#g' /etc/config/firewall
	echo "  helmilb_log : patching firewall config file done..."
else
	echo "  helmilb_log : firewall config file already patched. Skipping..."
fi

#-----------------------------------------------------------------------------
#   Start of @helmiau additionals menu
#-----------------------------------------------------------------------------

exit 0
