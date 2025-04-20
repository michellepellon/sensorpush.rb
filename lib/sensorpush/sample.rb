# frozen_string_literal: true

require 'date'

module Sensorpush
  # Represents a measurement sample from a SensorPush sensor
  class Sample
    # @return [Float] relative humidity percentage
    attr_reader :humidity

    # @return [Float] temperature in degrees (Celsius or Fahrenheit depending on account settings)
    attr_reader :temperature

    # @return [DateTime] when the sample was recorded
    attr_reader :observed

    # Initialize a new Sample instance
    # @param attributes [Hash] sample attributes from the API
    # @option attributes [Float] "humidity" relative humidity percentage
    # @option attributes [Float] "temperature" temperature reading
    # @option attributes [String] "observed" ISO8601 timestamp when sample was taken
    def initialize(attributes = {})
      @humidity = attributes['humidity']
      @temperature = attributes['temperature']
      @observed = parse_datetime(attributes['observed'])
    end

    private

    # Safely parse a datetime string
    # @param datetime_string [String, nil] ISO8601 datetime string
    # @return [DateTime, nil] parsed DateTime object or nil
    def parse_datetime(datetime_string)
      DateTime.parse(datetime_string) if datetime_string
    rescue ArgumentError
      nil
    end
  end
end
