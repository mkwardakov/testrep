#!/home/user/.rvm/rubies/ruby-2.2.1/bin/ruby
#/usr/local/bin/rspec
require 'json'
require 'rspec'
require 'rest-client'
require 'faker'
require 'mongo'

json = File.read('scenario.json')
$testData = JSON.parse(json)

$uri = $testData["uri"]

Mongo::Logger.logger.level = ::Logger::WARN #Stop Mongo being noisy
$dbConnect = Mongo::Client.new($testData["database"])

def apiPost(url, data)
	begin
		reply = RestClient.post url, data.to_json, :content_type => :json
	rescue => err
		reply = err.response
	end
	return reply
end

def preparePayment(test)
	# Form request data. Currency, amount and expected reply code is from test description, card data from the scenario
	data = Hash.new
	data["amount"] = test["amount"]
	data["currency"] = test["currency"]
	data["fullName"] = Faker::Name.name

	# If card for test is string, take predefined card which is referred by. Otherwise, use card specified in test
	card = (test["card"].instance_of? String) ? card = $testData[test["card"]].clone : test["card"].clone

	data["firstName"] = (card["first name"] == "") ? Faker::Name.first_name : card["first name"]
	data["lastName"] = (card["last name"] == "") ? Faker::Name.last_name : card["last name"]
	data["cardNumber"] = card["number"]
	data["cardCVV"] = (card["cvv"] == "") ? (rand(10)*100 + rand(10)*10 + rand(10)) : card["cvv"]
	data["expireMonth"] = card["expM"]
	data["expireYear"] = card["expY"]
	return data
end

RSpec.describe "Payment gateway tests" do

	context "Functional tests" do

		$testData["functional tests"].each { |test|

			requestData = preparePayment(test)
			response = apiPost($uri, requestData)

			it "#{test['desc']}: Response code" do
				expect(response.code).to eq test["expect"]
			end

			it "#{test['desc']}: Message" do
				expect(response.body).to match(test["expectmsg"])
			end

			request = $dbConnect['orders'].find("order"=>requestData)
			request.each {|d| puts d }

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

			it "#{test['desc']}: Response code" do
				expect(response.code).to eq test["expect"]
			end

			it "#{test['desc']}: Message" do
				expect(response.body).to match(test["expectmsg"])
			end

		}
	end
end
