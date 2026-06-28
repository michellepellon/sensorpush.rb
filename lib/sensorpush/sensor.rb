# frozen_string_literal: true

module Sensorpush
  # Base class created by Data.define
  SensorData = Data.define(:id, :name, :active, :address, :battery_voltage, :device_id)

  # Represents a SensorPush sensor device
  #
  # Sensors are the environmental monitoring devices that measure temperature
  # and humidity. They communicate with nearby gateways via Bluetooth.
  #
  # Sensor is an immutable value object built on Ruby's Data class, providing
  # value-based equality and frozen instances.
  #
  # @note All attributes are read-only. Sensor objects represent a snapshot
  #   of the device state from the API.
  #
  # @example Basic usage
  #   sensors = client.sensors
  #   sensor = sensors.first
  #   puts "#{sensor.name}: #{sensor.battery_percentage}% battery"
  #   puts "Low battery warning!" if sensor.battery_low?
  #
  # @example Using pattern matching
  #   case sensor
  #   in { battery_low: true, name: }
  #     puts "Warning: #{name} has low battery!"
  #   in { active: false, name: }
  #     puts "Sensor #{name} is inactive"
  #   end
  class Sensor < SensorData
    # Battery voltage below which the sensor is considered low
    # @return [Float]
    BATTERY_LOW_THRESHOLD = 2.2

    # Maximum expected battery voltage (100%)
    # @return [Float]
    BATTERY_MAX_VOLTAGE = 3.0

    # Minimum expected battery voltage (0%)
    # @return [Float]
    BATTERY_MIN_VOLTAGE = 2.0

    class << self
      # Create a Sensor from API response attributes
      #
      # Handles the string-keyed hash format returned by the SensorPush API,
      # mapping the API's "deviceId" key to the device_id member.
      #
      # @param attributes [Hash] sensor attributes from the API
      # @option attributes [String] "id" unique API identifier
      # @option attributes [String] "name" user-defined sensor name
      # @option attributes [Boolean] "active" sensor activity status
      # @option attributes [String] "address" Bluetooth MAC address
      # @option attributes [Float] "battery_voltage" current battery level in volts
      # @option attributes [String] "deviceId" hardware identifier
      # @return [Sensor] new immutable Sensor instance
      def from_api(attributes)
        new(
          id: attributes['id'],
          name: attributes['name'],
          active: attributes['active'],
          address: attributes['address'],
          battery_voltage: attributes['battery_voltage'],
          device_id: attributes['deviceId']
        )
      end

      # Override new to support backwards-compatible Hash initialization
      #
      # Allows the existing `Sensor.new(hash_with_string_keys)` interface to
      # continue working while also supporting the Data class keyword syntax.
      #
      # @overload new(attributes)
      #   @param attributes [Hash<String, Object>] API-style hash with string keys
      #   @return [Sensor] new Sensor instance
      #
      # @overload new(id:, name:, active:, address:, battery_voltage:, device_id:)
      #   @return [Sensor] new Sensor instance
      def new(*args, **kwargs)
        if args.size == 1 && args.first.is_a?(Hash) && kwargs.empty?
          hash = args.first
          # String keys (or an empty hash) indicate API response format
          return from_api(hash) if hash.empty? || hash.keys.any? { |k| k.is_a?(String) }

          # Symbol keys - use as kwargs
          return super(**hash)
        end

        super
      end
    end

    # Determines if the sensor's battery is low
    #
    # A battery is considered low when its voltage drops below
    # {BATTERY_LOW_THRESHOLD} (2.2V).
    #
    # @return [Boolean, nil] true if battery voltage is below threshold,
    #   false if above, nil if voltage is unknown
    #
    # @example
    #   if sensor.battery_low?
    #     send_alert("Replace battery in #{sensor.name}")
    #   end
    def battery_low?
      return nil unless battery_voltage

      battery_voltage < BATTERY_LOW_THRESHOLD
    end

    # Returns the battery level as a percentage
    #
    # Calculates the percentage based on a linear scale where:
    # - {BATTERY_MAX_VOLTAGE} (3.0V) = 100%
    # - {BATTERY_MIN_VOLTAGE} (2.0V) = 0%
    #
    # The result is clamped to the 0-100 range to handle edge cases
    # where voltage may be outside the expected range.
    #
    # @return [Float, nil] battery percentage (0-100) or nil if voltage is unknown
    #
    # @example
    #   puts "Battery: #{sensor.battery_percentage.round}%"
    def battery_percentage
      return nil unless battery_voltage

      voltage_range = BATTERY_MAX_VOLTAGE - BATTERY_MIN_VOLTAGE
      percentage = ((battery_voltage - BATTERY_MIN_VOLTAGE) / voltage_range) * 100
      percentage.clamp(0.0, 100.0)
    end

    # Support pattern matching deconstruction
    #
    # Extends the Data-provided deconstruction with computed properties
    # (battery_low, battery_percentage) for convenience in pattern matching.
    #
    # @param keys [Array<Symbol>, nil] specific keys to include, or nil for all
    # @return [Hash] deconstructed attributes including computed values
    #
    # @example Pattern matching with computed values
    #   case sensor
    #   in { battery_low: true, battery_percentage: pct }
    #     puts "Low battery: #{pct.round}%"
    #   end
    #
    # @example Selective deconstruction
    #   sensor.deconstruct_keys([:name, :battery_percentage])
    #   #=> { name: "Living Room", battery_percentage: 85.0 }
    def deconstruct_keys(keys)
      full = super(nil).merge(battery_low: battery_low?, battery_percentage: battery_percentage)
      keys ? full.slice(*keys) : full
    end
  end
end
