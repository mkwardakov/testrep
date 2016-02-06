#!/home/user/.rvm/rubies/ruby-2.2.1/bin/ruby
#/usr/local/bin/rspec
#require 'rubygems'
require 'json'
require 'rspec'
require 'rest-client'
require 'faker'
require 'mongo'
#require 'pp'

json = File.read('scenario.json')
testData = JSON.parse(json)
dbParams = testData["database"]
uri = testData["uri"]

def apiPost(data)
	begin
		reply = RestClient::Request.execute(
			:method => :post,
			:url => uri,
			:payload => data.to_json, 
			:headers => {
				:accept => :json,
				"X-Test-track" => "Payment GW test"
			}
		)
	rescue => err
		reply = err.response
	end
	return reply
end

def make_data(test, card)
	# Form request data. Currency, amount and expected reply code is from test description, card data from the scenario
	data = Hash.new
	data["amount"] = test["amount"].to_s
	data["currency"] = test["currency"]
	data["fullName"] = Faker::Name.name
	data["firstName"] = card["first name"] == "" ? Faker::Name.first_name : card["first name"]
	data["lastName"] = card["last name"] == "" ? Faker::Name.last_name : card["last name"]
	data["cardNumber"] = card["number"]
	data["cardCVV"] = card["cvv"] == "" ? rand(10).to_s + rand(10).to_s + rand(10).to_s : card["cvv"]
	data["expireMonth"] = card["expM"]
	data["expireYear"] = card["expY"]
	return data
end

#{"amount":"1","currency":"USD","fullName":"john m. connor","firstName":"john","lastName":"connor","cardNumber":"377127687066544","cardCVV":"123","expireMonth":"3","expireYear":"2021"}
#201
#500 Response Status : 400
#500 AMEX is possible to use only for USD

puts uri
puts dbParams["host"]

RSpec.describe "Payment gateway tests" do

	context "Functional tests" do
		testData["functional tests"].each { |test|
			testCase = "Case " + test["case"].to_s + ". " + test["card type"] + " " + test["currency"]
			requestData = make_data(test, testData[test["card type"]])
			puts requestData.to_json
			it testCase + ": Response code" do
			end
			it testCase + ": Database check" do
			end
		}
	end

	context "Negative tests" do
		testData["negative tests"].each { |test|
			testCase = "Case " + test["case"].to_s + ". " + test["card type"] + " " + test["amount"].to_s + test["currency"]
			requestData = make_data(test, testData[test["card type"]])
			puts testCase
			it testCase + ": Response code" do
			end
		}
	end
end
