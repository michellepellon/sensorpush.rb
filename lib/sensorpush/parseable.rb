# frozen_string_literal: true

require 'time'

module Sensorpush
  # Provides parsing utilities for model classes
  #
  # This module contains shared parsing logic used across multiple model classes
  # to ensure consistent handling of API response data.
  #
  # @example Including in a class
  #   class Gateway
  #     include Parseable
  #
  #     def initialize(attributes)
  #       @last_seen = parse_time(attributes['last_seen'])
  #     end
  #   end
  module Parseable
    # Safely parse a timestamp string from an API response
    #
    # @param time_string [String, nil] ISO8601 timestamp string from the API
    # @return [Time, nil] parsed Time object or nil if parsing fails
    #
    # @example Parsing a valid timestamp
    #   parse_time("2024-01-15T12:30:00Z") #=> 2024-01-15 12:30:00 UTC
    #
    # @example Handling nil input
    #   parse_time(nil) #=> nil
    #
    # @example Handling invalid input
    #   parse_time("not a date") #=> nil
    def parse_time(time_string)
      Time.parse(time_string) if time_string
    rescue ArgumentError
      nil
    end
  end
end
