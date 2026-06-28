# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'
require 'time'

module Sensorpush
  # Client for interacting with the SensorPush API
  #
  # The Client class handles all HTTP communication with the SensorPush API,
  # including authentication, device retrieval, and sample queries.
  #
  # @example Basic usage with credentials
  #   client = Sensorpush::Client.new(username: 'user@example.com', password: 'password')
  #   client.authenticate
  #   sensors = client.sensors
  #   samples = client.samples(sensors.first.id, limit: 100)
  #
  # @example Using an existing access token
  #   client = Sensorpush::Client.new(accesstoken: 'your-token')
  #   sensors = client.sensors
  class Client
    # Base URL for the SensorPush API
    # @return [String]
    BASE_URL = 'https://api.sensorpush.com/api/v1'

    # Default headers sent with every request
    # @return [Hash]
    BASE_HEADERS = {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }.freeze

    # Default request timeout in seconds
    # @return [Integer]
    DEFAULT_TIMEOUT = 30

    # @return [String, nil] SensorPush account email
    attr_accessor :username

    # @return [String, nil] SensorPush account password
    attr_accessor :password

    # @return [String, nil] OAuth access token
    attr_accessor :accesstoken

    # Initialize a new SensorPush client
    #
    # @param username [String, nil] SensorPush account email
    # @param password [String, nil] SensorPush account password
    # @param accesstoken [String, nil] Optional pre-existing access token
    # @param timeout [Integer] Request timeout in seconds (default: 30)
    #
    # @example With credentials
    #   client = Sensorpush::Client.new(username: 'user@example.com', password: 'secret')
    #
    # @example With existing token
    #   client = Sensorpush::Client.new(accesstoken: 'your-access-token')
    #
    # @example With custom timeout
    #   client = Sensorpush::Client.new(username: 'user@example.com', password: 'secret', timeout: 60)
    def initialize(username: nil, password: nil, accesstoken: nil, timeout: DEFAULT_TIMEOUT)
      @username = username
      @password = password
      @accesstoken = accesstoken
      @timeout = timeout
    end

    # Backwards compatible Hash-based initialization
    #
    # Allows the existing `Client.new(options_hash)` interface to continue
    # working while also supporting keyword arguments.
    #
    # @param options [Hash] configuration options
    # @return [Client] new client instance
    # @api private
    def self.new(options = {})
      return super(**options) if options.is_a?(Hash) && !options.empty?

      super()
    end

    # Control which instance variables appear in #inspect output
    #
    # Redacts sensitive credentials so the password and access token are
    # never disclosed through inspect output (logs, exception reporters,
    # REPL history). Only non-sensitive attributes are exposed.
    #
    # @return [Array<Symbol>] instance variables to include in inspect
    # @api private
    def instance_variables_to_inspect
      %i[@username @timeout]
    end

    # Authenticate with the SensorPush API
    #
    # Performs the OAuth2 authorization flow:
    # 1. Sends credentials to get an authorization code
    # 2. Exchanges the code for an access token
    #
    # @return [Boolean] true if authentication was successful
    # @raise [AuthenticationError] if username or password is missing
    #
    # @example
    #   if client.authenticate
    #     puts "Authenticated successfully"
    #   else
    #     puts "Authentication failed"
    #   end
    def authenticate
      raise AuthenticationError, 'Username and password required' if username.nil? || password.nil?

      authorization = authorize
      @accesstoken = get_token(authorization) if authorization
      !@accesstoken.nil?
    end

    # Retrieve all gateways associated with the account
    #
    # @return [Array<Sensorpush::Gateway>] list of gateway objects
    # @raise [ParseError] if the API response cannot be parsed
    # @raise [APIError] if the HTTP request fails
    #
    # @example
    #   gateways = client.gateways
    #   gateways.each do |gw|
    #     puts "#{gw.name} - last seen: #{gw.last_seen}"
    #   end
    def gateways
      response = api_post('/devices/gateways')
      parse_device_response(response, Gateway)
    end

    # Retrieve all sensors associated with the account
    #
    # @return [Array<Sensorpush::Sensor>] list of sensor objects
    # @raise [ParseError] if the API response cannot be parsed
    # @raise [APIError] if the HTTP request fails
    #
    # @example
    #   sensors = client.sensors
    #   sensors.each do |sensor|
    #     puts "#{sensor.name}: #{sensor.battery_percentage.round}% battery"
    #   end
    def sensors
      response = api_post('/devices/sensors')
      parse_device_response(response, Sensor)
    end

    # Retrieve samples for a specific sensor
    #
    # Fetches historical measurement data from the specified sensor.
    # Supports limiting results and filtering by time range.
    #
    # @param id [String] sensor ID
    # @param limit [Integer, nil] maximum number of samples to return
    # @param start_time [Time, nil] earliest time for samples
    # @param end_time [Time, nil] latest time for samples
    # @return [Array<Sensorpush::Sample>] list of sample objects
    # @raise [ParseError] if the API response cannot be parsed
    # @raise [APIError] if the HTTP request fails
    #
    # @example Get last 100 samples
    #   samples = client.samples(sensor.id, limit: 100)
    #
    # @example Get samples from the last hour
    #   samples = client.samples(sensor.id, start_time: Time.now - 3600)
    #
    # @example Get samples in a time range
    #   samples = client.samples(sensor.id,
    #     start_time: Time.utc(2024, 1, 1),
    #     end_time: Time.utc(2024, 1, 2),
    #     limit: 1000
    #   )
    def samples(id, limit: nil, start_time: nil, end_time: nil)
      body = { sensors: [id] }
      body[:limit] = limit if limit
      body[:startTime] = format_time(start_time) if start_time
      body[:endTime] = format_time(end_time) if end_time

      response = api_post('/samples', body)

      response.dig('sensors', id)&.map { |attrs| Sample.new(attrs) } || []
    end

    private

    # Format a time value as an ISO 8601 string for the API
    #
    # The SensorPush API expects ISO 8601 / RFC 3339 timestamps
    # (e.g. "2024-01-01T00:00:00Z"). Time and DateTime are converted via
    # #iso8601; strings (assumed already formatted) are passed through.
    #
    # @param value [Time, DateTime, String] the time value to format
    # @return [String] ISO 8601 timestamp
    def format_time(value)
      value.respond_to?(:iso8601) ? value.iso8601 : value.to_s
    end

    # Parse API response for device endpoints
    #
    # @param response [Hash] API response
    # @param klass [Class] the class to instantiate for each device
    # @return [Array] list of device objects
    def parse_device_response(response, klass)
      response.filter_map do |key, attributes|
        next if key == 'status'

        attributes['id'] = key unless attributes.key?('id')
        klass.new(attributes)
      end
    end

    # Create request headers with authorization if available
    #
    # @return [Hash] HTTP headers
    def headers
      h = BASE_HEADERS.dup
      h['Authorization'] = accesstoken if accesstoken
      h
    end

    # Authorize with email and password
    #
    # @return [String, nil] authorization code or nil if failed
    def authorize
      body = { email: username, password: password }
      response = api_post('/oauth/authorize', body)
      response['authorization']
    end

    # Exchange authorization code for access token
    #
    # @param authorization [String] authorization code
    # @return [String, nil] access token or nil if failed
    def get_token(authorization)
      body = { authorization: authorization }
      response = api_post('/oauth/accesstoken', body)
      response['accesstoken']
    end

    # Make a POST request to the API
    #
    # @param endpoint [String] API endpoint path
    # @param body [Hash] request body
    # @return [Hash] parsed JSON response
    # @raise [ParseError] if response is not valid JSON
    # @raise [APIError] if HTTP request fails
    def api_post(endpoint, body = {})
      uri = URI(BASE_URL + endpoint)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = @timeout
      http.read_timeout = @timeout

      request = Net::HTTP::Post.new(uri.path, headers)
      request.body = body.to_json

      response = http.request(request)
      JSON.parse(response.body)
    rescue JSON::ParserError => e
      raise ParseError, "Failed to parse API response: #{e.message}"
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      raise APIError, "Request timed out: #{e.message}"
    rescue SystemCallError, SocketError => e
      raise APIError, "HTTP request failed: #{e.message}"
    end
  end
end
