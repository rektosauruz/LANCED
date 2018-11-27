#!/bin/bash
    #title          :installersuidrootLANCED.sh
    #description    :installer tool for LANCED
    #author         :rektosauruz
    #date           :20181127
    #version        :v0.1
    #usage          :./installersuidrootLANCED.sh
    #notes          :kismet stdout silenced, locales are set
    #bash_version   :4.4-5
    #============================================

#File Declarations
#/home/pi/zulfi_logs/                    [raw data files are saved here from kismet_server.]
#/home/pi/zulfi_arch/                    [files are transferred after each run to this location to be processed.]
#/home/pi/zulfi_arch/{date}/             [a dated folder is created for that day.]
#/home/pi/zulfi_arch/BSSID.list          [unique MACs are held here for counting and comparison for uniqueness.]
#/home/pi/zulfi_arch/datapool.txt        [datapool.txt holds the unique data, populated after each run, a simple database file holds raw data.]
#/home/pi/zulfi_arch/temp.list           [for each run MACs in the respective .nettxt file are passed to temp.list for comparison with BSSID.list]
#/home/pi/zulfi_arch_processed/          [processed files are saved here under the same respective dates.]
#/home/pi/zulfi_arch_processed/{date}/   [dated folders are directly transferred under prcessed section after the sequence.]
#/etc/kismet/timechk             [timechk file is created after the first date correction, at the end of each run, this file is removed.]

##For both GUI and CLI, automation script
##will automatically install and configure Zulfikar system to latest version.
##For debugging, an echo can be return if a spesific process is failed.


#Color Declerations
ESC="["
RESET=$ESC"39m"
RED=$ESC"31m"
GREEN=$ESC"32m"
LYELLOW=$ESC"36m"
YELLOW=$ESC"34m"
YELLOW=$ESC"33m"
RB=$ESC"48;5;160m"
RESET1=$ESC"0m"

##check for root
if [[ "${EUID}" -ne 0 ]]; then
  echo -e "${GREEN}run${RESET} ${RED}installer.sh${RESET} ${GREEN}with${RESET} ${RED}root !${RESET}"
  exit 1
fi

##fix locale
#if [ "`locale | tail -1`" == "LC_ALL=" ];then
#  export LC_ALL=C
#  sudo dpkg-reconfigure locales
#fi

####FIRST SECTION####
##initialization of required folders used by zulfikar.sh
sudo mkdir /home/pi/zulfi_logs
sudo mkdir /home/pi/zulfi_arch
sudo mkdir /home/pi/zulfi_arch/processed
sudo touch /home/pi/zulfi_arch/BSSID.list
sudo touch /home/pi/zulfi_arch/datapool.txt

sudo chmod 777 /home/pi/zulfi_logs
sudo chmod 777 /home/pi/zulfi_arch
sudo chmod 777 /home/pi/zulfi_arch/processed
sudo chmod 777 /home/pi/zulfi_arch/BSSID.list
sudo chmod 777 /home/pi/zulfi_arch/datapool.txt


#initialize v{1-20}
for i in `seq 1 23`;do
  c="`sed ""$i"q;d" /home/pi/zulfikar/ZVL-Dev/Zulfi_handler/dep.list`"
  eval "v${i}=${RED}[${c}]${RESET}"
done


###Loading bar indicates while download and initialization progress###
ledger () {
clear
cat <<-ENDOFMESSAGE
${RB}                                       ${RESET1}
	${RB} ${RESET1}$v21   $v22   $v23${RB} ${RESET1}
	${RB} ${RESET1}$v1   $v2     $v3${RB} ${RESET1}
	${RB} ${RESET1}$v4 $v16${RB} ${RESET1}
	${RB} ${RESET1}$v6  $v7   $v8${RB} ${RESET1}
	${RB} ${RESET1}$v9  $v10  $v13${RB} ${RESET1}
	${RB} ${RESET1}$v11$v12$v14  $v20${RB} ${RESET1}
	${RB} ${RESET1}$v15    $v5${RB} ${RESET1}
	${RB} ${RESET1}$v17   $v18  $v19${RB} ${RESET1}
${RB}                                       ${RESET1}
ENDOFMESSAGE

}

ledger

###using the dep.list, this iteration handles the apt-get update/upgrade/dist-upgrade
for i in `seq 21 23`; do
	a="`sed ""$i"q;d" /home/pi/zulfikar/ZVL-Dev/Zulfi_handler/dep.list`"
	sed ""$i"q;d" /home/pi/zulfikar/ZVL-Dev/Zulfi_handler/dep.list | xargs apt-get -y > /dev/null 2>&1 && eval "v${i}=${GREEN}[${a}]${RESET}" ||
	echo -e "$a" >> /home/pi/zulfikar/ZVL-Dev/Zulfi_handler/error.list
  ledger
done

###using the dep.list this iteration hadnles the apt-get install
echo -e "update - upgrade - dist-upgrade DONE" >> /home/pi/zulfikar/ZVL-Dev/Zulfi_handler/progress.list

for i in `seq 1 19`; do
 	a="`sed ""$i"q;d" /home/pi/zulfikar/ZVL-Dev/Zulfi_handler/dep.list`"
 	sed ""$i"q;d" /home/pi/zulfikar/ZVL-Dev/Zulfi_handler/dep.list | xargs apt-get install -y > /dev/null 2>&1 && eval "v${i}=${GREEN}[${a}]${RESET}" ||
 	echo -e "$a" >> /home/pi/zulfikar/ZVL-Dev/Zulfi_handler/error.list
  ledger
