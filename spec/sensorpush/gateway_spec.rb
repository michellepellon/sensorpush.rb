# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sensorpush::Gateway do
  let(:attributes) do
    {
      'id' => 'gw_123',
      'name' => 'Living Room Gateway',
      'version' => '1.2.3',
      'message' => 'OK',
      'last_seen' => '2023-04-15T12:30:45Z',
      'last_alert' => '2023-04-10T08:15:20Z'
    }
  end

  subject(:gateway) { described_class.new(attributes) }

  describe '#initialize' do
    it 'sets attributes correctly' do
      expect(gateway.id).to eq('gw_123')
      expect(gateway.name).to eq('Living Room Gateway')
      expect(gateway.version).to eq('1.2.3')
      expect(gateway.message).to eq('OK')
      expect(gateway.last_seen).to be_a(DateTime)
      expect(gateway.last_seen.to_s).to eq('2023-04-15T12:30:45+00:00')
      expect(gateway.last_alert).to be_a(DateTime)
      expect(gateway.last_alert.to_s).to eq('2023-04-10T08:15:20+00:00')
    end

    it 'handles missing attributes' do
      gateway = described_class.new({})
      expect(gateway.id).to be_nil
      expect(gateway.name).to be_nil
      expect(gateway.version).to be_nil
      expect(gateway.message).to be_nil
      expect(gateway.last_seen).to be_nil
      expect(gateway.last_alert).to be_nil
    end
  end

  describe 'datetime parsing' do
    context 'with valid datetime strings' do
      it 'parses last_seen correctly' do
        expect(gateway.last_seen).to be_a(DateTime)
        expect(gateway.last_seen.to_s).to eq('2023-04-15T12:30:45+00:00')
      end

      it 'parses last_alert correctly' do
        expect(gateway.last_alert).to be_a(DateTime)
        expect(gateway.last_alert.to_s).to eq('2023-04-10T08:15:20+00:00')
      end
    end

    context 'with invalid datetime strings' do
      it 'returns nil for invalid last_seen' do
        gateway = described_class.new(attributes.merge('last_seen' => 'not-a-date'))
        expect(gateway.last_seen).to be_nil
      end

      it 'returns nil for invalid last_alert' do
        gateway = described_class.new(attributes.merge('last_alert' => 'not-a-date'))
        expect(gateway.last_alert).to be_nil
      end
    end

    context 'with nil datetime' do
      it 'returns nil for nil last_seen' do
        gateway = described_class.new(attributes.merge('last_seen' => nil))
        expect(gateway.last_seen).to be_nil
      end

      it 'returns nil for nil last_alert' do
        gateway = described_class.new(attributes.merge('last_alert' => nil))
        expect(gateway.last_alert).to be_nil
      end
    end
  end
end
