#!/bin/bash 

# This script is used to display list of nodes that have OUTDATED (older than N days) envelopes 
#
#   Param1: output directory (with tons of envelopes, probably)
#   Param2: file with 'mftp info' output  
#   Param3: num of days 
#
# Run it like this: 
#
#    mftp info > info.txt
#    mftp stop
#    ./show_ids.sh /etc/vipnet/out/ info.txt 12
#    mftp start 
#
# Result: 
#    you will see output like this
#      <vipnet_node_id> - <num_of_old_envelopes>

function name {
        cat $1 | grep CTL | awk '{print $2}' | sed 's:^.\(.*\).$:\1:'
}

# get next line
function recvr {
        cat $1 | awk '/CTL/{getline; print}' | awk '{print $1}' | sed 's:^.\(.*\).$:\1:'
}

vipnet_dir=$1
file=$2
num_days=$3

OUTPUT_DIR=output

rm -f ${OUTPUT_DIR}/*
mkdir ${OUTPUT_DIR}/

temp_dir=sort_tmp

name_array=(`name $file`)
id_array=(`recvr $file`)

mkdir $temp_dir
len=${#id_array[*]}

output_file=$temp_dir/list.txt
sorted_output_file=$temp_dir/sorted_list.txt 

rm -f $output_file 
rm -f $sorted_output_file

# Format and sort list by ID
ind=0
for id in ${id_array[*]}; do
	file_name=$vipnet_dir/${name_array[$ind]}

	# Check if file is older than N days
	if test `find $file_name -mtime +$num_days`
     then	
		# If CTL is older -> write to temp file  
          echo $id ${name_array[$ind]} >> $output_file
     fi

     let "ind++"
done

# Sort by ID
sort $output_file > $sorted_output_file 

for id in ${id_array[*]}; do
	# Search how many lines with such ID we've got in sorted file 
	ctls_count=`grep -r $id $sorted_output_file | wc -l | tr -d ' '`
	if [ $ctls_count -ne 0 ]
	then 
		# Directly write to console
		echo $id - $ctls_count 
	fi 
done

rm -f $output_file
