#!/bin/bash
# A simple script to extract a rar file inside a directory downloaded by Transmission.
# It uses environment variables passed by the transmission client to find and extract
# any rar files from a downloaded torrent into the folder they were found in.

LOGFILE="/var/lib/transmission-daemon/auto-unrar.log"

function log {
   echo "`date '+%Y-%m-%d %H:%M:%S'`    $1" >> "$LOGFILE"
}

if [ -z "$TR_APP_VERSION" ]
then
   log "Not run from transmission?"
   env >> "$LOGFILE"
   exit 2
fi

log "Running find with dir '$TR_TORRENT_DIR', name '$TR_TORRENT_NAME', id '$TR_TORRENT_ID'"
find /$TR_TORRENT_DIR/$TR_TORRENT_NAME -name "*.rar" -execdir unrar e -o- "{}" \; >> "$LOGFILE" 2>&1
log "Completed for ID '$TR_TORRENT_ID'"
