#!/bin/bash
    #title          :a.sh
    #description    :Providing powerful yet simle UI for both cli an desktop, this script handles automation  via bash scripting.
    #author         :rektosauruz
    #date           :20181005
    #version        :v2.5
    #usage          :#pi./a.sh
    #notes          :Single module usage is implemented for v2.0. Cell phone gps usage is implemented in addition to pl2303 gps usage.
    #bash_version   :4.4-5
    #================================================================================

#File Declarations
#/home/pi/zulfi_logs/                    [raw data files are saved here from kismet_server.]
#/home/pi/zulfi_arch/                    [files are transferred after each run to this location to be processed.]
#/home/pi/zulfi_arch/{date}/             [a dated folder is created for that day.]
#/home/pi/zulfi_arch/BSSID.list          [unique MACs are held here for counting and comparison for uniqueness.]
#/home/pi/zulfi_arch/datapool.txt        [datapool.txt holds the unique data, populated after each run, a simple database file holds raw data.]
#/home/pi/zulfi_arch/temp.list           [for each run MACs in the respective .nettxt file are passed to temp.list for comparison with BSSID.list]
#/home/pi/zulfi_arch_processed/          [processed files are saved here under the same respective dates.]
#/home/pi/zulfi_arch_processed/{date}/   [dated folders are directly transferred under prcessed section after the sequence.]
#/home/pi/etc/kismet/timechk             [timechk file is created after the first date correction, at the end of each run, this file is removed.]

# Color Declerations
ESC="["
RESET=$ESC"39m"
RED=$ESC"31m"
GREEN=$ESC"32m"
LYELLOW=$ESC"36m"
YELLOW=$ESC"34m"
YELLOW=$ESC"33m"
RB=$ESC"48;5;160m"
RESET1=$ESC"0m"
RESETU=$ESC"24m"
GB=$ESC"48;5;40m"


wst1="${RB}    ${RESET1}"
wst2="${RB}    ${RESET1}"
gpsm="${RB}    ${RESET1}"
gpfx="${RB}    ${RESET1}"
dat0="${RB}    ${RESET1}"

wst11="${RED}=====${RESET}"
wst22="${RED}===========${RESET}"
gpsmm="${RED}=====${RESET}"
gpfxx="${RED}===========${RESET}"
dat00="${RED}=====${RESET}"


ledger () {

cat <<-ENDOFMESSAGE
 ${RED}_____      ______${RESET}
${RED}/${RESET}$wst1${RED}|${RESET}$wst11${RED}/ W1 __\ ${RESET}  
${RED}\_____\    \___|   _____${RESET}   
${RED}/${RESET}$wst2 ${RED}|${RESET}$wst22${RED}/ W2 /${RESET}    
${RED}\_____\      _____\___|${RESET}   
${RED}/${RESET}$gpsm ${RED}|${RESET}$gpsmm${RED}/ GPS /${RESET}       
${RED}\_____\     \____| _____${RESET}   
${RED}/${RESET}$gpfx ${RED}|${RESET}$gpfxx${RED}/Gfix/${RESET}   
${RED}\_____\      _____\____| ${RESET} 
${RED}/${RESET}$dat0 ${RED}|${RESET}$dat00${RED}/ DATE/${RESET}  
${RED}\____/      \____/${RESET}                             
ENDOFMESSAGE

}

if [ -n "`sudo pidof gpsd`" ]; then
sudo pkill gpsd
fi


##use these later
#FOR THE GREEN BACKGORUND BLOCK
#echo -e "\e[48;5;40m \e[0m"
#above line prints a single block of green on tty 

#init var(1-4)
for i in `seq 1 4`; do
  eval "var${i}=${RED}X${RESET}"
done

var5="${RED}NOT READY${RESET}"
var6="${RED}X${RESET}"
timeloc=/usr/local/etc/timechk
kiss_state="`sudo pidof kismet_server`"
chk1="${RED}[Wlan1]${RESET}"
chk2="${RED}[Wlan2]${RESET}"
chk3="${RED}[GPS]${RESET}"
chk4="${RED}[GPSfix]${RESET}"
chk5="${RED}[Date]${RESET}"
reset

