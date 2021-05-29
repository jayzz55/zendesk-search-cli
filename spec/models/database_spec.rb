# frozen_string_literal: true

require 'spec_helper'
require 'models/database'

describe Models::Database do
  describe '.get_record' do
    subject(:get_record) { described_class.new(data).get_record(record: record, key: key) }

    let(:record) { :foo }
    let(:key) { 1 }

    let(:data) do
      {
        foo: {
          1 => 123
        }
      }
    end

    context 'when provided record and key exist' do
      it 'returns the value 123' do
        expect(get_record).to eq 123
      end
    end

    context 'when provided record does not exist' do
      let(:record) { :something }

      it 'returns the nil' do
        expect(get_record).to eq nil
      end
    end

    context 'when provided key does not exist' do
      let(:key) { :something }

      it 'returns the nil' do
        expect(get_record).to eq nil
      end
    end
  end

  describe '.search_index' do
    subject(:search_index) { described_class.new(data).search_index(record: record, paths: paths) }

    let(:record) { :foo }
    let(:paths) { ['name', 'john'] }

    let(:data) do
      {
        foo: {
          'index' => {
            'name' => { 'john' => [123] }
          }
        }
      }
    end

    context 'when provided record and paths exist' do
      it 'returns the value [123]' do
        expect(search_index).to eq [123]
      end
    end

    context 'when provided record does not exist' do
      let(:record) { :something }

      it 'returns the nil' do
        expect(search_index).to eq nil
      end
    end

    context 'when provided paths does not exist' do
      let(:paths) { ['is_admin', false] }

      it 'returns the nil' do
        expect(search_index).to eq nil
      end
    end
  end

  describe '.upsert_record' do
    subject(:upsert_record) do
      database.upsert_record(record: record, primary_key: primary_key, value: value)
    end

    let(:database) { described_class.new(data) }
    let(:record) { :foo }
    let(:primary_key) { "some-primary-key" }
    let(:value) do
      { hello: 'world' }
    end

    context 'when initial data is empty' do
      let(:data) do
        {}
      end

      it 'updates the data with the provided record, primary_key, and value' do
        upsert_record
        expect(database.data).to match({
          foo: {
            'some-primary-key' => { hello: 'world' }
          }
        })
      end
    end

    context 'when initial data is not empty' do
      let(:data) do
        {
          foo: {
            'some-primary-key' => { fruit: 'apple' },
            'some-primary-key-2' => { fruit: 'orange' }
          }
        }
      end

      it 'updates the data with the provided record, primary_key, and value' do
        upsert_record
        expect(database.data).to match({
          foo: {
            'some-primary-key' => { hello: 'world' },
            'some-primary-key-2' => { fruit: 'orange' }
          }
        })
      end
    end
  end

  describe '.upsert_index' do
    subject(:upsert_index) do
      database.upsert_index(record: record, paths: paths, index: index)
    end

    let(:database) { described_class.new(data) }
    let(:record) { :foo }
    let(:paths) { ['name', 'john'] }
    let(:index) { 123 }

    context 'when initial data is empty' do
      let(:data) do
        {}
      end

      it 'updates the index within the data with the provided record, paths, and index' do
        upsert_index
        expect(database.data).to match({
          foo: {
            'index' => {
              'name' => { 'john' => [123] }
            }
          }
        })
      end
    end

    context 'when initial data is not empty' do
      let(:data) do
        {
          foo: {
            'index' => {
              'name' => { 'john' => [25] }
            }
          }
        }
      end

      it 'append the index within the data with the provided record, paths, and index' do
        upsert_index
        expect(database.data).to match({
          foo: {
            'index' => {
              'name' => { 'john' => [25, 123] }
            }
          }
        })
      end
    end
  end
end
