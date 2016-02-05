#HotelQuickly sample tests

##Task description
https://github.com/HQInterview/Backend-Automation-Test-Engineer

##Test environment
	* Linux with rvm
	* Ruby 2.2.1p85 (2015-02-26 revision 49769) [x86_64-linux]
	* Used gems:
		* json (1.8.1)
		* minitest (5.4.3)
		* rvm (1.11.3.9)
		* test-unit (3.0.8)

## Running tests
	Test cases and all mandatory data is described in test-scenario.json
	Test are to be run via:
		```
		rspec tests.rb
		```
	Tests are ready to use in CI:
		* When deployment ready, TeamCity/Jenkins deploys latest automated tests from repository
		* Then starts Docker container with shared volume with tests and run them
		* CI tool gets test results via rspec runner

##Test scenario:

###Functional tests
Each case: Make payment using specified card, currency
Tests:
	1. Test Check reply
	2. Check used gw
	3. Check order data is in DB
	4. Check response from payment GW is in DB

|Case #:	|Card type		|Currency					|Reply		|Payment GW		|Check DB
|1			|AMEX			|USD						|OK			|Paypal			|Yes
|2-6		|AMEX			|EUR,THB,HKD,SGD,AUD		|Not OK		|n/a			|No
|7-12		|VISA,MC		|USD,EUR,AUD				|OK			|Paypal			|Yes
|13-18		|VISA,MC		|THB,HKD,SGD				|OK			|Braintree		|Yes

###Negative tests
Each case (1-36): Make payments trying all card type/currency combinations of amount 0 and -1
Tests:
	1. Check reply (expect Not OK)


