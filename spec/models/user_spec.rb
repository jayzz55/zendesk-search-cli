# frozen_string_literal: true

require 'spec_helper'
require 'models/user'

describe Models::User do
  let(:user) { described_class.new(data) }
  let(:time) { Time.parse('2016-04-14T08:32:31 -10:00') }
  let(:data) do
    {
      _id: 123
    }
  end

  describe '.with_associations' do
    subject(:with_associations) do
      user.with_associations(
        submitted_tickets: [1,2,3],
        assigned_tickets: ['a', 'b', 'c'],
        organization: 'MegaCorp'
      )
    end

    its(:associated_submitted_tickets) { should eq [1,2,3] }
    its(:associated_assigned_tickets) { should eq ['a', 'b', 'c'] }
    its(:associated_organization) { should eq 'MegaCorp' }
  end

  describe '.to_s' do
    subject(:to_s) { user.to_s(representer) }

    let(:representer) do
      lambda =-> (user) { "user has id of #{user._id}" }
    end

    it 'returns the represented_version' do
      expect(to_s).to eq 'user has id of 123'
    end
  end
end
