# frozen_string_literal: true

require 'spec_helper'
require 'services/fetch_schema'

describe Services::FetchSchema do
  describe '#call' do
    subject(:call) { described_class.call(record: record) }

    context 'when provided record is users' do
      let(:record) { 'users' }

      it 'returns a success' do
        expect(call.success?).to eq true
      end

      it 'has the USERS_SCHEMA' do
        expect(call.value!).to eq USERS_SCHEMA
      end
    end

    context 'when provided record is organizations' do
      let(:record) { 'organizations' }

      it 'returns a success' do
        expect(call.success?).to eq true
      end

      it 'has the ORGANIZATIONS_SCHEMA' do
        expect(call.value!).to eq ORGANIZATIONS_SCHEMA
      end
    end

    context 'when provided record is tickets' do
      let(:record) { 'tickets' }

      it 'returns a success' do
        expect(call.success?).to eq true
      end

      it 'has the TICKETS_SCHEMA' do
        expect(call.value!).to eq TICKETS_SCHEMA
      end
    end

    context 'when provided record is invalid' do
      let(:record) { 'foo' }

      it 'returns a failure' do
        expect(call.failure).to be_a(Errors::UnknownSchemaRecord)
      end
    end

    context 'when not able to find the schema' do
      let(:record) { 'users' }

      before do
        allow(Object).to receive(:const_get).and_raise
      end

      it 'returns a failure' do
        expect(call.failure).to be_a(Errors::UnknownSchemaRecord)
      end
    end
  end
end
