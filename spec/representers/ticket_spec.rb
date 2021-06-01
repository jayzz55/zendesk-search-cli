# frozen_string_literal: true

require 'spec_helper'
require 'representers/ticket'

describe Representers::Ticket do
  let(:ticket) do
    Models::Ticket.new(data).with_associations(
        submitter: submitter,
        assignee: assignee,
      organization: organization
    )
  end
  let(:time) { Time.parse('2016-04-14T08:32:31 -10:00') }
  let(:data) do
    {
      _id: 123,
      url: 'some-url',
      external_id: 'some-external-id',
      created_at: time,
      type: 'special',
      subject: 'urgent ticket',
      description: 'hello world!',
      priority: 'urgent',
      status: 'open',
      submitter_id: 123,
      assignee_id: 987,
      organization_id: 101,
      tags: ['some-tags'],
      has_incidents: false,
      due_at: time,
      via: 'web'
    }
  end
  let(:submitter) { {name: 'dan', alias: 'john', role: 'admin'} }
  let(:assignee) { nil }
  let(:organization) { { name: 'MegaCorp' } }

  describe '#call' do
    subject(:call) { described_class.call(ticket) }

    it 'returns a formatted strings' do
      expect(call).to match <<-DOCS
* Ticket with _id 123
_id                            123
url                            some-url
external_id                    some-external-id
created_at                     2016-04-14 08:32:31 -1000
type                           special
subject                        urgent ticket
description                    hello world!
priority                       urgent
status                         open
submitter_id                   123
assignee_id                    987
organization_id                101
tags                           ["some-tags"]
has_incidents                  false
due_at                         2016-04-14 08:32:31 -1000
via                            web
--- Submitter:
    name:     dan
    alias:    john
    role:     admin
--- Assignee:
--- Organization:
    name:     MegaCorp
      DOCS
    end
  end
end
