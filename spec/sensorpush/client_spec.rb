# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sensorpush::Client do
  let(:username) { 'test@example.com' }
  let(:password) { 'password123' }
  let(:api_base_url) { 'https://api.sensorpush.com/api/v1' }

  subject(:client) { described_class.new(username: username, password: password) }

  describe 'constants' do
    it 'defines BASE_URL' do
      expect(described_class::BASE_URL).to eq('https://api.sensorpush.com/api/v1')
    end

    it 'defines DEFAULT_TIMEOUT' do
      expect(described_class::DEFAULT_TIMEOUT).to eq(30)
    end

    it 'defines BASE_HEADERS' do
      expect(described_class::BASE_HEADERS).to eq({
                                                    'Accept' => 'application/json',
                                                    'Content-Type' => 'application/json'
                                                  })
    end
  end

  describe '#initialize' do
    context 'with keyword arguments' do
      it 'sets username and password' do
        expect(client.username).to eq(username)
        expect(client.password).to eq(password)
        expect(client.accesstoken).to be_nil
      end

      it 'uses an existing accesstoken if provided' do
        token = 'existing_token'
        client = described_class.new(accesstoken: token)
        expect(client.accesstoken).to eq(token)
      end

      it 'accepts custom timeout' do
        client = described_class.new(username: username, password: password, timeout: 60)
        expect(client.username).to eq(username)
      end
    end

    context 'with hash argument (backwards compatibility)' do
      it 'accepts hash with symbol keys' do
        client = described_class.new({ username: username, password: password })
        expect(client.username).to eq(username)
        expect(client.password).to eq(password)
      end
    end

    context 'with no arguments' do
      it 'creates client with nil credentials' do
        client = described_class.new
        expect(client.username).to be_nil
        expect(client.password).to be_nil
        expect(client.accesstoken).to be_nil
      end
    end
  end

  describe '#authenticate' do
    let(:authorize_url) { "#{api_base_url}/oauth/authorize" }
    let(:token_url) { "#{api_base_url}/oauth/accesstoken" }
    let(:auth_code) { 'auth_code_123456' }
    let(:access_token) { 'access_token_987654321' }

    context 'when credentials are missing' do
      it 'raises AuthenticationError when username is nil' do
        client = described_class.new(password: password)
        expect { client.authenticate }.to raise_error(
          Sensorpush::AuthenticationError,
          'Username and password required'
        )
      end

      it 'raises AuthenticationError when password is nil' do
        client = described_class.new(username: username)
        expect { client.authenticate }.to raise_error(
          Sensorpush::AuthenticationError,
          'Username and password required'
        )
      end
    end

    context 'when authentication succeeds' do
      before do
        stub_request(:post, authorize_url)
          .with(
            body: { email: username, password: password }.to_json,
            headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
          )
          .to_return(status: 200, body: fixture('authorize_response.json'))

        stub_request(:post, token_url)
          .with(
            body: { authorization: auth_code }.to_json,
            headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
          )
          .to_return(status: 200, body: fixture('accesstoken_response.json'))
      end

      it 'makes the correct API calls' do
        client.authenticate
        expect(WebMock).to have_requested(:post, authorize_url)
        expect(WebMock).to have_requested(:post, token_url)
      end

      it 'returns true' do
        expect(client.authenticate).to be true
      end

      it 'sets the accesstoken' do
        client.authenticate
        expect(client.accesstoken).to eq(access_token)
      end
    end

    context 'when authorization fails' do
      before do
        stub_request(:post, authorize_url)
          .to_return(status: 401, body: { status: 401, message: 'Invalid credentials' }.to_json)
      end

      it 'returns false' do
        expect(client.authenticate).to be false
      end

      it 'does not set the accesstoken' do
        client.authenticate
        expect(client.accesstoken).to be_nil
      end
    end

    context 'when token exchange fails' do
      before do
        stub_request(:post, authorize_url)
          .to_return(status: 200, body: fixture('authorize_response.json'))

        stub_request(:post, token_url)
          .to_return(status: 400, body: { status: 400, message: 'Invalid authorization code' }.to_json)
      end

      it 'returns false' do
        expect(client.authenticate).to be false
      end

      it 'does not set the accesstoken' do
        client.authenticate
        expect(client.accesstoken).to be_nil
      end
    end
  end

  describe '#gateways' do
    let(:gateways_url) { "#{api_base_url}/devices/gateways" }
    let(:access_token) { 'access_token_987654321' }

    before do
      client.accesstoken = access_token
      stub_request(:post, gateways_url)
        .with(headers: { 'Authorization' => access_token, 'Content-Type' => 'application/json',
                         'Accept' => 'application/json' })
        .to_return(status: 200, body: fixture('gateways_response.json'))
    end

    it 'makes the correct API call' do
      client.gateways
      expect(WebMock).to have_requested(:post, gateways_url)
    end

    it 'returns an array of Gateway objects' do
      gateways = client.gateways
      expect(gateways).to be_an(Array)
      expect(gateways.size).to eq(2)
      expect(gateways.first).to be_a(Sensorpush::Gateway)
      expect(gateways.first.id).to eq('gw_123')
      expect(gateways.first.name).to eq('Living Room Gateway')
    end
  end

  describe '#sensors' do
    let(:sensors_url) { "#{api_base_url}/devices/sensors" }
    let(:access_token) { 'access_token_987654321' }

    before do
      client.accesstoken = access_token
      stub_request(:post, sensors_url)
        .with(headers: { 'Authorization' => access_token, 'Content-Type' => 'application/json',
                         'Accept' => 'application/json' })
        .to_return(status: 200, body: fixture('sensors_response.json'))
    end

    it 'makes the correct API call' do
      client.sensors
      expect(WebMock).to have_requested(:post, sensors_url)
    end

    it 'returns an array of Sensor objects' do
      sensors = client.sensors
      expect(sensors).to be_an(Array)
      expect(sensors.size).to eq(2)
      expect(sensors.first).to be_a(Sensorpush::Sensor)
      expect(sensors.first.id).to eq('sensor_abc')
      expect(sensors.first.name).to eq('Living Room Sensor')
    end
  end

  describe '#samples' do
    let(:samples_url) { "#{api_base_url}/samples" }
    let(:access_token) { 'access_token_987654321' }
    let(:sensor_id) { 'sensor_abc' }

    before do
      client.accesstoken = access_token
    end

    context 'with no options' do
      before do
        stub_request(:post, samples_url)
          .with(
            body: { sensors: [sensor_id] }.to_json,
            headers: { 'Authorization' => access_token, 'Content-Type' => 'application/json',
                       'Accept' => 'application/json' }
          )
          .to_return(status: 200, body: fixture('samples_response.json'))
      end

      it 'makes the correct API call' do
        client.samples(sensor_id)
        expect(WebMock).to have_requested(:post, samples_url)
          .with(body: { sensors: [sensor_id] }.to_json)
      end

      it 'returns an array of Sample objects' do
        samples = client.samples(sensor_id)
        expect(samples).to be_an(Array)
        expect(samples.size).to eq(2)
        expect(samples.first).to be_a(Sensorpush::Sample)
        expect(samples.first.temperature).to eq(21.5)
        expect(samples.first.humidity).to eq(45.2)
      end
    end

    context 'with keyword arguments' do
      let(:limit) { 100 }
      let(:start_time) { Time.utc(2023, 4, 15, 12, 0, 0) }
      let(:end_time) { Time.utc(2023, 4, 15, 13, 0, 0) }

      before do
        stub_request(:post, samples_url)
          .with(
            body: {
              sensors: [sensor_id],
              limit: limit,
              startTime: start_time.to_s,
              endTime: end_time.to_s
            }.to_json,
            headers: { 'Authorization' => access_token, 'Content-Type' => 'application/json',
                       'Accept' => 'application/json' }
          )
          .to_return(status: 200, body: fixture('samples_response.json'))
      end

      it 'makes the correct API call with keyword arguments' do
        client.samples(sensor_id, limit: limit, start_time: start_time, end_time: end_time)
        expect(WebMock).to have_requested(:post, samples_url)
          .with(body: {
            sensors: [sensor_id],
            limit: limit,
            startTime: start_time.to_s,
            endTime: end_time.to_s
          }.to_json)
      end
    end

    context 'when sensor id is not found in response' do
      before do
        stub_request(:post, samples_url)
          .to_return(status: 200, body: { sensors: {} }.to_json)
      end

      it 'returns an empty array' do
        samples = client.samples('unknown_sensor')
        expect(samples).to eq([])
      end
    end
  end

  describe 'error handling' do
    let(:samples_url) { "#{api_base_url}/samples" }
    let(:access_token) { 'access_token_987654321' }

    before do
      client.accesstoken = access_token
    end

    context 'with JSON parse error' do
      before do
        stub_request(:post, samples_url)
          .to_return(status: 200, body: 'not valid json')
      end

      it 'raises a Sensorpush::ParseError' do
        expect { client.samples('sensor_abc') }.to raise_error(
          Sensorpush::ParseError,
          /Failed to parse API response/
        )
      end
    end

    context 'with HTTP error response' do
      before do
        stub_request(:post, samples_url)
          .to_return(status: 500, body: '{"status": 500, "message": "Internal server error"}')
      end

      it 'does not raise an error for parseable error responses' do
        expect { client.samples('sensor_abc') }.not_to raise_error
        expect(client.samples('sensor_abc')).to eq([])
      end
    end
  end
end
