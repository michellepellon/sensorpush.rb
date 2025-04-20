# frozen_string_literal: true

require 'date'

module Sensorpush
  # Represents a SensorPush gateway device
  class Gateway
    # @return [String] unique identifier for the gateway
    attr_reader :id

    # @return [String] user-defined name of the gateway
    attr_accessor :name

    # @return [String] firmware version of the gateway
    attr_reader :version

    # @return [String] latest status message from the gateway
    attr_reader :message

    # @return [DateTime] when the gateway was last seen online
    attr_reader :last_seen

    # @return [DateTime] when the gateway last triggered an alert
    attr_reader :last_alert

    # Initialize a new Gateway instance
    # @param attributes [Hash] gateway attributes from the API
    # @option attributes [String] "id" unique identifier
    # @option attributes [String] "name" user-defined name
    # @option attributes [String] "version" firmware version
    # @option attributes [String] "message" status message
    # @option attributes [String] "last_seen" ISO8601 timestamp
    # @option attributes [String] "last_alert" ISO8601 timestamp
    def initialize(attributes = {})
      @id = attributes['id']
      @name = attributes['name']
      @version = attributes['version']
      @message = attributes['message']
      @last_seen = parse_datetime(attributes['last_seen'])
      @last_alert = parse_datetime(attributes['last_alert'])
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
