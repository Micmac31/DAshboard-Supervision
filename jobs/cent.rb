require "curl" 
require "jq" 
require 'json'

# ip_centreon = IPCENTREON
# user = "USER"
# password = "PASS"
# token = TOKEN
# Get new token: curl -s -k -X POST -d '{"security": {"credentials": {"login": "USER","password": "PASS"}}}' -H "Content-Type: application/json" -X POST https://IPCENTREON/centreon/api/beta/login


SCHEDULER.every '30s', :first_in => 0 do |job|
# Ping server
state = `ping -c 3 IPCENTREON | grep -Po "100% packet loss" | wc -l`
state = JSON.parse(etat)

# check token
token = `curl -s -k -H 'X-AUTH-TOKEN:'TOKEN'' -H "Content-Type: application/json" -X GET "https://IPCENTREON /centreon/api/beta/monitoring/hostgroups" | jq '.' | grep "No token could be found." | wc -l`
token = JSON.parse(token)

# Hosts Down
host = `curl -s -k  "https://IPCENTREON/centreon/api/index.php?object=centreon_realtime_hosts&action=list&status=down&viewType=unhandled" -H 'Content-Type: application/json' -H 'centreon-auth-token: 'TOKEN'' | jq '.' | grep "acknowledged" | wc -l`
host = JSON.parse(host)

# services critiques
critical = `curl -s -k  "https://IPCENTREON/centreon/api/index.php?object=centreon_realtime_services&action=list&status=critical&viewType=unhandled" -H 'Content-Type: application/json' -H 'centreon-auth-token: 'TOKEN'' | jq '.' | grep "acknowledged" | wc -l`
critical = JSON.parse(critical)

# services warnings
warning = `curl -s -k  "https://IPCENTREON/centreon/api/index.php?object=centreon_realtime_services&action=list&status=warning&viewType=unhandled" -H 'Content-Type: application/json' -H 'centreon-auth-token: 'TOKEN'' | jq '.' | grep "acknowledged" | wc -l`
warning = JSON.parse(warning)

# services unknown
unknown = `curl -s -k  "https://IPCENTREON/centreon/api/index.php?object=centreon_realtime_services&action=list&status=unknown&viewType=unhandled" -H 'Content-Type: application/json' -H 'centreon-auth-token: 'TOKEN'' | jq '.' | grep "acknowledged" | wc -l`
unknown = JSON.parse(unknown)

# Send colors
status = host > 0 ? "out" : (state > 0 ? "out" : (token > 0 ? "out" : (critical > 0 ? "red": (warning > 0 ? "yellow" : (unknown > 0 ? "yellow" : "green")))))

# send state ping
state = state > 0 ? "Ping KO" : "Ping OK"

# Send state token
token = token > 0 ? "Token KO" : "Token OK"

# Send data to widget
send_event("cent",  {host: host, critical: critical, warning: warning, unknown: unknown, state: state, token: token, status: status})
end


