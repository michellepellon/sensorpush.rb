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

- Ruby 4.0.0 or higher

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

# Or use an existing access token
client = Sensorpush.new(accesstoken: 'your-access-token')
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
  puts "  Battery: #{sensor.battery_percentage.round}%"
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

## Ruby 4.0 Features

This gem takes full advantage of Ruby 4.0 features:

### Pattern Matching

All model classes support pattern matching via `deconstruct_keys`:

```ruby
# Pattern matching with sensors
sensors.each do |sensor|
  case sensor
  in { battery_low: true, name: }
    puts "Warning: #{name} has low battery!"
  in { active: false, name: }
    puts "Sensor #{name} is inactive"
  else
    puts "#{sensor.name} is operating normally"
  end
end

# Pattern matching with samples
samples.each do |sample|
  case sample
  in { temperature: t, humidity: h } if t > 30
    puts "High temperature alert: #{t} at #{h}% humidity"
  in { humidity: h } if h > 80
    puts "High humidity alert: #{h}%"
  else
    # Normal reading
  end
end

# Pattern matching with gateways
gateways.each do |gateway|
  case gateway
  in { last_seen: nil }
    puts "#{gateway.name} has never been online"
  in { last_seen: seen } if seen < DateTime.now - 1
    puts "#{gateway.name} offline for more than 24 hours"
  end
end
```

### Immutable Sample Objects

`Sample` is implemented as a Ruby `Data` class, making it immutable and providing built-in equality:

```ruby
sample1 = client.samples(sensor_id, limit: 1).first
sample2 = client.samples(sensor_id, limit: 1).first

# Value-based equality
sample1 == sample2  # true if same values

# Array deconstruction
humidity, temperature, observed = sample.deconstruct
```

## Advanced Usage

### Custom Timeout

```ruby
# Set a custom request timeout (default is 30 seconds)
client = Sensorpush.new(
  username: 'your-email@example.com',
  password: 'your-password',
  timeout: 60
)
```

### Error Handling

The gem provides a hierarchy of error classes for fine-grained error handling:

```ruby
begin
  client.authenticate
  sensors = client.sensors
rescue Sensorpush::AuthenticationError => e
  # Handle authentication failures (missing credentials, invalid login)
  puts "Authentication failed: #{e.message}"
rescue Sensorpush::ParseError => e
  # Handle invalid API responses
  puts "Failed to parse response: #{e.message}"
rescue Sensorpush::APIError => e
  # Handle API request failures (timeouts, network errors)
  puts "API error: #{e.message}"
  puts "Status: #{e.status}" if e.status
rescue Sensorpush::Error => e
  # Catch-all for any Sensorpush error
  puts "Error: #{e.message}"
end
```

## Upgrading from 1.x

Version 2.0.0 requires Ruby 4.0.0 and includes several breaking changes:

### Breaking Changes

1. **Ruby 4.0.0 required** - The gem now requires Ruby 4.0.0 or higher
2. **Sample is now immutable** - `Sample` objects cannot be modified after creation
3. **Gateway and Sensor names are read-only** - `name` is no longer writable
4. **New error classes** - Errors are now more specific (`AuthenticationError`, `ParseError`, `APIError`)

### Migration Guide

```ruby
# Old (1.x) - mutable name
gateway.name = "New Name"  # No longer works

# Old (1.x) - options hash for samples
client.samples(id, { limit: 100, start_time: time })

# New (2.x) - keyword arguments (backwards compatible)
client.samples(id, limit: 100, start_time: time)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

```bash
# Run tests
bundle exec rake spec

# Run linter
bundle exec rake rubocop

# Run both
bundle exec rake
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/michellepellon/sensorpush.

## License

The gem is available as open source under the terms of the [ISC License](https://opensource.org/licenses/ISC).
