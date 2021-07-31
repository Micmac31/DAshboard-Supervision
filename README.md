# Dashboard-Supervision
This is my first project on GitHub.\
My native langage is french so sorry if translate is not perfect :).\
- This dashboard that I created allows to send back the status information of Zabbix, Centreon and PRTG.\
- I installed and tested it on Debian 10 see: dashboard-Debian-install.txt\
- One tile per supervision with: (see result on dashboard.jpg)\
Hosts up / down (green / red color flashing)\
Services ok / unknown / warning / critical (color green / yellow / red)\
Supervision server state ok / ko (green / red color flashing)\
Token state ok / ko (green / red color flashing) no token for PRTG.\
- On Centreon you will need a user to see : https://docs.centreon.com/api/centreon-web/ \
- On Zabbix you will need a user to see : https://www.zabbix.com/documentation/current/manual/api \
- On PRTG you will need a user to see : https://www.paessler.com/manuals/prtg/http_api \
- Once your user is created you must enter the name and password as well as the IP of your server in the jobs / cent or zabb or prtg.rd file (depending on your server) \
- Copy all the .rb files in the jobs folder and all the folders in widgets in the widget folder of your dashboard\
- 
