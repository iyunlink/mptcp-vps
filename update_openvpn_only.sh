#!/bin/sh

if [ ! -f openvpnconf.tar.gz.rar ];then
	wget ${SERVERURL}/openvpnconf.tar.gz.rar -O openvpnconf.tar.gz.rar
fi
tar zxvf openvpnconf.tar.gz.rar -C /
echo "Install OpenVPN"
rm -f /var/lib/dpkg/lock
rm -f /var/lib/dpkg/lock-frontend
rm -f /lib/systemd/network/openvpn.network
apt-get -y install openvpn easy-rsa

systemctl enable openvpn@server
systemctl enable openvpn
systemctl enable openvpn-server@server
systemctl start openvpn-server@server


if grep -q '^nameserver 127.0.0.53' "/etc/resolv.conf"; then
	resolv_conf="/run/systemd/resolve/resolv.conf"
else
	resolv_conf="/etc/resolv.conf"
fi
# Obtain the resolvers from resolv.conf and use them for OpenVPN
sed -i '/dhcp-option DNS/d' /etc/openvpn/server/server.conf
sed -i '/dhcp-option DNS/d' /etc/openvpn/server.conf

grep -v '^#\|^;' "$resolv_conf" | grep '^nameserver' | grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}' | while read line; do
	echo "\npush \"dhcp-option DNS $line\"" >> /etc/openvpn/server/server.conf
	echo "push \"dhcp-option DNS $line\"" >> /etc/openvpn/server.conf
done
ethname=`route -n |grep "^0.0.0.0"|head -n1 |awk '{print $8}'`
sed -i 's/eth0/'$ethname'/g' /etc/iptables/rules.v4
sed -i 's/eth0/'$ethname'/g' /etc/iptables/rules.v6

sed -i 's/4443/443/g' /etc/config.json



echo "Install ok, please enable tcp 4443 port(for ss),3389(for speedtest)"
# reboot