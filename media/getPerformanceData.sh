#!/bin/bash

#################### User Set Variables ####################
#
testName="${TEST_NAME}"
###
basedir="${BASE_DIR}"
outputfile="${basedir}.csv"
#
############################################################

# This function prints the proper usage of this script
#
function printUsage {
  echo "Usage:   $0 [Ingest|Query] [#OfRuns]"
  echo "Example: $0 Ingest 30"
}

# Verify number of parameters
#
if (( $# != 2 )) ; then
  printUsage
  exit 1
fi

# First parameter must be Ingest or Query
#
testType=`echo $1 | tr [:upper:] [:lower:]`
#
case $testType in
  ingest) testcases=( 'Single' 'Bulk 10' 'Bulk 50' 'Bulk 100' )
          testthreads=( 'Primer' '1 Thread' '2 Threads' '5 Threads')
          ;;
  query)  testcases=( 'Single Criteria Tests (252)' 'Keyword and Datatype (550)' 'Keyword and Temporal (550)' 'Spatial and Datatype (550)' )
          testthreads=( 'Primer' '1 Thread' '10 Threads' '20 Threads' )
          ;;
  *)  echo "First parameter must specify Ingest or Query!"
      printUsage
      exit 1
      ;;
esac

# Second parameter must specify the number of runs to execute
#
if [[ "$2" =~ ^[0-9]+$ ]] ; then
  numberOfRuns=$2
else
  echo "Second parameter must be an integer to specify number of runs!"
  printUsage
  exit 1
fi

# This function ...
#
function getData {

  IFS=","

  for tc in ${testcases[@]}; do
    for tt in ${testthreads[@]}; do
      #echo "Run# $1, Test Case: $tc, Test Thread: $tt" >> $outputfile
      cat ${basedir}/Run${1}/${tc}/${tt}/*-statistics.txt | sed -e "s/^/${testName},${tc},${tt},Run${1},date,${tt},elapsed,/" >> $outputfile
    done
  done
}

# main
#
for i in `seq 1 ${numberOfRuns}`; do
  getData $i
done

# UNTIL WE MAKE A BETTER WAY TO REPORT RESULTS....
echo $outputfile
