# DDF Performance Test

Run SoapUI performance tests against a running DDF.

## Some assembly required

Test cases and suites must be manually entered (for now...)

The DDF container must be installed and running inside a network named 'testbed'

## Arguments

When the image is built, SoapUI test suite must be in the `media` and the name given as an ARG (TEST_PACKAGE)

When it is run, TEST_TYPE, NUM_RUNS, and TEST_NAME must be set in environment variables

## To run

Do all of the above, then `docker-compose up` in the `compose` directory

Results will be stored in `compose/results` in a .csv