done

#echo -e "essential files DONE" >> /home/pi/zulfikar/ZVL-Dev/Zulfi_handler/progress.list

#sudo apt-get install locate
#sudo apt-get install libpcre3 libpcre3-dev
sudo wget https://www.kismetwireless.net/code/kismet-2016-07-R1.tar.xz > /dev/null 2>&1
sudo tar -xf kismet-2016-07-R1.tar.xz
cd kismet-2016-07-R1/

sudo ./configure > /dev/null 2>&1

sudo make dep > /dev/null 2>&1

sudo make > /dev/null 2>&1

sudo make suidinstall > /dev/null 2>&1

sudo usermod -a -G kismet pi

v20=${GREEN}[kismet]${RESET}
ledger



#echo -e "kismet DONE" >> /home/pi/zulfikar/ZVL-Dev/Zulfi_handler/progress.list

####SECOND SECTION####

##git folder
#/home/pi/zulfikar/ZVL-Dev/Zulfi_handler/
#/etc/kismet/
#/etc/kismet/kismet.conf
#/etc/kismet/oui2.txt
#/etc/kismet/correct_date.py


##/etc/kismet/ folder contained file operations are handled here
#sudo mv /usr/local/etc/kismet_drone.conf /usr/local/etc/kismet_drone.conf.orig
sudo rm /usr/local/etc/kismet.conf
sudo cp /home/pi/zulfikar/ZVL-Dev/config_files/suidins/{kismet.conf,oui2.txt,correct_date.py} /usr/local/etc/
#sudo chmod 777 /etc/kismet/kismet.conf
#sudo chmod 777 /etc/kismet/oui2.txt
sudo chmod 777 /usr/local/etc/correct_date.py


##get mac address of wlan0 then pass it for kismet.conf for filtering the AP
##filter_tracker=BSSID(!--:--:--:--:--:--) is the defined format
holder="`sudo ip -o link | awk '{print $2,$(NF-2)}' | grep wlan0 | cut -d' ' -f2`"
sed -i "198s/.*/filter_tracker=BSSID(!$holder)/" /usr/local/etc/kismet.conf

#echo -e "/etc/kismet/ files done" >> /home/pi/zulfikar/ZVL-Dev/Zulfi_handler/progress.list


##/etc/default/gpsd
##/etc/default/hostapd
##/etc/default/ folder file operations are handled in this part
sudo mv /etc/default/gpsd /etc/default/gpsd.origin
sudo mv /etc/default/hostapd /etc/default/hostapd.origin
sudo cp /home/pi/zulfikar/ZVL-Dev/config_files/{gpsd,hostapd} /etc/default/
#sudo chmod 777 /etc/default/gpsd
#sudo chmod 777 /etc/default/hostapd

#echo -e "gpsd - hostapd files done" >> /home/pi/zulfikar/ZVL-Dev/Zulfi_handler/progress.list

#/etc/network/interfaces
sudo mv /etc/network/interfaces /etc/network/interfaces.origin
sudo cp /home/pi/zulfikar/ZVL-Dev/config_files/interfaces /etc/network/

#echo -e "interfaces done" >> /home/pi/zulfikar/ZVL-Dev/Zulfi_handler/progress.list


####/etc/hostapd/###
#/etc/hostapd/hostapd.conf
if [ -e /etc/hostapd/hostapd.conf ]; then
  sudo mv /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.origin
fi
sudo cp /home/pi/zulfikar/ZVL-Dev/config_files/hostapd.conf /etc/hostapd/

#echo -e "hostapd.conf done" >> /home/pi/zulfikar/ZVL-Dev/Zulfi_handler/progress.list

#allow ssh
#change the default port if needed
####/etc/ssh/###
#/etc/ssh/sshd_config

#allow ssh
#change timezone
#sudo raspi-config

#echo -e "raspi-config done" >> /home/pi/zulfikar/ZVL-Dev/Zulfi_handler/progress.list

####/etc/####

#/etc/dnsmasq.conf file operations are handled in this part
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.origin
sudo cp /home/pi/zulfikar/ZVL-Dev/config_files/dnsmasq.conf /etc/


#/etc/dhcpcd.conf file operations are handled in this part
sudo mv /etc/dhcpcd.conf /etc/dhcpcd.conf.origin
sudo cp /home/pi/zulfikar/ZVL-Dev/config_files/dhcpcd.conf /etc/


#/etc/sysctl.conf file operations are handled in this part
sudo mv /etc/sysctl.conf /etc/sysctl.conf.origin
sudo cp /home/pi/zulfikar/ZVL-Dev/config_files/sysctl.conf /etc/


#ipv4 port forward section
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

#/etc/rc.local
sudo mv /etc/rc.local /etc/rc.local.origin
sudo cp /home/pi/zulfikar/ZVL-Dev/config_files/rc.local /etc/

sudo systemctl disable dhcpcd.service > /dev/null 2>&1

##transfer the latest a.sh file to /home/pi by renaming the script and set priviliges.
sudo mv /home/pi/zulfikar/ZVL-Dev/Zulfi_handler/asuidroot.sh /home/pi/asuidroot.sh
sudo chmod 777 /home/pi/asuidroot.sh

sleep 5
echo "${RED}Shutting down!${RESET}"
sudo shutdown +0

#echo -e "/etc/ done" >> /home/pi/zulfikar/ZVL-Dev/Zulfi_handler/progress.list

#echo -e "FINALIZED" >> /home/pi/zulfikar/ZVL-Dev/Zulfi_handler/progress.list
