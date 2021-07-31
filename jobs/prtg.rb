#username=USER
#password=PASS
#
require "curl"
require "json"

SCHEDULER.every '1m', :first_in => 0 do |job|
# Ping server
state = `ping -c 3 IPPRTG | grep -Po "100% packet loss" | wc -l`
state = JSON.parse(etat)

# Check downs criticals
nb_crit =`curl -s -k 'https://IPPRTG//api/table.json?content=sensors&output=json&columns=objid&filter_status=5&username=USER&password=PASS' | jq '.' | grep "objid_raw" |wc -l`
nb_crit = JSON.parse(nb_crit)

# Check Warnings
nb_warn =`curl -s -k 'https://IPPRTG//api/table.json?content=sensors&output=json&columns=objid&filter_status=4&username=USER&password=PASS' | jq '.' | grep "objid_raw" |wc -l`
nb_warn = JSON.parse(nb_warn)

# Check Unknowns
nb_unkn =`curl -s -k 'https://IPPRTG//api/table.json?content=sensors&output=json&columns=objid&filter_status=1&username=USER&password=PASS' | jq '.' | grep "objid_raw" |wc -l`
nb_unkn = JSON.parse(nb_unkn)

# check ackownledged
nb_ack = `curl -s -k 'https://IPPRTG//api/table.json?content=sensors&output=json&columns=objid&filter_status=7&filter_status=8&filter_status=9&filter_status=11&filter_status=12&filter_status=13&username=USER&password=PASS' | jq '.' | grep "objid_raw" | wc -l`
nb_ack = JSON.parse(nb_ack)

# Send colors
status = nb_crit > 0 ? "out" : (state> 0 ? "out" : (nb_warn > 0 ? "yellow": (nb_unkn > 0 ? "yellow" : "green")))

# Send state ping
state = state > 0 ? "Ping KO" : "Ping OK"

# Send data to widget
send_event('adocc',  {criticals: nb_crit, warnings: nb_warn, unknowns: nb_unkn, acknowns: nb_ack, state: state, status: status})
end
