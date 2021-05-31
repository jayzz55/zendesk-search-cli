# frozen_string_literal: true

require 'spec_helper'
require 'representers/organization'

describe Representers::Organization do
  let(:organization) do
    Models::Organization.new(data).with_associations(
      tickets: tickets,
      users: users,
    )
  end
  let(:time) { Time.parse('2016-04-14T08:32:31 -10:00') }
  let(:data) do
    {
      _id: 123,
      url: 'some-url',
      external_id: 'some-external-id',
      name: 'some-name',
      domain_names: ['a.com', 'b.com'],
      created_at: time,
      details: 'some-details',
      shared_tickets: true,
      tags: ['some-tag']
    }
  end
  let(:tickets) { [{subject: 'hi', priority: 'high', status: 'open'}] }
  let(:users) { [{name: 'dan', alias: 'john', role: 'admin'}] }

  describe '#call' do
    subject(:call) { described_class.call(organization) }

    it 'returns a formatted strings' do
      expect(call).to match <<-DOCS
* Organization with _id 123
_id                            123
url                            some-url
external_id                    some-external-id
name                           some-name
domain_names                   ["a.com", "b.com"]
created_at                     2016-04-14 08:32:31 -1000
details                        some-details
shared_tickets                 true
tags                           ["some-tag"]
--- Users:
 1. name:     dan
    alias:    john
    role:     admin
--- Tickets:
 1. subject:  hi
    priority: high
    status:   open
      DOCS
    end
  end
end
