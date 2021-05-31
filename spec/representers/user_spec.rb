# frozen_string_literal: true

require 'spec_helper'
require 'representers/user'

describe Representers::User do
  let(:user) do
    Models::User.new(data).with_associations(
      submitted_tickets: submitted_tickets,
      assigned_tickets: assigned_tickets,
      organization: organization
    )
  end
  let(:time) { Time.parse('2016-04-14T08:32:31 -10:00') }
  let(:data) do
    {
      _id: 123,
      url: 'some-url',
      external_id: 'some-external-id',
      name: 'some-name',
      alias: 'some-alias',
      created_at: time,
      active: true,
      verified: true,
      shared: true,
      locale: 'en-AU',
      timezone: 'Australia/Melbourne',
      last_login_at: time,
      email: 'some-email',
      phone: '000',
      signature: 'some-signature',
      organization_id: 101,
      tags: ['tag1'],
      suspended: false,
      role: 'user'
    }
  end
  let(:submitted_tickets) { [{subject: 'hi', priority: 'high', status: 'open'}] }
  let(:assigned_tickets) { [{subject: 'reply', priority: 'low', status: 'closed'}] }
  let(:organization) { { name: 'MegaCorp' } }

  describe '#call' do
    subject(:call) { described_class.call(user) }

    it 'returns a formatted strings' do
      expect(call).to match <<-DOCS
* User with _id 123
_id                            123
url                            some-url
external_id                    some-external-id
name                           some-name
alias                          some-alias
created_at                     2016-04-14 08:32:31 -1000
active                         true
verified                       true
shared                         true
locale                         en-AU
timezone                       Australia/Melbourne
last_login_at                  2016-04-14 08:32:31 -1000
email                          some-email
phone                          000
signature                      some-signature
organization_id                101
tags                           ["tag1"]
suspended                      false
role                           user
--- Submitted tickets:
 1. subject:  hi
    priority: high
    status:   open
--- Assigned Tickets:
 1. subject:  reply
    priority: low
    status:   closed
--- Organization:
    name:     MegaCorp
      DOCS
    end
  end
end
