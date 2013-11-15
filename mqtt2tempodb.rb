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

# Listener that is subscribed to MQTT broker and upon receiving a new message, writes key:value into TempoDB
# to do: need to generically write key:value as topic:message into TempoDB
Thread.new do
        client = TempoDB::Client.new( api_key, api_secret, api_host, api_port, api_secure )
        MQTT::Client.connect(mqtt_conn_opts) do |c|
                # The block will be called when new messages arrive to the topic
                c.get('#') do |topic,message|
                        # puts "#{topic}: #{message}"
                        data = [
                                TempoDB::DataPoint.new(Time.now.utc, message.to_f)
                        ]
                        client.write_key(topic, data)
                        sleep 1
                end
        end
end