# frozen_string_literal: true

require 'spec_helper'
require 'parsers/time_attributes'
require 'dry/monads'

describe Parsers::TimeAttributes do
  describe '#call' do
    subject(:call) do
      described_class.call(value: value)
    end

    context 'when provided value is invalid' do
      let(:value) { 'foo' }

      it 'returns a None' do
        expect(call).to be_a(Dry::Monads::None)
      end
    end

    context 'when provided value is a valid time' do
      let(:value) { '2016-04-15T05:19:46 -10:00'}

      it 'returns a time in utc' do
        expect(call.value!).to eq([2016, 4, 15, 15, 19, 46])
      end
    end
  end
end
