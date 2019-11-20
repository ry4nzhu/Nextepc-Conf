#!/bin/bash
# sudo bash
# sudo apt-get remove -y --purge man-db

# require sudo bash
sudo apt-get update
sudo apt-get -y install mongodb
sudo systemctl start mongodb
export DEBIAN_FRONTEND=noninteractive
sudo apt-get -y install autoconf libtool gcc pkg-config \
         git flex bison libsctp-dev libgnutls28-dev libgcrypt-dev \
         libssl-dev libidn11-dev libmongoc-dev libbson-dev libyaml-dev

curl -sL https://deb.nodesource.com/setup_10.x
sudo apt-get -y install nodejs
cd /opt || exit
sudo git clone https://github.com/nextepc/nextepc
git clone https://github.com/ry4nzhu/Nextepc-Conf.git
cd nextepc
autoreconf -iv
./configure --prefix="$(pwd)"/install
make -j "$(nproc)"
make install
# exit
# cd /opt/nextepc/webui
# sudo npm install
# sudo bash
cat << EOF > /etc/systemd/network/98-nextepc.netdev
[NetDev]
Name=pgwtun
Kind=tun
EOF
# exit
sudo systemctl restart systemd-networkd
sudo ip addr add 192.168.0.1/24 dev pgwtun
sudo ip link set up dev pgwtun
sudo iptables -t nat -A POSTROUTING -o "$(cat /var/emulab/boot/controlif)" -j MASQUERADE
cp /opt/nextepc.conf /opt/nextepc/install/etc/nextepc

# edit conf files

# add subscriptors to the database
# mongoimport --db [name] --file [filename]
mongoimport --db nextepc --collection accounts /opt/hss_nextepc_account.json
mongoimport --db nextepc --collection sessions /opt/hss_nextepc_session.json
mongoimport --db nextepc --collection subscribers /opt/hss_nextepc_subscribers.json

# export mongodb database to csv file
# mongoexport --db [database name] --collection [collection name] --out [.json]

# sudo /opt/nextepc/install/bin/nextepc-epcd
