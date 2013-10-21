#!/bin/bash

# This script is useful if you wish to watch closely what is happening to your public
# facing DNS.
# Set up using cron to pull your current entire zone using AXFR, it can inform you via email
# to any changes to your zone. 
#
# Example crontab entry:
# */5   root   /usr/local/bin/compare_zone.sh mydomain.com ns1.mydomain.com ops@mydomain.com

if [ -z $3 ]
then
    echo "Usage: $0 <domain_to_test> <nameserver_with_axfr_enabled> <email_recipient>"
    echo 
    echo "Grabs a copy of the specified domain_to_test form nameserver_with_axfr_enabled using AXFR"
    echo "and compares. If there are changes, they are emailed to email_recipient. "
    echo "Run in cron to get automated alerts of any changes to your domain. "
    echo

    exit 2
fi

DOMAIN_TO_TEST=$1
AXFR_NS=$2
EMAIL_TO=$3

DIG_COMMAND="/usr/bin/dig +noall +answer -t axfr @$AXFR_NS $DOMAIN_TO_TEST"
TEMP_FILE="/tmp/compare_zone.$DOMAIN_TO_TEST"

echo "`date` - Starting compare run for '$DOMAIN_TO_TEST' from server '$AXFR_NS'..."

# For the first run we'll need to create a file to compare to. 
if [ ! -f $TEMP_FILE ]
then
    echo "`date` - First run, creating compare file at $TEMP_FILE..."
    $DIG_COMMAND > $TEMP_FILE
    if [ $? -ne 0 ]
    then
        echo 
        echo "Dig command failed!"
        echo "We tried to run: "
        echo
        echo "$DIG_COMMAND"
        echo
        echo "Please check your configuration!"
        rm $TEMP_FILE
        exit 2
    fi
fi

echo "`date` - Getting current copy of zone to compare to..."
$DIG_COMMAND > "$TEMP_FILE.new"
if [ $? -ne 0 ]
then
    echo 
    echo "Dig command failed!"
    echo "$DIG_COMMAND"
    echo
    echo "Please check your configuration! Or maybe your provider is down?"
    exit 2
fi


echo "`date` - Running diff..."
DIFF_CONTENT=`diff -U0 $TEMP_FILE $TEMP_FILE.new`

if [ $? -eq 0 ]
then
    echo "`date` - No changes, not doing anything"
else
    echo "`date` - Change in content, sending diff email to $EMAIL_TO..."
    echo "$DIFF_CONTENT" | mail -s "Change in '$DOMAIN_TO_TEST' zone occured" $EMAIL_TO
fi

# Update the old file with the new file, ready for the next comparison!
echo "`date` - Rotating new file over old..."
mv $TEMP_FILE.new $TEMP_FILE

echo "`date` - $DOMAIN_TO_TEST comparison complete. "
exit 0
