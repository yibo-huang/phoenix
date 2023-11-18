#! /bin/bash

set -uo pipefail

# set -x

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cores=$1
loop_times=$2

executable=phoenix-2.0/tests/matrix_multiply/matrix_multiply
output_file=mm-phoenix-output.txt
tmp_file=tmp-mm-phoenix.txt

function ssh_command {
        ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -p 10022 root@localhost ""$@""
}

ssh_command "test -e $output_file && rm -rf $output_file"
for (( i=0; i < $loop_times; ++i ))
do
    echo "Loop $i..."
	ssh_command "MR_NUMPROCS=$cores $executable 2000 2 >> $output_file 2> error.txt"
done

scp -P 10022 root@localhost:~/$output_file $tmp_file >> /dev/null
grep "\[TIME\]" $tmp_file | awk '{ total += $2 } END { print "[TIME] " total/NR }'
# ssh_command "grep -P '(TIME|LOOP)' $output_file"
