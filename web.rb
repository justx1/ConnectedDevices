require 'sinatra'
require 'tempodb'
require 'mqtt'

# CloudMQTT connection parameters
# Creates a hash with the connection parameters from the cloudmqtt URL in .env, else from the localhost URL
uri = URI.parse ENV['CLOUDMQTT_URL'] || 'mqtt://localhost:1883'
mqtt_conn_opts = {
	remote_host: uri.host,
	remote_port: uri.port,
	username: uri.user,
	password: uri.password,
}

# TempoDB connection parameters from the TempoDB parameters in .env
api_key = ENV['TEMPODB_API_KEY']
api_secret = ENV['TEMPODB_API_SECRET']
api_host = ENV['TEMPODB_API_HOST']
api_port = Integer(ENV['TEMPODB_API_PORT'])
api_secure = ENV['TEMPODB_API_SECURE'] == "False" ? false : true

# Redirect to index.html that loads D3/Cubism
get '/' do
	redirect '/index.html'
end

# API to provide data series to D3/Cubism
get '/data/?' do
	content_type :json

	return [].to_json if (params[:start].nil? or Time.parse(params[:start]).nil?)
	return [].to_json if (params[:stop].nil? or Time.parse(params[:stop]).nil?)
	return [].to_json if (params[:step].nil?)

	dataClient = TempoDB::Client.new( api_key, api_secret, api_host, api_port, api_secure )

	start = Time.parse params[:start]
	stop  = Time.parse params[:stop]
	keys  = ["sfo/arduino/inside/temperature"]
	# Calculate the correct rollup
	step = params[:step].to_i
	# We'll just measure it in minutes
	step_string = "#{step/60000}min"
	dataSet = dataClient.read(start, stop, keys: keys, interval: step_string, function: "mean", tz: "America/Los_Angeles")
	#dataSet.inspect

	 # Map the first series to temperature data points
	 # to do: set up sfo/arduino/outside/temperature in TempoDB as location:sfo.device:arduino.exposure:outside.temperature
	 # read TempoDB docu, as this will set attributes and tags automatically; then parse it out from dataSet generically! 
	response_data = dataSet.first.data.map{ |dp| {ts: dp.ts, value: dp.value, temperature: dp.value } }
	response_data.to_json
end

# Listener that is subscribed to MQTT broker and upon receiving a new message, writes key:value into TempoDB
# to do: need to generically write key:value as topic:message into TempoDB
Thread.new do
	puts "thread"
	client1 = TempoDB::Client.new( api_key, api_secret, api_host, api_port, api_secure )
	if client1
		begin
			puts "tempodb client"
		rescue
			puts "error"
	else

	MQTT::Client.connect(mqtt_conn_opts) do |c|
		# The block will be called when new messages arrive to the topic
		puts "mqtt"
		c.get('#') do |topic,message|
			# puts "#{topic}: #{message}"
			puts "msg received"
			data = [
				TempoDB::DataPoint.new(Time.now.utc, message.to_f)
			]
			client1.write_key(topic, data)
			puts "data written"
			sleep 1
		end
	end
end


=begin

# To Do

# 1. There are two active TempoDB databases. One tied to Heroku, the other one through website sign-up. Remove the latter.
# (there are tow key:secret sets that are confusing)


# Debugging Info

# inspect the dataset to see if it contains content
# dataSet.inspect => [#<TempoDB::DataSet:0x007fc474a58508 @series=#<TempoDB::Series:0x007fc474a4b998 @id="73c8843ef1ac417087c53ab359cf0237", @key="sfo/arduino/temperature/outside", @name="", @attributes={}, @tags=[]>, @start=2013-08-10 07:00:00 UTC, @stop=2013-09-23 07:00:00 UTC, @data=[#<TempoDB::DataPoint:0x007fc474a501a0 @ts=2013-09-23 05:10:00 UTC, @value=31.4>, #<TempoDB::DataPoint:0x007fc474a5aec0 @ts=2013-09-23 06:41:00 UTC, @value=31.4>, #<TempoDB::DataPoint:0x007fc474a5a1f0 @ts=2013-09-23 06:42:00 UTC, @value=31.4>, #<TempoDB::DataPoint:0x007fc474a59a70 @ts=2013-09-23 06:44:00 UTC, @value=31.4>, #<TempoDB::DataPoint:0x007fc474a592a0 @ts=2013-09-23 06:45:00 UTC, @value=31.4>], @summary=#<TempoDB::Summary:0x007fc474a59250 @sum=157.0, @mean=31.4, @max=31.4, @min=31.4, @stddev=1.7763568394002505e-15, @ss=1.262177448353619e-29, @count=5>>]

# Verify if mqtt messages are being dispatched (subscribe)
# test with mosquitto_sub -h broker.cloudmqtt.com -p *port* -t test -u *user* -P *user* (get port/user/pass from CLI: heroku config)
# test with mosquitto_sub -h localhost -p 1883 -t test

# Retrieve dataset from TempoDB through ReST API (get key/secret through CLI: heroku config):
# test dataset: curl -u *key*:*secret* https://api.tempo-db.com/v1/series/key/sfo%2Farduino%2Ftemperature%2Finside/data/?start=2013-09-22T07%3A00%3A00.000Z&end=2013-09-23T06%3A59%3A59.000Z

# Test the data API
# http://localhost:5000/data/?start=20130810&stop=20130923&step=60000
# http://***.herokuapp.com/data/?start=20130810&stop=20130925&step=60000

#publish to MQTT
	MQTT::Client.connect(mqtt_conn_opts) do |c|
		# publish a message to the topic 'test'
		c.publish('test', "The time is: #{Time.now}")
	end


=end