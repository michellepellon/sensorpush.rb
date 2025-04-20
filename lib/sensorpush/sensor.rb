# frozen_string_literal: true

module Sensorpush
  # Represents a SensorPush sensor device
  class Sensor
    # @return [Boolean] whether the sensor is currently active
    attr_reader :active

    # @return [String] user-defined name of the sensor
    attr_accessor :name

    # @return [String] Bluetooth MAC address of the sensor
    attr_reader :address

    # @return [Float] current battery voltage
    attr_reader :battery_voltage

    # @return [String] unique identifier in the SensorPush API
    attr_reader :id

    # @return [String] hardware identifier of the sensor
    attr_reader :device_id

    # Initialize a new Sensor instance
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
    # @return [Boolean] true if battery voltage is below 2.2V
    def battery_low?
      battery_voltage && battery_voltage < 2.2
    end

    # Returns the battery level as a percentage
    # @return [Float, nil] battery percentage or nil if voltage is unknown
    # @note Assumes 3.0V is 100% and 2.0V is 0%
    def battery_percentage
      return nil unless battery_voltage

      max_voltage = 3.0
      min_voltage = 2.0
      voltage_range = max_voltage - min_voltage

      percentage = ((battery_voltage - min_voltage) / voltage_range) * 100
      [[percentage, 0].max, 100].min # Clamp between 0-100
    end
  end
end
