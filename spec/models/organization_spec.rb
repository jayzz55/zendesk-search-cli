# frozen_string_literal: true

require 'spec_helper'
require 'models/organization'

describe Models::Organization do
  let(:organization) { described_class.new(data) }
  let(:time) { Time.parse('2016-04-14T08:32:31 -10:00') }
  let(:data) do
    {
      _id: 123
    }
  end

  describe '.with_associations' do
    subject(:with_associations) do
      organization.with_associations(
        tickets: [1,2,3],
        users: ['a', 'b', 'c']
      )
    end

    its(:associated_tickets) { should eq [1,2,3] }
    its(:associated_users) { should eq ['a', 'b', 'c'] }
  end

  describe '.to_s' do
    subject(:to_s) { organization.to_s(representer) }

    let(:representer) do
      lambda =-> (organization) { "organization has id of #{organization._id}" }
    end

    it 'returns the represented_version' do
      expect(to_s).to eq 'organization has id of 123'
    end
  end
end
