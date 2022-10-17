#!/bin/sh

# if [ ! -f openvpnconf.tar.gz ];then
# 	wget https://gitee.com/link4all_admin/vps/raw/master/openvpnconf.tar.gz -O openvpnconf.tar.gz
# fi
# tar zxvf openvpnconf.tar.gz -C /

if curl -s cip.cc|grep "中国";then
git clone https://gitee.com/link4all_admin/vps.git
else
git clone https://github.com/hewenhao2008/vps.git
fi
cd vps
cp ./etc/ / -r
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

apt install libssl-dev -f
git clone https://gitee.com/link4all_admin/chipvpn.git
cd chipvpn
make
cp bin/chipvpn /usr/bin/tcpvpn
cp server.json /etc/
cd ../
rm -rf chipvpn
update-rc.d tcpvpn defaults
rm -rf ../vps



echo "Install ok, please allow tcp port 443/59999/60011/3389."
# reboot