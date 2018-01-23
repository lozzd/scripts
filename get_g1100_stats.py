### get_g1100_stats.py
###   This script makes API calls to the Verizon G1100 router
###   to retrieve interesting stats, and then outputs in a key:value
###   format, which is used in the Cacti graphing application.

import requests
import json
from optparse import OptionParser
parser = OptionParser()
parser.add_option("-H", "--hostname", dest="host",
        help="IP address or hostname of target router")
parser.add_option("-p", "--pass", dest="password",
        help="Encrypted password of admin user")
(options, args) = parser.parse_args()
if not options.password or not options.host:
    parser.error("incorrect number of arguments")

# The password for the admin user - no idea how this is encoded. I grabbed it from looking
# at the network traffic in the Chrome development tools. TODO: Make that better
password_data = '{"password": "%s"}' % options.password

# All the URLs we want to use
login_page = 'http://%s/' % options.host
login_post = 'http://%s/api/login' % options.host
network_api = 'http://%s/api/network' % options.host
devices_api = 'http://%s/api/devices' % options.host
system_api = 'http://%s/api/settings/system' % options.host
logout_url = 'http://%s/api/logout' % options.host

# Start a new Session
s = requests.session()

# Grab the homepage, then login using the password above
r = s.get(login_page)
r = s.post(login_post, password_data)

## Keep the XSRF from now on
# Get the cookies
c = r.cookies
# Grab the XSRF token cookie
xsrf = c.get('XSRF-TOKEN')
# Now set the requests library to use it.
headers = {'X-XSRF-TOKEN': xsrf}
s.headers.update(headers)

# Network Stats
resp = s.get(network_api, cookies = c)

# JSON to object
j = json.loads(resp.text)

if 'error' in j:
    print 'Login failed or too many sessions'
    exit()

# 0 is Bridge, 1 is Broadband, 2 is 5Ghz Wifi, 3 is 2.4Ghz wifi, 4 is ethernet, 5 is coax
ret = { '24ghz_tx': j[3]['txBytes'], '24ghz_rx': j[3]['rxBytes'],
        '5ghz_tx': j[2]['txBytes'], '5ghz_rx': j[2]['rxBytes'],
        'bb_tx': j[1]['txBytes'], 'bb_rx': j[1]['rxBytes'],
        'eth_tx': j[4]['txBytes'], 'eth_rx': j[4]['rxBytes'],
        'bridge_tx': j[0]['txBytes'], 'bridge_rx': j[0]['rxBytes'],
        'coax_tx': j[5]['txBytes'], 'coax_rx': j[5]['rxBytes'],
        }

# Now let's do devices per network - 0 = ethernet, 4 = 5ghz, 5 = 2.4ghz
devices_5ghz = devices_24ghz = devices_eth = 0
resp = s.get(devices_api, cookies = c)
j = json.loads(resp.text)
for x in j:
    if x['connectionType'] == 5 and x['status'] == True:
        devices_24ghz += 1
    elif x['connectionType'] == 4 and x['status'] == True:
        devices_5ghz += 1
    elif x['connectionType'] == 0 and x['status'] == True:
        devices_eth += 1

ret['dev_24ghz'] = devices_24ghz
ret['dev_5ghz'] = devices_5ghz
ret['dev_eth'] = devices_eth

resp = s.get(system_api, cookies = c)
j = json.loads(resp.text)

ret['nat_used'] = j['natEntriesUsed']

# Logout!
s.get(logout_url)

for k, v in ret.iteritems():
    print '%s:%s' % (k,v),
