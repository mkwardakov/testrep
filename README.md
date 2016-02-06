#HotelQuickly sample tests

##Task description
https://github.com/HQInterview/Backend-Automation-Test-Engineer

##Test environment
* Linux with rvm
* Ruby 2.2.1p85 (2015-02-26 revision 49769) [x86_64-linux]
* Used gems:
 * json 1.8.1
 * mongo 2.2.2
 * rest-client 1.8.0
 * rspec 3.4.0
 * faker 1.6.1
 * logger 1.2.8

## Running tests
Test cases and all mandatory data is described in _scenario.json_
Test are to be run via:
```
rspec tests.rb
```
Tests are ready to use in CI tools: TeamCity, Jenkins

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
