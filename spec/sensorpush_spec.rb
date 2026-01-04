# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sensorpush do
  it 'has a version number' do
    expect(Sensorpush::VERSION).not_to be_nil
    expect(Sensorpush::VERSION).to eq('2.0.0')
  end

  it 'has semantic version components' do
    expect(Sensorpush::MAJOR).to eq('2')
    expect(Sensorpush::MINOR).to eq('0')
    expect(Sensorpush::PATCH).to eq('0')
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

    it 'accepts timeout option' do
      client = Sensorpush.new(username: 'test@example.com', password: 'pass', timeout: 60)
      expect(client).to be_a(Sensorpush::Client)
    end
  end

  describe 'error hierarchy' do
    describe Sensorpush::Error do
      it 'is a StandardError' do
        expect(Sensorpush::Error.new).to be_a(StandardError)
      end
    end

    describe Sensorpush::AuthenticationError do
      it 'is a Sensorpush::Error' do
        expect(Sensorpush::AuthenticationError.new).to be_a(Sensorpush::Error)
      end

      it 'can be rescued as Sensorpush::Error' do
        expect do
          raise Sensorpush::AuthenticationError, 'test'
        end.to raise_error(Sensorpush::Error)
      end
    end

    describe Sensorpush::ParseError do
      it 'is a Sensorpush::Error' do
        expect(Sensorpush::ParseError.new).to be_a(Sensorpush::Error)
      end
    end

    describe Sensorpush::APIError do
      it 'is a Sensorpush::Error' do
        expect(Sensorpush::APIError.new('test')).to be_a(Sensorpush::Error)
      end

      it 'accepts status and api_message' do
        error = Sensorpush::APIError.new('Request failed', status: 500, api_message: 'Internal error')
        expect(error.message).to eq('Request failed')
        expect(error.status).to eq(500)
        expect(error.api_message).to eq('Internal error')
      end

      it 'has nil status and api_message by default' do
        error = Sensorpush::APIError.new('Request failed')
        expect(error.status).to be_nil
        expect(error.api_message).to be_nil
      end
    end
  end
end
