# LANCED
##test
##overall progress listed##

# LINKS

https://github.com/merbanan/rtl_433/blob/master/BUILDING.md
https://github.com/pwnieexpress/blue_hydra
https://github.com/pwnieexpress/pwn_pad_sources/tree/develop/scripts




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

## NOT CRITICAL ##
PLL not locked error issuing caused by not properly compiled drivers
such as rtl_sdr libs, must recompile rtl_433 after.
librtl is not able to tune to specified frequency.
## NOT CRITICAL ##


TO-DO LIST
** SCENARIO ok
** APPENDIX ok
** LANCED PANEL
** sqlite3 database
** kismet - blue_hydra - rtl_433 ==== > database integration



sqlite3 data integration

TABLE 1
METHOD--------MAC------MANUF------LOCATION-----DATE
WIFI                  
BLUETOOTH
subGhz
