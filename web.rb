require 'sinatra'
require 'tempodb'

get '/' do
	"Hello, world1"
end

get '/data/?' do
	content_type :json

	return [].to_json if (params[:start].nil? or Time.parse(params[:start]).nil?)
	return [].to_json if (params[:stop].nil? or Time.parse(params[:stop]).nil?)
	return [].to_json if (params[:step].nil?)

	client = TempoDB::Client.new(ec6b67794d4d43a1b364181fea270d19, a92f52c4f85b45db9d26f95a9e09cf26)

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