##check for the kismet server if the a.sh is armed then closed, after a rerun state is fixed to armed.
if [ -n "$kiss_state" ]; then
      var5="${RED}ARMED${RESET}"
fi

#refresh() {
#if [ -n "`ls -A /home/pi/zulfi_logs/`" ]; then
#   tempcalc="`ls /home/pi/zulfi_logs/ | grep .nettxt`"
#   kk="${GREEN}`cat /home/pi/zulfi_logs/"$tempcalc" | grep Network | uniq | wc -l`${RESET}"
#else
#   kk="${GREEN}0${RESET}"
#fi
#}





count() {
kk="${RED}`wc -l /home/pi/zulfi_arch/BSSID.list | cut -d' ' -f1`${RESET}"
}

count


##time correction is made by comparing the gps time provided by gps module, if the time is not correct by the day, hour, minutes, then corrections
##is made by using the correct_date.py
correcttime() {

if [ "`gpspipe -w -n 10 | grep TPV | tail --lines=1 | cut -d'"' -f14 | cut --bytes=1-10,12-16 | sed -e "s/^\(.\{10\}\)/\1 /"`" == "`TZ=":UTC" date "+%Y-%m-%d %R"`" ]; then
      var6="${GREEN}OK${RESET}"
else
      python /usr/local/etc/correct_date.py
      var6="${GREEN}OK${RESET}"
fi
}


##check if hostapd is active or not, this option is for monitored runs and while no hostapd is needed.
##also ip address is printed in the Zulfikar GUI for easy usage.
apdip() {

if [ -z "`pidof hostapd`" ]; then
      var7="${RED}X${RESET}"
      var8="${RED}IP${RESET}    ${RED}>${RESET} ${RED}X${RESET}"
else
      var7="${GREEN}OK${RESET}"
      var8="${GREEN}`ifconfig wlan0 | grep "inet " | cut -d't' -f2 | cut -d'n' -f1 | xargs`${RESET}"
fi

}

apdip


##this is data sorter function for the zulfikar. After every use, data is collected under Zulfi_logs is first transferred to Zulfi_arch
d_sorter() {

##declare
datum="`date +%Y%m%d`"
locA=/home/pi/zulfi_logs/
locB=/home/pi/zulfi_arch/
locC=/home/pi/zulfi_arch/processed/

#check for dated folder /home/pi/zulfi_arch/ . Multiple runs in the same day are collected under the same folder such as 20180513
if [ ! -d "$locB""$datum" ];then
    sudo mkdir "$locB""$datum"
    sudo chmod 777 "$locB""$datum"/
fi

#check for dated folder /home/pi/zulfi_arch/processed/
if [ ! -d "$locC""$datum" ];then
    sudo mkdir "$locC""$datum"
    sudo chmod 777 "$locC""$datum"/
fi

##create data count list for different dates
sudo touch "$locB"datac.list
sudo chmod 777 "$locB"datac.list

##check for different dated files then pass it to datac.list
echo "`ls "$locA" | grep "$datum"`" >> "$locB"datac.list

##pass the dated files from zulfi_logs to respective dated folder
for i in $(cat /home/pi/zulfi_arch/datac.list);do
    #copy option
   sudo cp "$locA"$i "$locB""$datum"
done
sudo rm -r "$locA"*


##clear the datac.list
sudo rm "$locB"datac.list


#check for datapool file, create at /home/pi/zulfi_arch/ if needed
if [ ! -f "$locB""$datum"/datapool.txt ];then
    sudo touch "$locB"datapool.txt
    sudo chmod 777 "$locB"datapool.txt
fi


####check for temporary list, this list is used to compare with BSSID.list to keep track of unique MACs for the run.
if [ ! -f "$locB""$datum"/templ.list ];then
   sudo touch /home/pi/zulfi_arch/templ.list
   sudo chmod 777 /home/pi/zulfi_arch/templ.list
fi

##this line gets the exact name of the .nettxt file then picks the MACs then pushed it to temprary list named templ.list
filenom="`ls "$locB""$datum" | grep ".nettxt"`"
echo -e "`grep "Network " "$locB""$datum"/"$filenom" | cut -d' ' -f4`" >> "$locB"templ.list

##comparison is made in this for loop. For every MAC address located in templ.list, BSSID.list is checked, if no match then the MAC is unique.
##unique MACs then passed to datapool.txt file with certain lines(line 125). Also BSSID list is populated with new unique MACs.
for i in $(cat /home/pi/zulfi_arch/templ.list);do
	if [ "`grep "$i" "$locB"BSSID.list`" == "" ];then
		test1="`grep "Network " "$locB""$datum"/"$filenom" | grep "$i"`"
                sed -n "/$test1/,/Network /{/$test1/{p};/Network /{d};p}" "$locB""$datum"/"$filenom" >> "$locB"datapool.txt
		echo -e "$i" >> /home/pi/zulfi_arch/BSSID.list

    fi
done

##temporary list is cleared.
sudo rm /home/pi/zulfi_arch/templ.list

##moving the processed dated folder under zulfi_arch to processed folder under zulfi_arch
sudo mv -v /home/pi/zulfi_arch/"$datum"/* /home/pi/zulfi_arch/processed/"$datum"/ 1>/dev/null

count

}


##device probe function
components_chk() {
clear
ledger
if [ "`iwconfig 2>&1 | sed -n -e 's/wlan1     //p'| cut --bytes=1`" == "I" ]; then
#if [ "`iwconfig wlan1 | cut -d' ' -f1 | xargs`" == "wlan1" ]; then
#if [ "`iwconfig wlan1: | cut -d':' -f1 | cut -d' ' -f1 | xargs`" == "wlan1" ]; then
#	chk1="${GREEN}[Wlan1]${RESET}"
#	echo -ne "$chk1$chk2$chk3$chk4$chk5\r"
  wst11="${GREEN}=====${RESET}"
  clear 
  ledger
  sleep 1
  wst1="${GB}    ${RESET1}"
  clear
  ledger
	var1="${GREEN}OK${RESET}"
elif [ "`iwconfig 2>&1 | sed -n -e 's/wlan1     //p'| cut --bytes=1`" != "I" ];then
#	echo -ne "$chk1$chk2$chk3$chk4$chk5\r"
	var1="${RED}X${RESET}"

fi

if [ "`iwconfig 2>&1 | sed -n -e 's/wlan2     //p' | cut --bytes=1`" == "I" ]; then
#if [ "`iwconfig wlan2 | cut -d' ' -f1 | xargs`" == "wlan2" ]; then
#if [ "`iwconfig wlan2: | cut -d':' -f1 | cut -d' ' -f1 | xargs`" == "wlan2" ]; then
#	chk2="${GREEN}[Wlan2]${RESET}"
#	echo -ne "$chk1$chk2$chk3$chk4$chk5\r"
  clear
  ledger
  wst22="${GREEN}===========${RESET}"
  sleep 1
  wst2="${GB}    ${RESET1}"
  clear
  ledger
	var2="${GREEN}OK${RESET}"
elif [ "`iwconfig 2>&1 | sed -n -e 's/wlan2     //p'| cut --bytes=1`" != "I" ];then
#	echo -ne "$chk1$chk2$chk3$chk4$chk5\r"
	var2="${RED}X${RESET}"
fi

if [ "`dmesg | grep "pl2303 converter now attached to ttyUSB0" | cut -d':' -f2 | xargs`" == "pl2303 converter now attached to ttyUSB0" ]; then
#	chk3="${GREEN}[GPS]${RESET}"
#	echo -ne "$chk1$chk2$chk3$chk4$chk5\r"
  clear
  ledger
  gpsmm="${GREEN}=====${RESET}"
  gpfxx="${GREEN}===========${RESET}"
  dat00="${GREEN}===========${RESET}"
  clear
  ledger
  sleep 1
  clear
  ledger
  gpsm="${GB}    ${RESET1}"
	var3="${GREEN}OK${RESET}"

else
#	echo -ne "$chk1$chk2$chk3$chk4$chk5\r"
	var3="${RED}X${RESET}"
#	gpsd -b -n tcp://172.24.1.150:50000
#	return 1
fi

testv=`ping -c 1 -w 1 172.24.1.150 | grep ttl`
if [ -n "$testv" ];
    then
    clear
    ledger
    gpsmm="${GREEN}=====${RESET}"
    clear 
    ledger
    sleep 1
    gpsm="${GB}    ${RESET1}"
    clear
    ledger
    sleep 1
    gpfxx="${GREEN}===========${RESET}"
    clear
    ledger
    sleep 1
    dat00="${GREEN}=====${RESET}"
    clear
    ledger
    sleep 1
    gpsd -b -n tcp://172.24.1.150:50000
    var3="${GREEN}OK${RESET}"
else
    return 1  
fi

if [ "`timeout 6 gpspipe -w -n 5 | cut -d',' -f3 | grep mode | cut -d':' -f2`" != "3" ]; then
    return 1
fi

while true ; do
   if [ "`gpspipe -w -n 5 | cut -d',' -f3 | grep mode | cut -d':' -f2`" == "3" ]; then
 #     chk3="${GREEN}[GPS]${RESET}"
 #     chk4="${GREEN}[GPSfix]${RESET}"
 #     echo -ne "$chk1$chk2$chk3$chk4$chk5\r"
#      gpsm="${GB}    ${RESET1}"
      var3="${GREEN}OK${RESET}"
      var4="${GREEN}OK${RESET}"
      gpfx="${GB}    ${RESET1}"
      clear
      ledger
      sleep 1
	if [ ! -f "$timeloc"  ]; then
           #correcttime
           correcttime > /dev/null 2>&1
	 #  chk5="${GREEN}[Date]${RESET}"
   #        echo -ne "$chk1$chk2$chk3$chk4$chk5\r"
           
           dat0="${GB}    ${RESET1}"
           clear
           ledger
           sleep 1
       
           var5="${GREEN}READY${RESET}"
	   sudo touch "$timeloc"
        else
	 #  chk5="${GREEN}[Date]${RESET}"
   #        echo -ne "$chk1$chk2$chk3$chk4$chk5\r"
           dat0="${GB}    ${RESET1}"
           clear 
           ledger
           sleep 1
           var5="${GREEN}READY${RESET}"
        fi
      break
   else
      chk4="${RED}[GPSfix]${RESET}"
   #   echo -ne "$chk1$chk2$chk3$chk4$chk5\r"
   fi
done

##check WLAN1 WLAN2 GPS GPSfix
if [ "$var1" == "${GREEN}OK${RESET}" ] && [ "$var2" == "${GREEN}OK${RESET}" ] && [ "$var3" == "${GREEN}OK${RESET}" ] && [ "$var4" == "${GREEN}OK${RESET}" ]; then
      var5="${GREEN}READY${RESET}"
elif [ "$var1" == "${GREEN}OK${RESET}" ] && [ "$var2" == "${RED}X${RESET}" ] && [ "$var3" == "${GREEN}OK${RESET}" ] && [ "$var4" == "${GREEN}OK${RESET}" ]; then
      var5="${GREEN}READY${RESET}"

else
	 var5="${RED}MISSING MODULE(s)${RESET}"
	 echo -e "\n${RED}reprobe needed${RESET}"
	 sleep 1
	 return 1
fi
if [ -z "`pidof hostapd`" ]; then
      var7="${RED}X${RESET}"
      var8="${RED}IP${RESET}    ${RED}>${RESET} ${RED}X${RESET}"
else
      var7="${GREEN}OK${RESET}"
      #ifconfig wlan0 | grep "inet " | cut -d't' -f2 | cut -d'n' -f1 | xargs
      var8="${GREEN}`ifconfig wlan0 | grep "inet " | cut -d't' -f2 | cut -d'n' -f1 | xargs`${RESET}"
fi



}

#clock () {

#while [1];do ledger;printf "\33[A";sleep 1;done

#}
#var5="${RED}READY${RESET}"
##zulfikar menu
while :
do
    #clear
    reset
    cat<<EOF
`echo -e "${RED}  _                  _   _   ____   _____  ____ ${RESET}"`
`echo -e "${RED} | |         /\     | \ | | / ___| |___ / |  _ \ ${RESET}"`
`echo -e "${RED} | |        /  \    |  \| || |       |_ \ | | | | ${RESET}"`
`echo -e "${RED} | |___ _  / /\ \  _| |\  || |___ _ ___) || |_| |${RESET}"`
`echo -e "${RED} |_____(${RESET}${RB} ${RESET1}${RED})/______\(${RESET}${RB} ${RESET1}${RED})_| \_(${RESET}${RB} ${RESET1}${RED})____(${RESET}${RB} ${RESET1}${RED})____(${RESET}${RB} ${RESET1}${RED})____(${RESET}${RB} ${RESET1}${RED})${RESET}"`
 ${RED} _____      _____ ${RESET}   ${RED}__________________${RESET}
${RED}//     \\${RESET}${RED}MENU${RESET}${RED}/     \\\\${RESET}  ${RED}\\${RESET}${RB}                ${RESET1}${RED}/${RESET}
${RB} ${RESET1} ${RED}Device Probe${RESET} ${RED}[1]${RESET} ${RB} ${RESET1}   ${RED}\\${RESET}${RB}              ${RESET1}${RED}/${RESET}
${RB} ${RESET1} ${RED}Quick Start${RESET}  ${RED}[2]${RESET} ${RB} ${RESET1}    ${RED}\\${RESET}  `printf "%-20s\n" "$var5"`${RED}/${RESET}
${RB} ${RESET1} ${RED}ARM${RESET}          ${RED}[3]${RESET} ${RB} ${RESET1}     ${RED}\\${RESET}${RB}          ${RESET1}${RED}/${RESET}
${RB} ${RESET1} ${RED}DISARM${RESET}       ${RED}[4]${RESET} ${RB} ${RESET1}      ${RED}\\${RESET}${RB}        ${RESET1}${RED}/${RESET}
${RB} ${RESET1} ${RED}Quit${RESET}         ${RED}[Q]${RESET} ${RB} ${RESET1}       ${RED}\\${RESET}${RB}      ${RESET1}${RED}/${RESET}
${RED}\\${RESET}${RED}\\${RESET}${RED}________________/${RESET}${RED}/${RESET}        ${RED}\\${RESET}${RB}    ${RESET1}${RED}/${RESET}
${RED}Total APs >${RESET} `printf "%-20s\n" "$kk"`       ${RED}\\${RESET}${RB}  ${RESET1}${RED}/${RESET}
`printf "%-31s\n" "$var8"`         ${RED}\\/${RESET}
`ledger`


                        

  

EOF

##while [ 1 ];do date;printf "\33[A";sleep 1;done

##start function uses kismet_server
start_ks() {
#refresh
#create a file named by YearMonthDay
#sudo mkdir /home/pi/zulfi_logs/"`date +%Y%m%d`"
if [ "$var5" == "${GREEN}READY${RESET}" ];then
/usr/local/bin/kismet_server --daemonize > /dev/null 2>&1
var5="${RED}ARMED${RESET}"
sleep 2
else
	echo "${RED}!!!probe the devices!!!${RESET}"
	return 1
fi

}


##stop function kills kismet_server then after 3 seconds sorts the data using d_sorter function
stop_ks() {

sudo killall kismet_server
sleep 3
if [ -z "$(ls -A /home/pi/zulfi_logs)" ]; then
	return 1
else
    d_sorter
    sleep 5
fi
if [ -n "`pidof gpsd`" ]; then
        sudo pkill gpsd
fi
var5="${GREEN}UNARMED${RESET}"

}


##start function for selection 2. first the components are probed, then the kismet_server is run
q_start() {
components_chk
start_ks
return 1
}


    read -n1 -s
    case "$REPLY" in
    "1")  components_chk ;;
    "2")  q_start  ;;
    "3")  start_ks ;;
    "4")  stop_ks  ;;
#    "r")  refresh ;;
    "Q")  sudo rm "$timeloc" 2>/dev/null
	  reset
          exit
                  ;;
    "q")  sudo rm "$timeloc" 2>/dev/null
	  reset
 	  exit
		  ;;
     * )  echo "invalid option"  ;;
    esac
    sleep 1
done
