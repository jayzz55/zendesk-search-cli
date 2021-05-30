# frozen_string_literal: true

require 'spec_helper'
require 'validators/search_term'

describe Validators::SearchTerm do
  describe '#call' do
    subject(:call) do
      described_class.call(search_terms: search_terms, value: value)
    end

    context 'when provided search_term is invalid' do
      let(:search_terms) { ['created_at'] }
      let(:value) { 'foo' }

      it 'returns a failure' do
        expect(call.failure).to be_a(Errors::UnknownSearchTerm)
      end
    end

    context 'when provided search_term is valid' do
      let(:search_terms) { ['created_at'] }
      let(:value) { 'created_at' }

      it 'returns a success' do
        expect(call.success?).to eq true
      end
    end
  end
end
