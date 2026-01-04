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

  describe 'constants' do
    it 'defines battery thresholds' do
      expect(described_class::BATTERY_LOW_THRESHOLD).to eq(2.2)
      expect(described_class::BATTERY_MAX_VOLTAGE).to eq(3.0)
      expect(described_class::BATTERY_MIN_VOLTAGE).to eq(2.0)
    end
  end

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

  describe 'immutability' do
    it 'does not allow name modification' do
      expect(sensor).not_to respond_to(:name=)
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

  describe '#instance_variables_to_inspect' do
    it 'returns key instance variables for inspect output' do
      expect(sensor.instance_variables_to_inspect).to eq(%i[@id @name @active @battery_voltage])
    end
  end

  describe 'pattern matching' do
    describe '#deconstruct_keys' do
      it 'returns all attributes including computed values when keys is nil' do
        result = sensor.deconstruct_keys(nil)
        expect(result).to include(
          id: 'sensor_abc',
          name: 'Living Room Sensor',
          active: true,
          address: '00:11:22:33:44:55',
          battery_voltage: 2.85,
          device_id: 'HT1_001122334455',
          battery_low: false
        )
        expect(result[:battery_percentage]).to be_within(0.1).of(85.0)
      end

      it 'returns only specified keys' do
        result = sensor.deconstruct_keys(%i[id name battery_low])
        expect(result).to eq({
                               id: 'sensor_abc',
                               name: 'Living Room Sensor',
                               battery_low: false
                             })
      end
    end

    it 'supports case/in pattern matching' do
      case sensor
      in { id:, name:, active: true }
        expect(id).to eq('sensor_abc')
        expect(name).to eq('Living Room Sensor')
      else
        raise 'Pattern should have matched'
      end
    end

    it 'supports pattern matching with computed properties' do
      low_battery_sensor = described_class.new(attributes.merge('battery_voltage' => 2.1))

      result = case low_battery_sensor
               in { battery_low: true, name: }
                 "Warning: #{name} has low battery!"
               else
                 'Battery OK'
               end

      expect(result).to eq('Warning: Living Room Sensor has low battery!')
    end

    it 'supports pattern matching with guard clauses' do
      result = case sensor
               in { battery_percentage: pct } if pct < 20
                 'critical'
               in { battery_percentage: pct } if pct < 50
                 'low'
               else
                 'good'
               end
      expect(result).to eq('good')
    end
  end
end
