# frozen_string_literal: true

require 'spec_helper'
require 'search_app'
require 'json'

describe SearchApp do
  let(:user_json) { JSON.generate(user_json_hash) }
  let(:organization_json) { JSON.generate(organization_json_hash) }
  let(:ticket_json) { JSON.generate(ticket_json_hash) }
  let(:user_json_hash) do
    [
      {
        "_id" => 1,
        "url" => "http://initech.zendesk.com/api/v2/users/1.json",
        "external_id" => "74341f74-9c79-49d5-9611-87ef9b6eb75f",
        "name" => "Francisca Rasmussen",
        "alias" => "Miss Coffey",
        "created_at" => "2016-04-15T05:19:46 -10:00",
        "active" => true,
        "verified" => true,
        "shared" => true,
        "locale" => "en-AU",
        "timezone" => "Sri Lanka",
        "last_login_at" => "2013-08-04T01:03:27 -10:00",
        "email" => "coffeyrasmussen@flotonic.com",
        "phone" => "8335-422-718",
        "signature" => "Don't Worry Be Happy!",
        "organization_id" => 101,
        "tags" => [
          "Springville",
          "Sutton"
        ],
        "suspended" => true,
        "role" => "admin"
      },
      {
        "_id" => 2,
        "url" => "",
        "external_id" => "",
        "name" => "",
        "alias" => "",
        "created_at" => "2016-04-15T05:19:46 -10:00",
        "active" => false,
        "verified" => false,
        "shared" => nil,
        "locale" => nil,
        "timezone" => nil,
        "last_login_at" => "",
        "email" => "",
        "phone" => "",
        "signature" => "",
        "organization_id" => nil,
        "tags" => [
          "Melbourne",
          "Sutton"
        ],
        "suspended" => nil,
        "role" => ""
      }
    ]
  end
  let(:organization_json_hash) do
    [
      {
        "_id" => 101,
        "url" => "http://initech.zendesk.com/api/v2/organizations/101.json",
        "external_id" => "9270ed79-35eb-4a38-a46f-35725197ea8d",
        "name" => "Enthaze",
        "domain_names" => ["kage.com", "zentix.com"],
        "created_at" => "2016-05-21T11:10:28 -10:00",
        "details" => "MegaCorp",
        "shared_tickets" => false,
        "tags" => ["Fulton", "Farley"]
      },
      {
        "_id" => 102,
        "url" => "",
        "external_id" => "",
        "name" => "",
        "domain_names" => ["apple.com", "zentix.com"],
        "created_at" => "2016-05-21T11:10:28 -10:00",
        "details" => "",
        "shared_tickets" => nil,
        "tags" => ["Fulton", "Barley"]
      }
    ]
  end
  let(:ticket_json_hash) do
    [
      {
        "_id" => "436bf9b0-1147-4c0a-8439-6f79833bff5b",
        "url" => "http://initech.zendesk.com/api/v2/tickets/436bf9b0-1147-4c0a-8439-6f79833bff5b.json",
        "external_id" => "9210cdc9-4bee-485f-a078-35396cd74063",
        "created_at" => "2016-04-28T11:19:34 -10:00",
        "type" => "incident",
        "subject" => "A Catastrophe in Korea (North)",
        "description" => "Nostrud ad sit velit cupidatat laboris ipsum nisi amet laboris ex exercitation amet et proident. Ipsum fugiat aute dolore tempor nostrud velit ipsum.",
        "priority" => "high",
        "status" => "pending",
        "submitter_id" => 1,
        "assignee_id" => 2,
        "organization_id" => 101,
        "tags" => ["Ohio", "Northern Mariana Islands"],
        "has_incidents" => false,
        "due_at" => "2016-07-31T02:37:50 -10:00",
        "via" => "web"
      },
      {
        "_id" => "9s8df9b0-82jd-d99d-adss-998s833bff4e",
        "url" => "",
        "external_id" => "",
        "created_at" => "2016-04-28T11:19:34 -10:00",
        "type" => "",
        "subject" => "",
        "description" => "",
        "priority" => "",
        "status" => "",
        "submitter_id" => nil,
        "assignee_id" => nil,
        "organization_id" => nil,
        "tags" => ["Ohio", "Melbourne"],
        "has_incidents" => false,
        "due_at" => "",
        "via" => ""
      }
    ]
  end

  describe '#init' do
    subject(:init) do
      described_class.init(
        user_json: user_json,
        organization_json: organization_json,
        ticket_json: ticket_json
      )
    end

    it 'returns a Success' do
      expect(init.success?).to eq true
    end

    it 'has a SearchApp instance' do
      expect(init.value!).to be_a SearchApp
    end

    context 'when provided user_json is invalid' do
      let(:user_json) { "{ 123 }" }

      it 'returns a failure' do
        expect(init.failure).to be_a(JSON::ParserError)
      end
    end

    context 'when provided organization_json is invalid' do
      let(:organization_json) { "{ 123 }" }

      it 'returns a failure' do
        expect(init.failure).to be_a(JSON::ParserError)
      end
    end

    context 'when provided ticket_json is invalid' do
      let(:ticket_json) { "{ 123 }" }

      it 'returns a failure' do
        expect(init.failure).to be_a(JSON::ParserError)
      end
    end

    context 'when there is an error in generating database' do
      let(:user_json_hash) do
        [{"random-key" => 123 }]
      end

      it 'returns a failure' do
        expect(init.failure).to be_a(Errors::GenerateDatabase)
      end
    end
  end

  describe '.available_records' do
    subject(:available_records) do
      described_class.init(
        user_json: user_json,
        organization_json: organization_json,
        ticket_json: ticket_json
      ).value!.available_records
    end

    it 'returns a Success' do
      expect(available_records.success?).to eq true
    end

    it 'has the known available records' do
      expect(available_records.value!).to eq(['users', 'organizations', 'tickets'])
    end
  end
end
