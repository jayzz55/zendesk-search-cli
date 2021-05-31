# frozen_string_literal: true

require 'spec_helper'
require 'models/ticket'

describe Models::Ticket do
  let(:ticket) { described_class.new(data) }
  let(:time) { Time.parse('2016-04-14T08:32:31 -10:00') }
  let(:data) do
    {
      _id: 123
    }
  end

  describe '.with_associations' do
    subject(:with_associations) do
      ticket.with_associations(
        submitter: 'john',
        assignee: 'mary',
        organization: 'MegaCorp'
      )
    end

    its(:associated_submitter) { should eq 'john' }
    its(:associated_assignee) { should eq 'mary' }
    its(:associated_organization) { should eq 'MegaCorp' }
  end

  describe '.to_s' do
    subject(:to_s) { ticket.to_s(representer) }

    let(:representer) do
      lambda =-> (ticket) { "ticket has id of #{ticket._id}" }
    end

    it 'returns the represented_version' do
      expect(to_s).to eq 'ticket has id of 123'
    end
  end
end
