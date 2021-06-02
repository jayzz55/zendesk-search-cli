# frozen_string_literal: true

require 'spec_helper'
require 'parsers/search_value'
require 'dry/monads'

describe Parsers::SearchValue do
  describe '#call' do
    subject(:call) do
      described_class.call(type: type, value: value)
    end

    context 'when provided value is an empty string' do
      let(:value) { '' }
      let(:type) { nil }

      it 'returns empty string' do
        expect(call.value!).to eq('')
      end
    end

    context 'when the type is nil' do
      let(:type) { nil }
      let(:value) { 'foo' }

      it 'returns a None' do
        expect(call).to be_a(Dry::Monads::None)
      end
    end

    context 'when the type is Integer' do
      let(:type) { 'Integer' }

      context 'when provided value is invalid' do
        let(:value) { 'foo' }

        it 'returns a None' do
          expect(call).to be_a(Dry::Monads::None)
        end
      end

      context 'when provided value is valid a integer' do
        let(:value) { '123' }

        it 'returns 123 as integer' do
          expect(call.value!).to eq(123)
        end
      end
    end

    context 'when the type is Boolean' do
      let(:type) { 'Boolean' }

      context 'when provided value is invalid' do
        let(:value) { 'foo' }

        it 'returns a None' do
          expect(call).to be_a(Dry::Monads::None)
        end
      end

      context 'when provided value is a valid true string' do
        let(:value) { 'true' }

        it 'returns true as boolean' do
          expect(call.value!).to eq(true)
        end
      end

      context 'when provided value is a valid false string' do
        let(:value) { 'false' }

        it 'returns false as boolean' do
          expect(call.value!).to eq(false)
        end
      end

      context 'when provided value is a valid true boolean' do
        let(:value) { true }

        it 'returns true as boolean' do
          expect(call.value!).to eq(true)
        end
      end

      context 'when provided value is a valid false boolean' do
        let(:value) { false }

        it 'returns false as boolean' do
          expect(call.value!).to eq(false)
        end
      end
    end

    context 'when the type is Time' do
      let(:type) { 'Time' }

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

    context 'when the type is String' do
      let(:type) { 'String' }
      let(:value) { 'FOO' }

      it 'returns the downcased value' do
        expect(call.value!).to eq('foo')
      end
    end

    context 'when the type is unknown' do
      let(:type) { 'UNKNOWN' }
      let(:value) { 'FOO' }

      it 'returns a None' do
        expect(call).to be_a(Dry::Monads::None)
      end
    end
  end
end
