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


# test with mosquitto_sub -h broker.cloudmqtt.com -p 10858 -t test -u nmtbetoo -P m_VLz3-9Ni5O
# test with mosquitto_sub -h localhost -p 1883 -t test

get '/' do
	"Hello, world. This is the TempoDB data API"
	MQTT::Client.connect(mqtt_conn_opts) do |c|
		# publish a message to the topic 'test'
		c.publish('test', "The time is: #{Time.now}")
	end
end

Thread.new do
	client1 = TempoDB::Client.new( api_key, api_secret, api_host, api_port, api_secure )
	MQTT::Client.connect(mqtt_conn_opts) do |c|
		# The block will be called when new messages arrive to the topic
		c.get('#') do |topic,message|
			puts "#{topic}: #{message}"
			puts topic	
			puts message
			data = [
				TempoDB::DataPoint.new(Time.now.utc, message.to_f)
			]
			client1.write_key(topic, data)
			sleep 1
		end
	end
end

get '/data/?' do
	content_type :json

	return [].to_json if (params[:start].nil? or Time.parse(params[:start]).nil?)
	return [].to_json if (params[:stop].nil? or Time.parse(params[:stop]).nil?)
	return [].to_json if (params[:step].nil?)

	dataClient = TempoDB::Client.new( api_key, api_secret, api_host, api_port, api_secure )

	start = Time.parse params[:start]
	stop  = Time.parse params[:stop]
	keys  = ["sfo/arduino/temperature/outside"]
	# Calculate the correct rollup
	step = params[:step].to_i
	# We'll just measure it in minutes
	step_string = "#{step/60000}min"
	dataSet = dataClient.read(start, stop, keys: keys, interval: step_string, function: "mean")
	#dataSet.inspect

	 # Map the first series to temperature data points
	response_data = dataSet.first.data.map{ |dp| {ts: dp.ts, value: dp.value, temperature: dp.value } }
	response_data.to_json

end

# dataSet.inspect => [#<TempoDB::DataSet:0x007fc474a58508 @series=#<TempoDB::Series:0x007fc474a4b998 @id="73c8843ef1ac417087c53ab359cf0237", @key="sfo/arduino/temperature/outside", @name="", @attributes={}, @tags=[]>, @start=2013-08-10 07:00:00 UTC, @stop=2013-09-23 07:00:00 UTC, @data=[#<TempoDB::DataPoint:0x007fc474a501a0 @ts=2013-09-23 05:10:00 UTC, @value=31.4>, #<TempoDB::DataPoint:0x007fc474a5aec0 @ts=2013-09-23 06:41:00 UTC, @value=31.4>, #<TempoDB::DataPoint:0x007fc474a5a1f0 @ts=2013-09-23 06:42:00 UTC, @value=31.4>, #<TempoDB::DataPoint:0x007fc474a59a70 @ts=2013-09-23 06:44:00 UTC, @value=31.4>, #<TempoDB::DataPoint:0x007fc474a592a0 @ts=2013-09-23 06:45:00 UTC, @value=31.4>], @summary=#<TempoDB::Summary:0x007fc474a59250 @sum=157.0, @mean=31.4, @max=31.4, @min=31.4, @stddev=1.7763568394002505e-15, @ss=1.262177448353619e-29, @count=5>>]

=begin

get '/data/?' do

	client = TempoDB::Client.new( api_key, api_secret, api_host, api_port, api_secure )

	out = ""

	start=Time.utc(2000, 1, 1)
	stop=Time.utc(2013, 9, 23)
	series_data = client.read_id("c00c57b643f84e94a4d67191c3e758f9", start, stop)
	puts series_data.first.data
	puts series_data.to_json
	#data.each_key { |key| out += data.to_json + "<br/>"  }
	#data.each{ |data| out += data.to_json + "<br/>"  }
	#response_data = []
	# We need to remove any inconsistencies
	#data.each_with_index do |val, index|
		# Add this datapoint
	#	response_data.push( { value: val.value } )
	#end
	series_data.to_json



	# read all series from TempoDB for user, and track how long it takes
	read_start = Time.now
	series = client.get_series()
	read_end = Time.now

	# build string of JSON representation of user series
	#series.each{ |series| out += series.to_json + "<br/>"  }

	request_end = Time.now

	# write to TempoDB the page load speed, and series read speed
data = [
    TempoDB::DataPoint.new(Time.now.utc, 1.123),
    TempoDB::DataPoint.new(Time.utc(2012, 1, 1, 1, 1, 0), 1.874),
    TempoDB::DataPoint.new(Time.utc(2012, 1, 1, 1, 2, 0), 21.52)
]

client.write_key("sfo/arduino/temperature/inside", data)
	#client.write_key( {'t'=>Time.now ,'key'=>'sfo/arduino/temperature/inside', 'v'=>request_end-request_start} )
	#client.write_bulk( Time.now, [ {'key'=>'heroku-page-load-speed', 'v'=>request_end-request_start}, {'key'=>'heroku-tempodb-read-speed', 'v'=>read_end-read_start} ] )
	out
end



get '/data/?' do
	content_type :json

	return [].to_json if (params[:start].nil? or Time.parse(params[:start]).nil?)
	return [].to_json if (params[:stop].nil? or Time.parse(params[:stop]).nil?)
	return [].to_json if (params[:step].nil?)

	# setup the Tempo client
	api_key = ENV['TEMPODB_API_KEY']
	api_secret = ENV['TEMPODB_API_SECRET']
	api_host = ENV['TEMPODB_API_HOST']
	api_port = Integer(ENV['TEMPODB_API_PORT'])
	api_secure = ENV['TEMPODB_API_SECURE'] == "False" ? false : true

	client = TempoDB::Client.new( api_key, api_secret, api_host, api_port, api_secure )

	start = Time.parse params[:start]
	stop  = Time.parse params[:stop]
	keys  = ["temperature"]
	# Calculate the correct rollup
	step = params[:step].to_i
	# We'll just measure it in minutes
	step_string = "#{step/60000}min"
	logger.info step
	data = client.read(start, stop, keys: keys, interval: step_string, function: "mean")
	#data = data.first.data.map{ |dp| {ts: dp.ts, value: dp.value} }
	data = data.first.data
	response_data = []
	# We need to remove any inconsistencies
	data.each_with_index do |val, index|
		# Add this datapoint
		response_data.push( { value: val.value } )
		if (index + 1) < data.length
			current_time = val.ts
			next_time = data[index+1].ts
			# If there is more than a 5 second difference
			logger.info (next_time - current_time - step / 1000)
			if((next_time - current_time - step / 1000).abs > 5)
				# Let's add the right number of values
				points_needed = ((next_time - current_time) / (step / 1000)).floor
				difference = data[index+1].value - val.value
				points_needed.times { |i| response_data.push({ value: (val.value + difference * i / points_needed.to_f) }) }
			end
		end
	end

	response_data.to_json
end
=end