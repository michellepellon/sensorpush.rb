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
end
