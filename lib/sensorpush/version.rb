# frozen_string_literal: true

# This module defines version information in both string and component format,
# allowing programmatic access to individual version numbers (MAJOR, MINOR,
# PATCH) that follow semantic versioning principles.
#
# == Usage Examples
#
#   # Access the complete version string
#   Sensorpush::VERSION  #=> "0.2.0"
#
#   # Access individual version components
#   Sensorpush::MAJOR    #=> "0"
#   Sensorpush::MINOR    #=> "2"
#   Sensorpush::PATCH    #=> "0"
#
# == Version Components
#
# - MAJOR: Incremented for incompatible API changes
# - MINOR: Incremented for backward-compatible functionality additions
# - PATCH: Incremented for backward-compatible bug fixes
module Sensorpush
  # The current version of the Sensorpush gem
  VERSION = '0.2.0'
  # Version components for programmatic access
  MAJOR, MINOR, PATCH = VERSION.split('.')
end
