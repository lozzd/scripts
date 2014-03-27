scripts
===========

Here lies an assortment of scripts that didn't fit anywhere else

## gmetric-nagios.rb

If you happen to run both Ganglia and Nagios, drop this script in and cron it minutely to get loads of juicy
metrics from ```nagiostats``` into Ganglia using ```gmetric```

Simply double check the paths to the binaries in the top of the file, amend the list of metrics (if you wish) and cron it up.

Example graphs:

![Example Nagios Graphs](https://laur.ie/grb/dl-g3i5nmxdkwcko.png)

This is a small sample of the stats (get the full list from nagiostats using ```nagiostats -h``` and look for the variables under "MRTG DATA VARIABLES")

The above examples show the Nagios check latency (in this case, latency times to run active service and host checks, and the average execute time for the plugins for both host and service checks) which are important to make sure your installation is not falling behind (have you tried enabling use_large_installation_tweaks?) running checks. 

Other metrics that graph by default include stats about how many services/hosts you have and what state they're in. 



## compare_zone.sh

This script is useful if you wish to watch closely what is happening to your public facing DNS.

Set up using cron to pull your current entire zone using AXFR, it can inform you via email to any changes to your zone.

Usage:

    compare_zone.sh <your-domain-name> <your-public-nameserver-address> <email-address-for-alerts>


Example crontab entry:

    */5   root   /usr/local/bin/compare_zone.sh mydomain.com ns1.mydomain.com ops@mydomain.com

All you need is bash, cron, and a place to run it that is allowed to use AXFR to transfer your zone from your public nameserver.


## Problems?

Hit me with an issue or a pull request whenever. These random scripts are without warranty.
