#!/bin/bash
# require sudo bash and sudo

cd /opt/ || return
git clone https://github.com/ry4nzhu/Nextepc-Conf.git
git clone https://github.com/ry4nzhu/OpenairInterface-Scheduler.git enb_folder
git clone https://gitlab.eurecom.fr/oai/openairinterface5g/ ue_folder
cd ue_folder || return
git checkout -f v1.0.0
cd ..

sudo chown -R "$(whoami)" ./enb_folder/
sudo chown -R "$(whoami)" ./ue_folder/

#edit ue_folder/openair3/NAS/TOOLS/ue_eurecom_test_sfr.conf

sudo ifconfig lo: 127.0.0.2 netmask 255.0.0.0 up

cp /opt/Nextepc-Conf/ue_eurecom_test_sfr.conf /opt/ue_folder/openair3/NAS/TOOLS/
cp /opt/Nextepc-Conf/rcc.band7.tm1.nfapi.conf /opt/enb_folder/ci-scripts/conf_files/

#build enb
cd /opt/enb_folder/ &&
source oaienv
cd cmake_targets &&
./build_oai --eNB -t ETHERNET -c

#build ue
cd /opt/ue_folder &&
source oaienv &&
cd cmake_targets &&
./build_oai --UE -t ETHERNET -c

cd /opt/ue_folder/targets/bin/ &&
cp .u* ../../cmake_targets/ &&
cp usim ../../cmake_targets/ &&
cp nvram ../../cmake_targets/

cd /opt/ue_folder/cmake_targets/tools &&
source init_nas_s1 UE

cp /opt/Nextepc-Conf/run_enb.sh /opt/enb_folder/cmake_targets/
cp /opt/Nextepc-Conf/run_ue.sh /opt/ue_folder/cmake_targets/


myiface=$(ifconfig | grep -B1 10.10.1.1 | head -n1 | cut -d ':' -f1)
sed -i "s/ENB_INTERFACE_NAME_FOR_S1_MME            = \"enp6s0f1\"/ENB_INTERFACE_NAME_FOR_S1_MME            = \"$myiface\"/" /opt/enb_folder/ci-scripts/conf_files/rcc.band7.tm1.nfapi.conf
sed -i "s/ENB_INTERFACE_NAME_FOR_S1U               = \"enp6s0f1\";/ENB_INTERFACE_NAME_FOR_S1U               = \"$myiface\";/" /opt/enb_folder/ci-scripts/conf_files/rcc.band7.tm1.nfapi.conf

# configuration done

