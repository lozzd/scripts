scripts
===========

Random scripts

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
