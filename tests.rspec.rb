#!/usr/local/bin/rspec
require 'json'
require 'rspec'
require 'rest-client'
require 'faker'
require 'mongo'
require 'logger'

logger = Logger.new('testrun.log')
scenario = (ARGV.empty? || File.readable?(ARGV[0])) ? 'scenario.json' : ARGV[0] #If readable file is set to command line option, use it. Otherwise, default scenario.json
json = File.read(scenario) and $testData = JSON.parse(json) and $uri = $testData["uri"]
Mongo::Logger.logger.level = ::Logger::WARN #Stop Mongo being noisy
$dbConnect = Mongo::Client.new($testData["database"])

logger.info("Used #{scenario} file to load tests from")
logger.info("Target function is #{$uri}")
logger.info("Database connection string is #{$testData["database"]}")

def apiPost(url, data) #Goal of the function is to handle exceptions which RestClient raises on not 2xx response codes
	begin
		reply = RestClient.post url, data.to_json, :content_type => :json
	rescue => err
		reply = err.response
	end
	return reply
end

def preparePayment(test) # Form request data. Nothing interesting in here
	data = Hash.new
	data["amount"] = test["amount"]
	data["currency"] = test["currency"]
	data["fullName"] = Faker::Name.name
	# If card for test is string, take predefined card which is referred by. Otherwise, use card specified in test
	card = (test["card"].instance_of? String) ? card = $testData[test["card"]].clone : test["card"].clone
	data["firstName"] = (card["first name"] == "") ? Faker::Name.first_name : card["first name"]
	data["lastName"] = (card["last name"] == "") ? Faker::Name.last_name : card["last name"]
	data["cardNumber"] = card["number"]
	data["cardCVV"] = (card["cvv"] == "") ? ((rand(9)+1)*100 + rand(10)*10 + rand(10)) : card["cvv"]
	data["expireMonth"] = card["expM"]
	data["expireYear"] = card["expY"]
	return data
end

RSpec.describe "Payment gateway tests" do

	context "Functional tests" do

		$testData["functional tests"].each { |test|

			requestData = preparePayment(test)
			response = apiPost($uri, requestData)

			logger.info("Test description: #{test['desc']}")
			logger.info("Payload: #{requestData.to_s}")
			logger.info("Response: Code=#{response.code} Body=#{response.body}")

			it "#{test['desc']}: Response code" do
				expect(response.code).to eq test["expect"]
			end

			it "#{test['desc']}: Message" do
				expect(response.body).to include(test["expectmsg"])
			end

			request = $dbConnect['orders'].find("order"=>requestData)
			logger.info("Found #{request.count} document(s) in the collection")
			logger.info("Library has used #{request.to_a[0]["provider"]} as payment gateway")

			it "#{test['desc']}: Database check" do
				expect(request.count).to eq 1
			end

			it "#{test['desc']}: Correct gateway check" do
				expect(request.to_a[0]["provider"]).to eq test["expectgw"]
			end
		}
	end

	context "Negative tests" do

		$testData["negative tests"].each { |test|

			requestData = preparePayment(test)
			response = apiPost($uri, requestData)

			logger.info("Test description: #{test['desc']}")
			logger.info("Payload: #{requestData.to_s}")
			logger.info("Response: Code=#{response.code} Body=#{response.body}")

			it "#{test['desc']}: Response code" do
				expect(response.code).to eq test["expect"]
			end

			it "#{test['desc']}: Message" do
				expect(response.body).to include(test["expectmsg"])
			end

		}
	end
end
