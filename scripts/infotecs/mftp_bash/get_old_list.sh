#!/bin/bash

# This script is used to generate file containing OUTDATED (older than N days) envelopes list
#
#   Param1: output directory (with tons of envelopes, probably)
#   Param2: num of days 
#
# Run it like this: 
#
#    ./get_old_list.sh.sh /etc/vipnet/out/ 12
#
# Result: 
#	This script generates old_files.txt list
#
# Output example:
#	"Done. Result: 291 files. See old_files.txt" 

vipnet_dir=$1
num_days=$2
OUTPUT_DIR=output

rm -f ${OUTPUT_DIR}/*
mkdir ${OUTPUT_DIR}/

total_files=`ls -al ${vipnet_dir}/* | wc -l`
echo "Directory ${vipnet_dir} contains ${total_files} files"

echo "Starting. Searching CTL files that are older than ${num_days} days"
# Copy files to TMP preserving their date and time!
find ${vipnet_dir}/* -type f -mtime +${num_days} -exec cp -p {} ${OUTPUT_DIR} \;

cd ${OUTPUT_DIR}
ls -al * | grep CTL > ../old_files.txt
cd - 

found_files=`ls -al ${OUTPUT_DIR}/* | wc -l`
echo "Done. Result: ${found_files} files. See old_files.txt"
