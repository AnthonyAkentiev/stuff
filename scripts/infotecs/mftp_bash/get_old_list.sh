#!/bin/bash

vipnet_dir=$1
num_days=$2
OUTPUT_DIR=output

rm -f ${OUTPUT_DIR}/*
mkdir ${OUTPUT_DIR}/

total_files=`ls -al ${vipnet_dir}/* | wc -l`
echo "Directory ${vipnet_dir} contains ${total_files} files"

echo "Starting. Copying files that are older than ${num_days} days to TMP directory"
# Copy files to TMP preserving their date and time!
#
# CHANGE cp to mv to DELETE files from source directory!
find ${vipnet_dir}/* -type f -mtime +${num_days} -exec mv {} ${OUTPUT_DIR} \;
ls -al ${OUTPUT_DIR}/* > old_envelopes.txt

found_files=`ls -al ${OUTPUT_DIR}/* | wc -l`
echo "Done. Result: ${found_files} files"
