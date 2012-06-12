#!/bin/bash

# 10 MBs
SOFTWARE_UPDATE_SIZE=10485760

function name {
        cat $1 | grep CTL | awk '{print $2}' | sed 's:^.\(.*\).$:\1:'
}

function date {
        cat $1 | grep CTL | awk '{print $6}'
}

function get_time {
        cat $1 | grep CTL | awk '{print $7}'
}

# get next line
function recvr {
        cat $1 | awk '/CTL/{getline; print}' | awk '{print $1}' | sed 's:^.\(.*\).$:\1:'
}

function file_size {
     file_name="$1"
     file_size=`stat -c%s $file_name`
	RETVAL=$?
	[ $RETVAL -eq 0 ] && echo $file_size
	[ $RETVAL -ne 0 ] && echo 0
}

# 
function get_ctl {
     cat $1 | grep CTL | awk '{print $8}'
}

echo "Starting" 
vipnet_dir=$1
file=$2 
temp_dir=sort_tmp

name_array=(`name $file`)
id_array=(`recvr $file`)
date_array=(`date $file`)
time_array=(`get_time $file`)

mkdir $temp_dir
len=${#id_array[*]}
echo "Number of CTLs found in $file : $len"

rm -f $temp_dir/list.txt
rm -f $temp_dir/list_sorted.txt

# Format and sort list by ID
echo "Sorting by ID"
ind=0
for id in ${id_array[*]}; do
	curr_size=`file_size $vipnet_dir/${name_array[$ind]}`
     output_file=$temp_dir/list.txt
     
     if [ $curr_size -ge $SOFTWARE_UPDATE_SIZE ]
     then 
          output_file=$temp_dir/list_big.txt
     fi

     [ $curr_size -ne 0 ] && echo $id ${name_array[$ind]} ${date_array[$ind]} ${time_array[$ind]} $curr_size >> $output_file
     let "ind++"
done

sort $temp_dir/list.txt > $temp_dir/list_sorted.txt
sort $temp_dir/list_big.txt > $temp_dir/list_big_sorted.txt

echo "Sorting envelopes by date and time"
rm -f $temp_dir/result.txt
# Now do sort by date and time for each ID
for id in ${id_array[*]}; do
     grep -r $id $temp_dir/list_sorted.txt | awk '{print $3,$4,$5,$2}' | awk '{print substr($1,7,4),substr($1,4,2),substr($1,1,2),substr($2,1,2),substr($2,4,2),substr($2,7,2),substr($3,1,20),substr($4,1,20)}' > $temp_dir/id.txt
    	# the first line is the most recent file
     sort -r $temp_dir/id.txt > $temp_dir/id_sorted.txt
     latest=`head -n 1 $temp_dir/id_sorted.txt`
	echo $latest >> $temp_dir/result.txt
done

# Copy-Paste is BAD!
echo "Sorting BIG envelopes by date and time"
for id in ${id_array[*]}; do
     # for Software Updates
     grep -r $id $temp_dir/list_big_sorted.txt | awk '{print $3,$4,$5,$2}' | awk '{print substr($1,7,4),substr($1,4,2),substr($1,1,2),substr($2,1,2),substr($2,4,2),substr($2,7,2),substr($3,1,20),substr($4,1,20)}' > $temp_dir/id_big.txt

     sort -r $temp_dir/id_big.txt > $temp_dir/id_big_sorted.txt
     latest_big=`head -n 1 $temp_dir/id_big_sorted.txt`
	echo $latest_big >> $temp_dir/result_big.txt
done

echo "Sorted. See result.txt and result_big.txt"
# Here we go -> $temp_dir/result.txt has the most recent files
# Now copy these envelopes

echo "Copying envelopes to results and results_big directories"
rm -rf results results_big
mkdir results results_big
final_ctls_array=(`get_ctl $temp_dir/result.txt`)
final_big_ctls_array=(`get_ctl $temp_dir/result_big.txt`)

for ctl in ${final_ctls_array[*]}; do
     cp $vipnet_dir/$ctl ./results
done

for ctl in ${final_big_ctls_array[*]}; do
     cp $vipnet_dir/$ctl ./results_big
done

echo "Done"
# Cleanup
rm $temp_dir/id*.txt $temp_dir/list.txt $temp_dir/list_big.txt
