require "curl" 
require "jq" 
require 'json'

#ip_zabbix = "IPZABBIX"
#user = "USER"
#password = "PASS"
#token = "TOKEN"

# Get new token: curl -s -k -X POST -H 'Content-Type: application/json-rpc' -d '{ "params": { "user": "USER", "password": "PASS" }, "jsonrpc": "2.0", "method": "user.login", "id": 0 }' 'https://IPZABBIX/zabbix/api_jsonrpc.php' | jq '.'


SCHEDULER.every '30s', :first_in => 0 do |job|
# Ping serveur
state = `ping -c 3 IPZABBIX | grep -Po "100% packet loss" | wc -l`
state = JSON.parse(etat)

# check state token
token = `curl -s -k -m 5 -H "Content-Type: application/json-rpc" -X POST https://IPZABBIX/zabbix/api_jsonrpc.php -d '{"jsonrpc":"2.0","method":"hostgroup.get","id":1,"auth":"TOKEN","params": {"output": "extend"}}' | jq '.' | grep "Session terminated, re-login, please." | wc -l`
token = JSON.parse(token)

# Hosts Disaster
dis = `curl -s -k -m 5 -H "Content-Type: application/json-rpc" -X POST https://IPZABBIX/zabbix/api_jsonrpc.php -d '{"jsonrpc":"2.0","method":"trigger.get","id":1,"auth":"TOKEN","params" : {"selectLastEvent": "extend","selectHosts": "extend","output": ["triggerid","status","priority","description","status","manual_close"],"maintenance": false,"monitored": true,"withLastEventUnacknowledged": true,"skipDependent": true,"only_true": true,"filter": {"value": 1,"priority": "5","status": 0}}}' | jq '.' | grep "triggerid" | wc -l`
dis = JSON.parse(dis)

# services high
high = `curl -s -k -m 5 -H "Content-Type: application/json-rpc" -X POST https://IPZABBIX/zabbix/api_jsonrpc.php -d '{"jsonrpc":"2.0","method":"trigger.get","id":1,"auth":"TOKEN","params" : {"selectLastEvent": "extend","selectHosts": "extend","output": ["triggerid","status","priority","description","status","manual_close"],"maintenance": false,"monitored": true,"withLastEventUnacknowledged": true,"skipDependent": true,"only_true": true,"filter": {"value": 1,"priority": "4","status": 0}}}' | jq '.' | grep "triggerid" | wc -l`
high = JSON.parse(high)

# services warnings
warn = `curl -s -k -m 5 -H "Content-Type: application/json-rpc" -X POST https://IPZABBIX/zabbix/api_jsonrpc.php -d '{"jsonrpc":"2.0","method":"trigger.get","id":1,"auth":"TOKEN","params" : {"selectLastEvent": "extend","selectHosts": "extend","output": ["triggerid","status","priority","description","status","manual_close"],"maintenance": false,"monitored": true,"withLastEventUnacknowledged": true,"skipDependent": true,"only_true": true,"filter": {"value": 1,"priority": "3","status": 0}}}' | jq '.' | grep "triggerid" | wc -l`
warn = JSON.parse(warn)

# services unknown
avrg = `curl -s -k -m 5 -H "Content-Type: application/json-rpc" -X POST https://IPZABBIX/zabbix/api_jsonrpc.php -d '{"jsonrpc":"2.0","method":"trigger.get","id":1,"auth":"TOKEN","params" : {"selectLastEvent": "extend","selectHosts": "extend","output": ["triggerid","status","priority","description","status","manual_close"],"maintenance": false,"monitored": true,"withLastEventUnacknowledged": true,"skipDependent": true,"only_true": true,"filter": {"value": 1,"priority": "2","status": 0}}}' | jq '.' | grep "triggerid" | wc -l`
avrg = JSON.parse(avrg)

# Send colors
status = dis > 0 ? "out" : (state > 0 ? "out" : (token > 0 ? "out" : (high > 0 ? "red": (warn > 0 ? "yellow" : "green"))))

# Send state ping
state = state > 0 ? "Ping KO" : "Ping OK"

# Send state Token
token = token > 0 ? "Token KO" : "Token OK"

# Send datas
send_event("CLIENT",  {dis: dis, high: high, warn: warn, avrg: avrg, state: state, token: token, status: status})
end

