# frozen_string_literal: true

require_relative 'parseable'

module Sensorpush
  # Base class created by Data.define
  GatewayData = Data.define(:id, :name, :version, :message, :last_seen, :last_alert)

  # Represents a SensorPush gateway device
  #
  # Gateways are the bridge between your SensorPush sensors and the cloud.
  # They receive data from nearby sensors via Bluetooth and upload it to
  # the SensorPush cloud service.
  #
  # Gateway is an immutable value object built on Ruby's Data class, providing
  # value-based equality and frozen instances.
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
  #   in { last_seen: seen } if seen < Time.now - 86_400
  #     puts "Gateway offline for more than 24 hours"
  #   end
  class Gateway < GatewayData
    extend Parseable

    class << self
      # Create a Gateway from API response attributes
      #
      # Handles the string-keyed hash format returned by the SensorPush API
      # and parses timestamp fields into Time objects.
      #
      # @param attributes [Hash] gateway attributes from the API
      # @option attributes [String] "id" unique identifier
      # @option attributes [String] "name" user-defined name
      # @option attributes [String] "version" firmware version
      # @option attributes [String] "message" status message
      # @option attributes [String] "last_seen" ISO8601 timestamp
      # @option attributes [String] "last_alert" ISO8601 timestamp
      # @return [Gateway] new immutable Gateway instance
      def from_api(attributes)
        new(
          id: attributes['id'],
          name: attributes['name'],
          version: attributes['version'],
          message: attributes['message'],
          last_seen: parse_time(attributes['last_seen']),
          last_alert: parse_time(attributes['last_alert'])
        )
      end

      # Override new to support backwards-compatible Hash initialization
      #
      # Allows the existing `Gateway.new(hash_with_string_keys)` interface to
      # continue working while also supporting the Data class keyword syntax.
      #
      # @overload new(attributes)
      #   @param attributes [Hash<String, Object>] API-style hash with string keys
      #   @return [Gateway] new Gateway instance
      #
      # @overload new(id:, name:, version:, message:, last_seen:, last_alert:)
      #   @return [Gateway] new Gateway instance
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
  end
end
