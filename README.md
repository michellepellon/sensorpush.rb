# SensorPush.rb

The SensorPush Ruby library provides convenient access to the [SensorPush API](https://www.sensorpush.com/api) from applications written in the Ruby language.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sensorpush'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install sensorpush
```

## Requirements

- Ruby 3.4.1 or higher

## Usage

### Authentication

```ruby
require 'sensorpush'

# Initialize the client with your SensorPush credentials
client = Sensorpush.new(
  username: 'your-email@example.com',
  password: 'your-password'
)

# Authenticate with the SensorPush API
client.authenticate
```

### Working with Gateways

```ruby
# Get all gateways
gateways = client.gateways

# Access gateway properties
gateways.each do |gateway|
  puts "Gateway: #{gateway.name}"
  puts "  ID: #{gateway.id}"
  puts "  Firmware: #{gateway.version}"
  puts "  Last seen: #{gateway.last_seen}"
end
```

### Working with Sensors

```ruby
# Get all sensors
sensors = client.sensors

# Access sensor properties
sensors.each do |sensor|
  puts "Sensor: #{sensor.name}"
  puts "  ID: #{sensor.id}"
  puts "  Active: #{sensor.active}"
  puts "  Battery: #{sensor.battery_percentage}%"
  puts "  Battery Low: #{sensor.battery_low?}"
end
```

### Retrieving Samples

```ruby
# Get samples for a specific sensor
sensor_id = sensors.first.id
samples = client.samples(
  sensor_id, 
  limit: 100,
  start_time: Time.now - 86400, # 24 hours ago
  end_time: Time.now
)

# Access sample data
samples.each do |sample|
  puts "Sample at #{sample.observed}"
  puts "  Temperature: #{sample.temperature}"
  puts "  Humidity: #{sample.humidity}%"
end
```

## Advanced Usage

### Using a Pre-existing Access Token

If you already have a valid access token, you can initialize the client with it:

```ruby
client = Sensorpush.new(accesstoken: 'your-access-token')
```

### Error Handling

```ruby
begin
  client.authenticate
  sensors = client.sensors
rescue Sensorpush::Error => e
  puts "Error: #{e.message}"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/michellepellon/sensorpush.

## License

The gem is available as open source under the terms of the [ISC License](https://opensource.org/licenses/ISC).