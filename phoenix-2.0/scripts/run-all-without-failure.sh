#! /bin/bash

set -uo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ $# != 1 ]; then
    echo "Usage: ./run-all-without-failure.sh #loop_times"
    exit -1
fi

loop_times=$1

function ssh_command {
        ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -p 10022 root@localhost ""$@""
}

function loop {
        for cores in 1 2 4 8 16 32
        do
                echo Running with $cores cores
                $@ $cores $loop_times
        done
}

echo ======== Phoenix-2.0 \(malloc\) ========
echo Running WordCount
loop $SCRIPT_DIR/run-wc.sh
echo Running KMeans
loop $SCRIPT_DIR/run-km.sh
echo Running Matrix Multiply
loop $SCRIPT_DIR/run-mm.sh
echo Running Histogram
loop $SCRIPT_DIR/run-histogram.sh
