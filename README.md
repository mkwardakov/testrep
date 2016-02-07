#HotelQuickly assignment

##Task description
The script covers payment library with automation tests

For the details, see https://github.com/HQInterview/Backend-Automation-Test-Engineer

##Test environment
Script is developed using environment below
* Ubuntu Linux 14.04 LTS
* [RVM 1.26.11] (https://rvm.io/)
* Ruby 2.2.1
* Used gems:
 * json 1.8.1
 * mongo 2.2.2
 * rest-client 1.8.0
 * rspec 3.4.0
 * faker 1.6.1
 * logger 1.2.8

##How to run
To start testing, just use:
```
rspec tests.rb
```
or
```
rspec tests.rb your_scenario.json
```
Test cases and all mandatory data is described in _scenario.json_ which is used by default if no json file is specified

Tests are ready to use in CI tools: *TeamCity*, *Jenkins*

###Work log
The script writes work log to testrun.log using standard library.

Log level is INFO

##Test scenario:

###Functional tests
Each case: Make payment

Tests:

1. Check reply code
2. Check reply message
3. Check order data is in DB
4. Check payment gateway

There are 13 cases: 1 is for AmEx, VISA and MC have 6 each

###Negative tests
Set of negative tests: wrong values in payload and 5 AmEx cases with improper currency

Each case: Make payment

Tests:

1. Check reply code
2. Check reply message

This section has 12 cases.
