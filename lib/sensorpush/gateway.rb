# frozen_string_literal: true

require 'date'
require_relative 'parseable'

module Sensorpush
  # Represents a SensorPush gateway device
  #
  # Gateways are the bridge between your SensorPush sensors and the cloud.
  # They receive data from nearby sensors via Bluetooth and upload it to
  # the SensorPush cloud service.
  #
  # @note All attributes are read-only. Gateway objects represent a snapshot
  #   of the device state from the API.
  #
  # @example Basic usage
  #   gateways = client.gateways
  #   gateway = gateways.first
  #   puts "#{gateway.name} (v#{gateway.version}) - last seen: #{gateway.last_seen}"
  #
  # @example Using pattern matching
  #   case gateway
  #   in { last_seen: nil }
  #     puts "Gateway has never been online"
  #   in { last_seen: seen } if seen < DateTime.now - 1
  #     puts "Gateway offline for more than 24 hours"
  #   end
  class Gateway
    include Parseable

    # @return [String] unique identifier for the gateway
    attr_reader :id

    # @return [String] user-defined name of the gateway
    attr_reader :name

    # @return [String] firmware version of the gateway
    attr_reader :version

    # @return [String] latest status message from the gateway
    attr_reader :message

    # @return [DateTime, nil] when the gateway was last seen online
    attr_reader :last_seen

    # @return [DateTime, nil] when the gateway last triggered an alert
    attr_reader :last_alert

    # Initialize a new Gateway instance
    #
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

    # Control which instance variables appear in #inspect output
    #
    # This Ruby 4.0 feature provides cleaner inspect output by excluding
    # less important attributes like message and last_alert.
    #
    # @return [Array<Symbol>] instance variables to include in inspect
    # @api private
    def instance_variables_to_inspect
      %i[@id @name @version @last_seen]
    end

    # Support pattern matching deconstruction
    #
    # Enables the use of pattern matching with Gateway objects using
    # the `case/in` syntax.
    #
    # @param keys [Array<Symbol>, nil] specific keys to include, or nil for all
    # @return [Hash] deconstructed attributes
    #
    # @example Full deconstruction
    #   case gateway
    #   in { id:, name:, version: }
    #     puts "Gateway #{name} (#{id}) running v#{version}"
    #   end
    #
    # @example Selective deconstruction
    #   gateway.deconstruct_keys([:name, :last_seen])
    #   #=> { name: "Living Room", last_seen: #<DateTime...> }
    def deconstruct_keys(keys)
      hash = {
        id: @id,
        name: @name,
        version: @version,
        message: @message,
        last_seen: @last_seen,
        last_alert: @last_alert
      }
      keys ? hash.slice(*keys) : hash
    end
  end
end
