# frozen_string_literal: true

require 'date'

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
  #       @last_seen = parse_datetime(attributes['last_seen'])
  #     end
  #   end
  module Parseable
    # Safely parse a datetime string from API response
    #
    # @param datetime_string [String, nil] ISO8601 datetime string from the API
    # @return [DateTime, nil] parsed DateTime object or nil if parsing fails
    #
    # @example Parsing a valid datetime
    #   parse_datetime("2024-01-15T12:30:00Z") #=> #<DateTime: 2024-01-15T12:30:00+00:00>
    #
    # @example Handling nil input
    #   parse_datetime(nil) #=> nil
    #
    # @example Handling invalid input
    #   parse_datetime("not a date") #=> nil
    def parse_datetime(datetime_string)
      DateTime.parse(datetime_string) if datetime_string
    rescue ArgumentError
      nil
    end
  end
end
