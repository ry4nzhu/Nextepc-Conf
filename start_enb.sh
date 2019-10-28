#!/bin/bash
sudo bash
cd /opt/
git clone https://gitlab.eurecom.fr/oai/openairinterface5g/ enb_folder
cd enb_folder
git checkout -f v1.0.0
cd ..
cp -Rf enb_folder ue_folder
sudo chown -R ryanzhu ./enb_folder/
sudo chown -R ryanzhu ./ue_folder/

#edit ue_folder/openair3/NAS/TOOLS/ue_eurecom_test_sfr.conf


sudo ifconfig lo: 127.0.0.2 netmask 255.0.0.0 up

#build enb
cd /opt/enb_folder/
source oaienv
cd cmake_targets
./build_oai --eNB -t ETHERNET -c

#build ue
cd /opt/ue_folder
source oaienv
cd cmake_targets
./build_oai --UE -t ETHERNET -c

cd /opt/ue_folder/targets/bin/
cp .u* ../../cmake_targets/
cp usim ../../cmake_targets/
cp nvram ../../cmake_targets/
cd /opt/ue_folder/cmake_targets/tools
source init_nas_s1 UE

cd /opt/enb_folder/cmake_targets
#start enb
sudo -E ./lte_build_oai/build/lte-softmodem -O ../ci-scripts/conf_files/rcc.band7.tm1.nfapi.conf > enb.log 2>&1 &

#start ue
cd /opt/ue_folder/cmake_targets
sudo -E ./lte_build_oai/build/lte-uesoftmodem -O ../ci-scripts/conf_files/ue.nfapi.conf --L2-emul 3 --num-ues 2 --nums_ue_thread 2 > ue.log 2>&1 &

