# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'

module Sensorpush
  # Client for interacting with the SensorPush API
  class Client
    BASE_URL = 'https://api.sensorpush.com/api/v1'
    BASE_HEADERS = {
      accept: 'application/json',
      "Content-Type": 'application/json'
    }.freeze

    attr_accessor :username, :password, :accesstoken

    # Initialize a new SensorPush client
    # @param options [Hash] configuration options
    # @option options [String] :username SensorPush account email
    # @option options [String] :password SensorPush account password
    # @option options [String] :accesstoken Optional pre-existing access token
    def initialize(options = {})
      @username = options[:username]
      @password = options[:password]
      @accesstoken = options[:accesstoken]
    end

    # Authenticate with the SensorPush API
    # @return [Boolean] true if authentication was successful
    def authenticate
      authorization = authorize
      @accesstoken = get_token(authorization) if authorization
      !@accesstoken.nil?
    end

    # Retrieve all gateways associated with the account
    # @return [Array<Sensorpush::Gateway>] list of gateway objects
    def gateways
      response = api_post('/devices/gateways')
      parse_device_response(response, Sensorpush::Gateway)
    end

    # Retrieve all sensors associated with the account
    # @return [Array<Sensorpush::Sensor>] list of sensor objects
    def sensors
      response = api_post('/devices/sensors')
      parse_device_response(response, Sensorpush::Sensor)
    end

    # Parse API response for device endpoints
    # @param response [Hash] API response
    # @param klass [Class] the class to instantiate for each device
    # @return [Array] list of device objects
    def parse_device_response(response, klass)
      result = []
      response.each do |key, attributes|
        next if key == 'status'

        attributes['id'] = key unless attributes.key?('id')
        result << klass.new(attributes)
      end
      result
    end

    # Retrieve samples for a specific sensor
    # @param id [String] sensor ID
    # @param options [Hash] query parameters
    # @option options [Integer] :limit maximum number of samples to return
    # @option options [Time] :start_time earliest time for samples
    # @option options [Time] :end_time latest time for samples
    # @return [Array<Sensorpush::Sample>] list of sample objects
    def samples(id, options = {})
      body = { sensors: [id] }
      body[:limit] = options[:limit] if options[:limit]
      body[:startTime] = options[:start_time].to_s if options[:start_time]
      body[:endTime] = options[:end_time].to_s if options[:end_time]

      response = api_post('/samples', body)
      samples_array = response.dig('sensors', id)
      return [] unless samples_array

      samples_array.map { |attributes| Sensorpush::Sample.new(attributes) }
    end

    private

    # Create request headers with authorization if available
    # @return [Hash] HTTP headers
    def headers
      headers = BASE_HEADERS.dup
      headers[:Authorization] = accesstoken if accesstoken
      headers
    end

    # Authorize with email and password
    # @return [String, nil] authorization code or nil if failed
    def authorize
      body = { email: username, password: password }
      response = api_post('/oauth/authorize', body)
      response['authorization']
    end

    # Exchange authorization code for access token
    # @param authorization [String] authorization code
    # @return [String, nil] access token or nil if failed
    def get_token(authorization)
      body = { authorization: authorization }
      response = api_post('/oauth/accesstoken', body)
      response['accesstoken']
    end

    # Make a POST request to the API
    # @param endpoint [String] API endpoint path
    # @param body [Hash] request body
    # @return [Hash] parsed JSON response
    def api_post(endpoint, body = {})
      uri = URI(BASE_URL + endpoint)
      response = Net::HTTP.post(uri, body.to_json, headers)
      JSON.parse(response.body)
    rescue JSON::ParserError => e
      raise Error, "Failed to parse API response: #{e.message}"
    rescue Net::HTTPError => e
      raise Error, "HTTP request failed: #{e.message}"
    end
  end
end
