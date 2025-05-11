# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sensorpush do
  it 'has a version number' do
    expect(Sensorpush::VERSION).not_to be nil
  end

  describe '.new' do
    it 'creates a new client instance' do
      client = Sensorpush.new(username: 'test@example.com', password: 'password123')
      expect(client).to be_a(Sensorpush::Client)
      expect(client.username).to eq('test@example.com')
      expect(client.password).to eq('password123')
    end

    it 'passes options to the client' do
      client = Sensorpush.new(accesstoken: 'existing_token')
      expect(client).to be_a(Sensorpush::Client)
      expect(client.accesstoken).to eq('existing_token')
    end
  end

  describe 'error handling' do
    it 'defines a custom error class' do
      expect(Sensorpush::Error.new).to be_a(StandardError)
    end
  end
end
