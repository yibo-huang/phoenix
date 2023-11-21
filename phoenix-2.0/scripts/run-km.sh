#! /bin/bash

set -uo pipefail

# set -x

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

typeset cores=$1
typeset loop_times=$2

typeset executable=./phoenix-2.0/tests/kmeans/kmeans
typeset output_file=kmeans-phoenix-output.txt
typeset tmp_file=tmp-kmeans-phoenix.txt
typeset malloc=/usr/local/lib/libjemalloc.so.2

function ssh_command {
        ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -p 10022 root@localhost ""$@""
}

ssh_command "test -e $output_file && rm -rf $output_file"
for (( i=0; i < $loop_times; ++i ))
do
    echo "Loop $i..."
	ssh_command "LD_PRELOAD=$malloc MR_NUMPROCS=$cores $executable -d 8 -c 2048 -p 5000000 -s 40 >> $output_file 2> error.txt"
done

scp -P 10022 root@localhost:~/$output_file $tmp_file >> /dev/null
grep "\[TIME\]" $tmp_file | awk '{ total += $2 } END { print "[TIME] " total/NR }'
# ssh_command "grep -P '(TIME|LOOP)' $output_file"
