# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sensorpush::Sensor do
  let(:attributes) do
    {
      'id' => 'sensor_abc',
      'name' => 'Living Room Sensor',
      'active' => true,
      'address' => '00:11:22:33:44:55',
      'battery_voltage' => 2.85,
      'deviceId' => 'HT1_001122334455'
    }
  end

  subject(:sensor) { described_class.new(attributes) }

  describe '#initialize' do
    it 'sets attributes correctly' do
      expect(sensor.id).to eq('sensor_abc')
      expect(sensor.name).to eq('Living Room Sensor')
      expect(sensor.active).to be true
      expect(sensor.address).to eq('00:11:22:33:44:55')
      expect(sensor.battery_voltage).to eq(2.85)
      expect(sensor.device_id).to eq('HT1_001122334455')
    end

    it 'handles missing attributes' do
      sensor = described_class.new({})
      expect(sensor.id).to be_nil
      expect(sensor.name).to be_nil
      expect(sensor.active).to be_nil
      expect(sensor.address).to be_nil
      expect(sensor.battery_voltage).to be_nil
      expect(sensor.device_id).to be_nil
    end
  end

  describe '#battery_low?' do
    context 'when battery voltage is above threshold' do
      it 'returns false' do
        expect(sensor.battery_low?).to be false
      end
    end

    context 'when battery voltage is below threshold' do
      it 'returns true' do
        sensor = described_class.new(attributes.merge('battery_voltage' => 2.1))
        expect(sensor.battery_low?).to be true
      end
    end

    context 'when battery voltage is nil' do
      it 'returns nil' do
        sensor = described_class.new(attributes.merge('battery_voltage' => nil))
        expect(sensor.battery_low?).to be_nil
      end
    end
  end

  describe '#battery_percentage' do
    context 'with battery voltage present' do
      it 'calculates percentage correctly for full battery' do
        sensor = described_class.new(attributes.merge('battery_voltage' => 3.0))
        expect(sensor.battery_percentage).to eq(100)
      end

      it 'calculates percentage correctly for empty battery' do
        sensor = described_class.new(attributes.merge('battery_voltage' => 2.0))
        expect(sensor.battery_percentage).to eq(0)
      end

      it 'calculates percentage correctly for middle value' do
        sensor = described_class.new(attributes.merge('battery_voltage' => 2.5))
        expect(sensor.battery_percentage).to eq(50)
      end

      it 'clamps values above maximum' do
        sensor = described_class.new(attributes.merge('battery_voltage' => 3.5))
        expect(sensor.battery_percentage).to eq(100)
      end

      it 'clamps values below minimum' do
        sensor = described_class.new(attributes.merge('battery_voltage' => 1.5))
        expect(sensor.battery_percentage).to eq(0)
      end
    end

    context 'when battery voltage is nil' do
      it 'returns nil' do
        sensor = described_class.new(attributes.merge('battery_voltage' => nil))
        expect(sensor.battery_percentage).to be_nil
      end
    end
  end
end
