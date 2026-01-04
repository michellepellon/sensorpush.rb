# frozen_string_literal: true

module Sensorpush
  # Represents a SensorPush sensor device
  #
  # Sensors are the environmental monitoring devices that measure temperature
  # and humidity. They communicate with nearby gateways via Bluetooth.
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
  class Sensor
    # Battery voltage below which the sensor is considered low
    # @return [Float]
    BATTERY_LOW_THRESHOLD = 2.2

    # Maximum expected battery voltage (100%)
    # @return [Float]
    BATTERY_MAX_VOLTAGE = 3.0

    # Minimum expected battery voltage (0%)
    # @return [Float]
    BATTERY_MIN_VOLTAGE = 2.0

    # @return [Boolean, nil] whether the sensor is currently active
    attr_reader :active

    # @return [String, nil] user-defined name of the sensor
    attr_reader :name

    # @return [String, nil] Bluetooth MAC address of the sensor
    attr_reader :address

    # @return [Float, nil] current battery voltage
    attr_reader :battery_voltage

    # @return [String, nil] unique identifier in the SensorPush API
    attr_reader :id

    # @return [String, nil] hardware identifier of the sensor
    attr_reader :device_id

    # Initialize a new Sensor instance
    #
    # @param attributes [Hash] sensor attributes from the API
    # @option attributes [Boolean] "active" sensor activity status
    # @option attributes [String] "name" user-defined sensor name
    # @option attributes [String] "address" Bluetooth MAC address
    # @option attributes [Float] "battery_voltage" current battery level in volts
    # @option attributes [String] "id" unique API identifier
    # @option attributes [String] "deviceId" hardware identifier
    def initialize(attributes = {})
      @active = attributes['active']
      @name = attributes['name']
      @address = attributes['address']
      @battery_voltage = attributes['battery_voltage']
      @id = attributes['id']
      @device_id = attributes['deviceId']
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
      percentage.clamp(0, 100)
    end

    # Control which instance variables appear in #inspect output
    #
    # This Ruby 4.0 feature provides cleaner inspect output by showing
    # only the most relevant attributes.
    #
    # @return [Array<Symbol>] instance variables to include in inspect
    # @api private
    def instance_variables_to_inspect
      %i[@id @name @active @battery_voltage]
    end

    # Support pattern matching deconstruction
    #
    # Enables the use of pattern matching with Sensor objects using
    # the `case/in` syntax. Includes computed properties for convenience.
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
      hash = {
        id: @id,
        name: @name,
        active: @active,
        address: @address,
        battery_voltage: @battery_voltage,
        device_id: @device_id,
        battery_low: battery_low?,
        battery_percentage: battery_percentage
      }
      keys ? hash.slice(*keys) : hash
    end
  end
end
