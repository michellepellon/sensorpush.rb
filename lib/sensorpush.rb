# frozen_string_literal: true

require_relative 'sensorpush/version'
require_relative 'sensorpush/client'
require_relative 'sensorpush/sensor'
require_relative 'sensorpush/sample'
require_relative 'sensorpush/gateway'

# The Sensorpush module provides functionality for interacting with the SensorPush API
module Sensorpush
  # Custom error class for Sensorpush-specific exceptions
  class Error < StandardError; end

  # Factory method to create a new client instance
  # @param options [Hash] configuration options for the client
  # @return [Sensorpush::Client] a configured client instance
  def self.new(options = {})
    Client.new(options)
  end
end
