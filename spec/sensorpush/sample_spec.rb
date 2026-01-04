# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sensorpush::Sample do
  let(:attributes) do
    {
      'observed' => '2023-04-15T12:00:00Z',
      'temperature' => 21.5,
      'humidity' => 45.2
    }
  end

  subject(:sample) { described_class.new(attributes) }

  describe '#initialize' do
    it 'sets attributes correctly' do
      expect(sample.observed).to be_a(DateTime)
      expect(sample.observed.to_s).to eq('2023-04-15T12:00:00+00:00')
      expect(sample.temperature).to eq(21.5)
      expect(sample.humidity).to eq(45.2)
    end

    it 'handles missing attributes' do
      sample = described_class.new({})
      expect(sample.observed).to be_nil
      expect(sample.temperature).to be_nil
      expect(sample.humidity).to be_nil
    end

    context 'with keyword arguments (Data class style)' do
      it 'accepts keyword arguments directly' do
        sample = described_class.new(
          humidity: 50.0,
          temperature: 22.0,
          observed: DateTime.now
        )
        expect(sample.humidity).to eq(50.0)
        expect(sample.temperature).to eq(22.0)
        expect(sample.observed).to be_a(DateTime)
      end
    end
  end

  describe '.from_api' do
    it 'creates a sample from API response attributes' do
      sample = described_class.from_api(attributes)
      expect(sample.temperature).to eq(21.5)
      expect(sample.humidity).to eq(45.2)
      expect(sample.observed).to be_a(DateTime)
    end
  end

  describe 'datetime parsing' do
    context 'with valid datetime string' do
      it 'parses correctly' do
        expect(sample.observed).to be_a(DateTime)
        expect(sample.observed.to_s).to eq('2023-04-15T12:00:00+00:00')
      end
    end

    context 'with invalid datetime string' do
      it 'returns nil' do
        sample = described_class.new(attributes.merge('observed' => 'not-a-date'))
        expect(sample.observed).to be_nil
      end
    end

    context 'with nil datetime' do
      it 'returns nil' do
        sample = described_class.new(attributes.merge('observed' => nil))
        expect(sample.observed).to be_nil
      end
    end
  end

  describe 'immutability (Data class)' do
    it 'is a Data class' do
      expect(described_class.ancestors).to include(Data)
    end

    it 'does not allow attribute modification' do
      expect { sample.instance_variable_set(:@temperature, 25.0) }
        .to raise_error(FrozenError)
    end

    it 'provides equality based on values' do
      sample1 = described_class.new(attributes)
      sample2 = described_class.new(attributes)
      expect(sample1).to eq(sample2)
    end
  end

  describe 'pattern matching' do
    it 'supports hash deconstruction with deconstruct_keys' do
      case sample
      in { temperature: t, humidity: h }
        expect(t).to eq(21.5)
        expect(h).to eq(45.2)
      else
        raise 'Pattern should have matched'
      end
    end

    it 'supports array deconstruction with deconstruct' do
      humidity, temperature, observed = sample.deconstruct
      expect(humidity).to eq(45.2)
      expect(temperature).to eq(21.5)
      expect(observed).to be_a(DateTime)
    end

    it 'supports guard clauses in pattern matching' do
      result = case sample
               in { temperature: t } if t > 20
                 'warm'
               else
                 'cold'
               end
      expect(result).to eq('warm')
    end
  end
end
