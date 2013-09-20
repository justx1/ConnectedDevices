require 'sinatra'
require 'tempodb'
require 'mqtt'

# Create a hash with the connection parameters from the URL
uri = URI.parse ENV['CLOUDMQTT_URL'] || 'mqtt://localhost:1883'
conn_opts = {
	remote_host: uri.host,
	remote_port: uri.port,
	username: uri.user,
	password: uri.password,
}

Thread.new do
	#MQTT::Client.connect(conn_opts) do |c|
	MQTT::Client.connect('localhost') do |c|
		# The block will be called when you messages arrive to the topic
		c.get('test') do |topic, message|
			puts "#{topic}: #{message}"
			c.publish('test', 'Fucker')
			sleep 1
		end
	end
end

get '/' do
	"Hello, world. This is the TempoDB data API"
	#MQTT::Client.connect(conn_opts) do |c|
	MQTT::Client.connect('localhost') do |c|		
		# publish a message to the topic 'test'
		c.publish('test', 'Fucker2')
	end
end

=begin
get '/data/?' do
  request_start = Time.now

  # setup the Tempo client
  api_key = ENV['TEMPODB_API_KEY']
  api_secret = ENV['TEMPODB_API_SECRET']
  api_host = ENV['TEMPODB_API_HOST']
  api_port = Integer(ENV['TEMPODB_API_PORT'])
  api_secure = ENV['TEMPODB_API_SECURE'] == "False" ? false : true

  client = TempoDB::Client.new( api_key, api_secret, api_host, api_port, api_secure )

  out = ""

  # read all series from TempoDB for user, and track how long it takes
  read_start = Time.now
  series = client.get_series()
  read_end = Time.now

  # build string of JSON representation of user series
  series.each{ |series| out += series.to_json + "<br/>"  }

  request_end = Time.now

  # write to TempoDB the page load speed, and series read speed
  client.write_bulk( Time.now, [ {'key'=>'heroku-page-load-speed', 'v'=>request_end-request_start}, {'key'=>'heroku-tempodb-read-speed', 'v'=>read_end-read_start} ] )
  out
end


get '/' do
	"Hello, world1"
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