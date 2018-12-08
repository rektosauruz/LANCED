# LANCED

##overall progress listed

```
# LINKS

https://github.com/merbanan/rtl_433/blob/master/BUILDING.md
https://github.com/pwnieexpress/blue_hydra
https://github.com/pwnieexpress/pwn_pad_sources/tree/develop/scripts
```



Program          status

```
hostapd            ok
blue_hydra         ok
ppp                ok
gprs               ok
gps                ok
lanced             ok
rtl-sdr            ok
Gqrx               ok
merbanan/rtl_433   ok

seems there is no issue with merbanan/rtl_433
#there is an issue with merbanan/rtl_433
```

```
## NOT CRITICAL ##
PLL not locked error issuing caused by not properly compiled drivers
such as rtl_sdr libs, must recompile rtl_433 after.
librtl is not able to tune to specified frequency.
## NOT CRITICAL ##
```

```
TO-DO LIST
** SCENARIO ok
** APPENDIX ok
** LANCED PANEL
** sqlite3 database
** kismet - blue_hydra - rtl_433 ==== > database integration
```

```
sqlite3 data integration

TABLE 1
METHOD--------MAC------MANUF------LOCATION-----DATE
WIFI                  
BLUETOOTH
subGhz
```

```
prot type for the csv file
"TYPE","Manuf","BSSID","MAC","TIMESTAMP","LAT","LON","ALT"
```

```
giskismet

use the giskismet to upload the data sqlite3
for the blue_hydra, all data is passed to the blue_hydra.db
for the rtl_433, there must be a framework to save the data to the db

for the formatting, a csv file can be formed for these three software
in that case after constructing a csv file, a wrapper for the sqlite3 data is handled by a python script.
after all these, a parser may be needed to read data from all three databases and inform a
new merged csv data file to populate an ultimate db for all three kind of devices.

```


```
apply range extender for emergency
fallback 
```
