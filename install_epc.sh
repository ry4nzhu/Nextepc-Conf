#!/bin/bash
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
cd nextepc || return
autoreconf -iv
./configure --prefix="$(pwd)"/install
make -j "$(nproc)"
make install

cat << EOF > /etc/systemd/network/98-nextepc.netdev
[NetDev]
Name=pgwtun
Kind=tun
EOF

sudo systemctl restart systemd-networkd
sudo ip addr add 192.168.0.1/24 dev pgwtun
sudo ip link set up dev pgwtun
sudo iptables -t nat -A POSTROUTING -o "$(cat /var/emulab/boot/controlif)" -j MASQUERADE

# edit conf files
cp /opt/Nextepc-Conf/nextepc.conf /opt/nextepc/install/etc/nextepc

# add subscriptors to the database
# mongoimport --db [name] --collection [collectionname] --file [filename]
mongoimport --db nextepc --collection accounts /opt/Nextepc-Conf/hss_nextepc_account.json
mongoimport --db nextepc --collection sessions /opt/Nextepc-Conf/hss_nextepc_session.json
mongoimport --db nextepc --collection subscribers /opt/Nextepc-Conf/hss_nextepc_subscribers.json

# export mongodb database to csv file
# mongoexport --db [database name] --collection [collection name] --out [.json]

