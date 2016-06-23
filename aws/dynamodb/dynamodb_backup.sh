#!/bin/bash

# Purpose:
#     Backup AWS DynamoDB tables. Script wrapper for dynamodump.py.
# Usage:
#     Run script with --help option to get usage.

version="1.0.2"

set -o pipefail
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
script_name="$(basename "$0")"
config_path="$script_dir/${script_name/.sh/.cfg}"

# Load configuration settings.
source "$config_path"

if [[ $1 == '--help' ]]; then
    echo 'Usage:'
    echo "    $script_name"
    exit 1
fi

start_time="$(date -u +'%F %T %Z')"
bkup_ts="$(date -d "$start_time" +'%Y%m%dT%H%M%SZ')"

echo "**************************************************"
echo "* Backup AWS DynamoDB Tables"
echo "* Time started: $start_time"
echo "**************************************************"
echo
echo "Hostname: $HOSTNAME"
echo "Backup TS: $bkup_ts"
echo

for table in $tables; do
    date -u +'TS: %Y%m%dT%H%M%SZ'
    echo "Table: $table"
    $dynamodump -r $region --accessKey $accessKey --secretKey $secretKey -m backup -s $table
    #$dynamodump -r $region --accessKey $accessKey --secretKey $secretKey -m restore -s $table -d new_table_name 
    echo
done

date -u +'TS: %Y%m%dT%H%M%SZ'
mv dump "$bkup_ts"

cat > "$bkup_ts/backup_info.txt" <<HEREDOCUMENT
Backup of AWS DynamoDB tables.

bkup_ts: $bkup_ts
script: $script_dir/$script_name
bkup_method: $dynamodump
HEREDOCUMENT

echo "Size of backup:"
du -s "$bkup_ts/"*
echo
echo "**************************************************"
echo "* Time finished: $(date -u +'%F %T %Z')"
echo "**************************************************"
