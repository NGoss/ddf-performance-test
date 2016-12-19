#!/bin/bash

if [ -z $TEST_TYPE ] ; then
	echo "TEST_TYPE must be defined. Please define TEST_TYPE and re-run runtest.sh"
	exit 1
fi

if [ -z $NUM_RUNS ] ; then
	echo "NUM_RUNS must be defined. Please define NUM_RUNS and re-run runtest.sh"
	exit 1
fi

if [ -z $TEST_NAME ] ; then
	echo "TEST_NAME must be defined. Please define TEST_NAME and re-run runtest.sh"
	exit 1
fi

echo "All parameters defined. Starting test...."

# Wait for the ddf to install
# DISABLED FOR TESTING PURPOSES
#sleep 3m

#################### User Set Variables ####################
#
httpHost=ddf
ddfBin=/opt/ddf/bin
testconfig=${TEST_DIRECTORY}/${TEST_PACKAGE}
basedir=${TEST_DIRECTORY}/output/Performance_Test_$(date "+%Y-%m-%d-%H%M")
#
############################################################

if [[ $TEST_TYPE = ingest ]]; then
	testsuite='SOAP Ingest Performance'
	testcases=('Single','Bulk 10','Bulk 50','Bulk 100')
	testthreads=('Primer','1 Thread','2 Threads','5 Threads')
elif [[ $TEST_TYPE = query ]]; then
	testsuite='SOAP Query Performance'
	testcases=('Single Criteria Tests (252),Keyword and Datatype (550),Keyword and Temporal (550),Spatial and Datatype (550)')
	testthreads=('Primer','1 Thread','10 Threads','20 Threads')
else
	echo "TEST_TYPE must specify Ingest or Query!"
	exit 1
fi

# Second parameter must specify the number of runs to execute
#
if [[ "$NUM_RUNS" =~ ^[0-9]+$ ]] ; then
	numberOfRuns=$NUM_RUNS
else
	echo "NUM_RUNS must be an integer to specify number of runs!"
	exit 1
fi

# This function runs the requested performance
# test, the database is cleared if necessary
#
function runme {

	# Clear the database for an Ingest test
	#
	if [[ $TEST_TYPE = ingest ]] ; then
		echo "Shutting down the DDF..."
		docker exec ddf ${ddfBin}/stop
		sleep 60
		echo "Clearing out the Solr database..."
		docker exec ddf rm -f ${DDF_HOME}/solr/collection1/data/index/*
		sleep 60
		echo "Starting the DDF..."
		docker exec ddf ${ddfBin}/start
		sleep 120
	fi

	# Run the test
	#
	program=loadtestrunner.sh
	IFS=","
	#
	cd ${SOAPUI_HOME}/bin
	#
	echo "Test Suite: $testsuite"
	for tc in $testcases; do
		echo "  Test Case: $tc"
		for tt in $testthreads; do
			echo "    Test Thread: $tt"
			./$program -s "$testsuite" -c $tc -l $tt -h $httpHost -r -f "$basedir/Run${1}/$tc/$tt" $testconfig
			sleep 60
		done
	done
}

# main
#
genKeys=true
#
for i in `seq 1 ${numberOfRuns}`; do
	echo "Run# $i"
	runme $i
done

# Make basedir visible to data script
export BASE_DIR=${basedir}

cd /home/
./getPerformanceData.sh $TEST_TYPE $NUM_RUNS
