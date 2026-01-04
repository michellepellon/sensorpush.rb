# frozen_string_literal: true

require 'date'
require_relative 'parseable'

module Sensorpush
  # Base class created by Data.define
  SampleData = Data.define(:humidity, :temperature, :observed)

  # Represents a measurement sample from a SensorPush sensor
  #
  # Sample is an immutable value object that extends Ruby's Data class.
  # It represents a single environmental reading from a sensor at a specific
  # point in time.
  #
  # @note This class is immutable. Once created, its values cannot be changed.
  #
  # @example Creating a sample from API response
  #   sample = Sensorpush::Sample.new({
  #     'temperature' => 21.5,
  #     'humidity' => 45.2,
  #     'observed' => '2024-01-15T12:30:00Z'
  #   })
  #
  # @example Using pattern matching
  #   case sample
  #   in { temperature: t, humidity: h } if t > 30
  #     puts "High temperature alert: #{t}C at #{h}% humidity"
  #   end
  #
  # @example Array deconstruction
  #   humidity, temperature, observed = sample.deconstruct
  class Sample < SampleData
    extend Parseable

    class << self
      # Create a Sample from API response attributes
      #
      # This factory method handles the string-keyed hash format returned
      # by the SensorPush API and performs datetime parsing.
      #
      # @param attributes [Hash] sample attributes from the API
      # @option attributes [Float] "humidity" relative humidity percentage
      # @option attributes [Float] "temperature" temperature reading
      # @option attributes [String] "observed" ISO8601 timestamp when sample was taken
      # @return [Sample] new immutable Sample instance
      #
      # @example
      #   Sample.from_api({ 'temperature' => 21.5, 'humidity' => 45.2, 'observed' => '2024-01-15T12:30:00Z' })
      def from_api(attributes)
        new(
          humidity: attributes['humidity'],
          temperature: attributes['temperature'],
          observed: parse_datetime(attributes['observed'])
        )
      end

      # Override new to support backwards-compatible Hash initialization
      #
      # This allows the existing `Sample.new(hash_with_string_keys)` interface
      # to continue working while also supporting the Data class keyword syntax.
      #
      # @overload new(attributes)
      #   @param attributes [Hash<String, Object>] API-style hash with string keys
      #   @return [Sample] new Sample instance
      #
      # @overload new(humidity:, temperature:, observed:)
      #   @param humidity [Float, nil] relative humidity percentage
      #   @param temperature [Float, nil] temperature reading
      #   @param observed [DateTime, nil] when sample was taken
      #   @return [Sample] new Sample instance
      #
      # @example Hash initialization (backwards compatible)
      #   Sample.new({ 'temperature' => 21.5, 'humidity' => 45.2 })
      #
      # @example Keyword initialization (Data class style)
      #   Sample.new(temperature: 21.5, humidity: 45.2, observed: DateTime.now)
      def new(*args, **kwargs)
        # Check if called with a single Hash positional argument (API style)
        if args.size == 1 && args.first.is_a?(Hash) && kwargs.empty?
          hash = args.first
          # String keys indicate API response format
          if hash.empty? || hash.keys.any? { |k| k.is_a?(String) }
            return super(
              humidity: hash['humidity'],
              temperature: hash['temperature'],
              observed: parse_datetime(hash['observed'])
            )
          end
          # Symbol keys - use as kwargs
          return super(**hash)
        end

        super
      end
    end
  end
end
