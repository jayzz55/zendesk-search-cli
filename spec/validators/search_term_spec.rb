# frozen_string_literal: true

require 'spec_helper'
require 'validators/search_term'

describe Validators::SearchTerm do
  describe '#call' do
    subject(:call) do
      described_class.call(record: record, search_term: search_term)
    end

    context 'when Services::FetchSchema returns a failure' do
      let(:record) { 'foo' }
      let(:search_term) { 'created_at' }

      it 'returns a failure' do
        expect(call.failure).to be_a(Errors::UnknownSchemaRecord)
      end
    end

    context 'when provided search_term is invalid' do
      let(:record) { 'users' }
      let(:search_term) { 'foo' }

      it 'returns a failure' do
        expect(call.failure).to be_a(Errors::UnknownSearchTerm)
      end
    end

    context 'when provided search_term is valid' do
      let(:record) { 'users' }
      let(:search_term) { 'created_at' }

      it 'returns a success' do
        expect(call.success?).to eq true
      end
    end
  end
end
