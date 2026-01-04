# frozen_string_literal: true

require_relative 'sensorpush/version'
require_relative 'sensorpush/parseable'
require_relative 'sensorpush/client'
require_relative 'sensorpush/sensor'
require_relative 'sensorpush/sample'
require_relative 'sensorpush/gateway'

# The Sensorpush module provides functionality for interacting with the SensorPush API
#
# SensorPush is a cloud-based environmental monitoring platform that uses Bluetooth-connected
# sensors (temperature and humidity) that communicate through gateway devices.
#
# @example Basic usage
#   client = Sensorpush.new(username: 'user@example.com', password: 'password')
#   client.authenticate
#   sensors = client.sensors
#   samples = client.samples(sensors.first.id, limit: 100)
#
# @example Using pattern matching (Ruby 4.0+)
#   sensors.each do |sensor|
#     case sensor
#     in { battery_low: true, name: }
#       puts "Warning: #{name} has low battery!"
#     end
#   end
module Sensorpush
  # Base error class for Sensorpush-specific exceptions
  #
  # All Sensorpush errors inherit from this class, allowing you to rescue
  # all gem-related errors with a single rescue clause.
  #
  # @example Rescuing all Sensorpush errors
  #   begin
  #     client.authenticate
  #   rescue Sensorpush::Error => e
  #     puts "Sensorpush error: #{e.message}"
  #   end
  class Error < StandardError; end

  # Raised when authentication with the SensorPush API fails
  #
  # This error is raised when:
  # - Username or password is missing
  # - Credentials are invalid
  # - OAuth token exchange fails
  #
  # @example Handling authentication errors
  #   begin
  #     client.authenticate
  #   rescue Sensorpush::AuthenticationError => e
  #     puts "Authentication failed: #{e.message}"
  #   end
  class AuthenticationError < Error; end

  # Raised when an API request fails
  #
  # This error includes additional context about the failure, including
  # the HTTP status code and any error message from the API.
  #
  # @example Handling API errors
  #   begin
  #     client.sensors
  #   rescue Sensorpush::APIError => e
  #     puts "API error (#{e.status}): #{e.api_message}"
  #   end
  class APIError < Error
    # @return [Integer, nil] HTTP status code from the failed request
    attr_reader :status

    # @return [String, nil] Error message from the API response
    attr_reader :api_message

    # Initialize a new API error
    #
    # @param message [String] Human-readable error description
    # @param status [Integer, nil] HTTP status code
    # @param api_message [String, nil] Error message from API response
    def initialize(message, status: nil, api_message: nil)
      @status = status
      @api_message = api_message
      super(message)
    end
  end

  # Raised when the API response cannot be parsed
  #
  # This typically indicates the API returned invalid JSON or
  # an unexpected response format.
  #
  # @example Handling parse errors
  #   begin
  #     client.sensors
  #   rescue Sensorpush::ParseError => e
  #     puts "Failed to parse response: #{e.message}"
  #   end
  class ParseError < Error; end

  # Factory method to create a new client instance
  #
  # This is the primary entry point for creating a SensorPush API client.
  # It accepts the same options as {Client#initialize}.
  #
  # @param options [Hash] configuration options for the client
  # @option options [String] :username SensorPush account email
  # @option options [String] :password SensorPush account password
  # @option options [String] :accesstoken Pre-existing access token
  # @option options [Integer] :timeout Request timeout in seconds (default: 30)
  # @return [Sensorpush::Client] a configured client instance
  #
  # @example Creating a client with credentials
  #   client = Sensorpush.new(username: 'user@example.com', password: 'password')
  #
  # @example Creating a client with an existing token
  #   client = Sensorpush.new(accesstoken: 'your-access-token')
  def self.new(options = {})
    Client.new(options)
  end
end
