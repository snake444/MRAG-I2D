#!/bin/bash

PROGNAME=$1
EXECNAME=$2
TIMES=$3
WCLOCK=$4
NTHREADS=$5

NPROCESSES=1
NPROCESSORS=$(($NPROCESSES*$NTHREADS))

BASEPATH="/cluster/scratch_xl/public/wvanrees/MRAG2D/"

SETTINGS=
SETTINGS+=" -study AXISYM"
SETTINGS+=" -bpd 4"
SETTINGS+=" -nthreads ${NTHREADS}"
SETTINGS+=" -ic case1"

SETTINGS+=" -tend 24"

SETTINGS+=" -lcfl 0.1"
SETTINGS+=" -cfl 0.5"
SETTINGS+=" -fc 0.5"

SETTINGS+=" -lmax 5"
SETTINGS+=" -jump 2"
SETTINGS+=" -rtol 1e-5"
SETTINGS+=" -ctol 1e-3"
SETTINGS+=" -uniform 0"
SETTINGS+=" -hilbert 0"

SETTINGS+=" -fmm velocity"
SETTINGS+=" -fmm-theta 0.5"
SETTINGS+=" -core-fmm sse"
SETTINGS+=" -refine-omega-only 0"
SETTINGS+=" -fmm-skip 0"

SETTINGS+=" -vtu 0"
SETTINGS+=" -particles 1"
#SETTINGS+=" -rio free_frame"
SETTINGS+=" -rio rigid_frame"

SETTINGS+=" -adaptfreq 50"
SETTINGS+=" -dumpfreq 10"
SETTINGS+=" -savefreq 1000"

RESTART=" -restart 0"

OPTIONS=${SETTINGS}${RESTART}

if [[ "$(hostname)" == brutus* ]]; then
mkdir -p ${BASEPATH}${EXECNAME}
cp ${0} ${BASEPATH}${EXECNAME}/
cp ctrl.* factory ${BASEPATH}${EXECNAME}/
cp ../makefiles/${PROGNAME} ${BASEPATH}${EXECNAME}/
cd ${BASEPATH}${EXECNAME}
export LD_LIBRARY_PATH=/cluster/work/infk/wvanrees/apps/TBB/tbb41_20120718oss/build/linux_intel64_gcc_cc4.7.0_libc2.12_kernel2.6.32_release/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/cluster/work/infk/cconti/VTK5.8_gcc/lib/vtk-5.8/:$LD_LIBRARY_PATH

export OMP_NUM_THREADS=${NTHREADS}

echo "Submission 0..."
bsub -J ${EXECNAME} -n ${NTHREADS} -R span[ptile=${NTHREADS}] -W ${WCLOCK} -o out time ./${PROGNAME} ${OPTIONS}

RESTART=" -restart 1"
OPTIONS=${SETTINGS}${RESTART}
for (( c=1; c<=${TIMES}-1; c++ ))
do
    echo "Submission $c..."
    bsub -J ${EXECNAME} -n ${NTHREADS} -R span[ptile=${NTHREADS}] -w "ended(${EXECNAME})" -W ${WCLOCK} -o out time ./${PROGNAME} ${OPTIONS}
done
fi