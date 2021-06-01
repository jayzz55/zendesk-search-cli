# frozen_string_literal: true

require 'spec_helper'
require 'services/generate_database'

describe Services::GenerateDatabase do
  describe '#call' do
    subject(:database) { described_class.call(input) }

    let(:input) do
      {
        'users' => user_json,
        'organizations' => organization_json,
        'tickets' => ticket_json
      }
    end

    let(:user_json) do
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
    let(:organization_json) do
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
    let(:ticket_json) do
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

    it 'returns a Success' do
      expect(database.success?).to eq true
    end

    context 'when users data is provided' do
      it 'generates database 2 users data populated' do
        expect(database.value!.data.dig('users').except('index').size).to eq(2)
      end

      it 'generates database with user 1 data populated' do
        expect(database.value!.data.dig('users', 1)).to match(user_json[0])
      end

      it 'generates database with user 2 data populated' do
        expect(database.value!.data.dig('users', 2)).to match(user_json[1])
      end

      it 'generates database index for the url attribute' do
        expect(database.value!.data.dig('users', 'index', 'url')).to match({
          "http://initech.zendesk.com/api/v2/users/1.json" => [1],
          "" => [2]
        })
      end

      it 'generates database index for the external_id attribute' do
        expect(database.value!.data.dig('users', 'index', 'external_id')).to match({
          "74341f74-9c79-49d5-9611-87ef9b6eb75f" => [1],
          "" => [2]
        })
      end

      it 'generates database index for the name attribute' do
        expect(database.value!.data.dig('users', 'index', 'name')).to match({
          "francisca rasmussen" => [1],
          "" => [2],
        })
      end

      it 'generates database index for the alias attribute' do
        expect(database.value!.data.dig('users', 'index', 'alias')).to match({
          "miss coffey" => [1], "" => [2]
        })
      end

      it 'generates database index for the created_at attribute' do
        expect(database.value!.data.dig('users', 'index', 'created_at')).to match({
          2016 => { 4 => { 15 => { 15 => { 19 => { 46 => [1,2] } } } } }
        })
      end

      it 'generates database index for the active attribute' do
        expect(database.value!.data.dig('users', 'index', 'active')).to match({
          true => [1], false => [2]
        })
      end

      it 'generates database index for the verified attribute' do
        expect(database.value!.data.dig('users', 'index', 'verified')).to match({
          true => [1], false => [2]
        })
      end

      it 'generates database index for the shared attribute' do
        expect(database.value!.data.dig('users', 'index', 'shared')).to match({
          true => [1], false => [2]
        })
      end

      it 'generates database index for the locale attribute' do
        expect(database.value!.data.dig('users', 'index', 'locale')).to match({
          "en-au" => [1], "" => [2]
        })
      end

      it 'generates database index for the timezone attribute' do
        expect(database.value!.data.dig('users', 'index', 'timezone')).to match({
          "sri lanka" => [1], "" => [2]
        })
      end

      it 'generates database index for the last_login_at attribute' do
        expect(database.value!.data.dig('users', 'index', 'last_login_at')).to match({
          2013 => { 8 => { 4 => { 11 => { 3 => { 27 => [1] } } } } },
          "" => [2]
        })
      end

      it 'generates database index for the email attribute' do
        expect(database.value!.data.dig('users', 'index', 'email')).to match({
          "coffeyrasmussen@flotonic.com" => [1], "" => [2]
        })
      end

      it 'generates database index for the phone attribute' do
        expect(database.value!.data.dig('users', 'index', 'phone')).to match({
          "8335-422-718" => [1], "" => [2]
        })
      end

      it 'generates database index for the signature attribute' do
        expect(database.value!.data.dig('users', 'index', 'signature')).to match({
          "don't worry be happy!" => [1], "" => [2]
        })
      end

      it 'generates database index for the organization_id attribute' do
        expect(database.value!.data.dig('users', 'index', 'organization_id')).to match({
          101 => [1],
          0 => [2]
        })
      end

      it 'generates database index for the tags attribute' do
        expect(database.value!.data.dig('users', 'index', 'tags')).to match({
          "springville" => [1],
          "sutton" => [1,2],
          "melbourne" => [2]
        })
      end

      it 'generates database index for the suspended attribute' do
        expect(database.value!.data.dig('users', 'index', 'suspended')).to match({
          true => [1], false => [2]
        })
      end

      it 'generates database index for the role attribute' do
        expect(database.value!.data.dig('users', 'index', 'role')).to match({
          "admin" => [1], "" => [2]
        })
      end
    end

    context 'when organizations data is provided' do
      it 'generates database 2 organizations data populated' do
        expect(database.value!.data.dig('organizations').except('index').size).to eq(2)
      end

      it 'generates database with organization 1 data populated' do
        expect(database.value!.data.dig('organizations', 101)).to match(organization_json[0])
      end

      it 'generates database with organization 2 data populated' do
        expect(database.value!.data.dig('organizations', 102)).to match(organization_json[1])
      end

      it 'generates database index for the url attribute' do
        expect(database.value!.data.dig('organizations', 'index', 'url')).to match({
          "http://initech.zendesk.com/api/v2/organizations/101.json" => [101],
          "" => [102]
        })
      end

      it 'generates database index for the external_id attribute' do
        expect(database.value!.data.dig('organizations', 'index', 'external_id')).to match({
          "9270ed79-35eb-4a38-a46f-35725197ea8d" => [101],
          "" => [102]
        })
      end

      it 'generates database index for the domain_names attribute' do
        expect(database.value!.data.dig('organizations', 'index', 'domain_names')).to match({
          "kage.com" => [101],
          "zentix.com" => [101, 102],
          "apple.com" => [102]
        })
      end

      it 'generates database index for the created_at attribute' do
        expect(database.value!.data.dig('organizations', 'index', 'created_at')).to match({
          2016 => { 5 => { 21 => { 21 => { 10 => { 28 => [101, 102] } } } } }
        })
      end

      it 'generates database index for the tags attribute' do
        expect(database.value!.data.dig('organizations', 'index', 'tags')).to match({
          "fulton" => [101, 102],
          "farley" => [101],
          "barley" => [102]
        })
      end

      it 'generates database index for the shared_tickets attribute' do
        expect(database.value!.data.dig('organizations', 'index', 'shared_tickets')).to match({
          false => [101, 102]
        })
      end


      it 'generates database index for the details attribute' do
        expect(database.value!.data.dig('organizations', 'index', 'details')).to match({
          "megacorp" => [101],
          "" => [102]
        })
      end
    end

    context 'when tickets data is provided' do
      let(:ticket_1_id) { "436bf9b0-1147-4c0a-8439-6f79833bff5b" }
      let(:ticket_2_id) { "9s8df9b0-82jd-d99d-adss-998s833bff4e" }

      it 'generates database 2 tickets data populated' do
        expect(database.value!.data.dig('tickets').except('index').size).to eq(2)
      end

      it 'generates database with ticket 1 data populated' do
        expect(database.value!.data.dig('tickets', ticket_1_id)).to match(ticket_json[0])
      end

      it 'generates database with ticket 2 data populated' do
        expect(database.value!.data.dig('tickets', ticket_2_id)).to match(ticket_json[1])
      end

      it 'generates database index for the url attribute' do
        expect(database.value!.data.dig('tickets', 'index', 'url')).to match({
          "http://initech.zendesk.com/api/v2/tickets/436bf9b0-1147-4c0a-8439-6f79833bff5b.json" => [ticket_1_id],
          "" => [ticket_2_id]
        })
      end

      it 'generates database index for the external_id attribute' do
        expect(database.value!.data.dig('tickets', 'index', 'external_id')).to match({
          "9210cdc9-4bee-485f-a078-35396cd74063" => [ticket_1_id],
          "" => [ticket_2_id]
        })
      end

      it 'generates database index for the created_at attribute' do
        expect(database.value!.data.dig('tickets', 'index', 'created_at')).to match({
          2016 => { 4 => { 28 => { 21 => { 19 => { 34 => [ticket_1_id, ticket_2_id] } } } } }
        })
      end

      it 'generates database index for the due_at attribute' do
        expect(database.value!.data.dig('tickets', 'index', 'due_at')).to match({
          2016 => { 7 => { 31 => { 12 => { 37 => { 50 => [ticket_1_id] } } } } },
          "" => [ticket_2_id]
        })
      end

      it 'generates database index for the tags attribute' do
        expect(database.value!.data.dig('tickets', 'index', 'tags')).to match({
          "ohio" => [ticket_1_id, ticket_2_id],
          "northern mariana islands" => [ticket_1_id],
          "melbourne" => [ticket_2_id]
        })
      end

      it 'generates database index for the has_incidents attribute' do
        expect(database.value!.data.dig('tickets', 'index', 'has_incidents')).to match({
          false => [ticket_1_id, ticket_2_id],
        })
      end

      it 'generates database index for the type attribute' do
        expect(database.value!.data.dig('tickets', 'index', 'type')).to match({
          "incident" => [ticket_1_id],
          "" => [ticket_2_id]
        })
      end

      it 'generates database index for the subject attribute' do
        expect(database.value!.data.dig('tickets', 'index', 'subject')).to match({
          "a catastrophe in korea (north)" => [ticket_1_id],
          "" => [ticket_2_id]
        })
      end

      it 'generates database index for the description attribute' do
        expect(database.value!.data.dig('tickets', 'index', 'description')).to match({
          "nostrud ad sit velit cupidatat laboris ipsum nisi amet laboris ex exercitation amet et proident. ipsum fugiat aute dolore tempor nostrud velit ipsum." => [ticket_1_id],
          "" => [ticket_2_id]
        })
      end

      it 'generates database index for the priority attribute' do
        expect(database.value!.data.dig('tickets', 'index', 'priority')).to match({
          "high" => [ticket_1_id],
          "" => [ticket_2_id]
        })
      end

      it 'generates database index for the status attribute' do
        expect(database.value!.data.dig('tickets', 'index', 'status')).to match({
          "pending" => [ticket_1_id],
          "" => [ticket_2_id]
        })
      end

      it 'generates database index for the via attribute' do
        expect(database.value!.data.dig('tickets', 'index', 'via')).to match({
          "web" => [ticket_1_id],
          "" => [ticket_2_id]
        })
      end

      it 'generates database index for the submitter_id attribute' do
        expect(database.value!.data.dig('tickets', 'index', 'submitter_id')).to match({
          1 => [ticket_1_id],
          0 => [ticket_2_id]
        })
      end

      it 'generates database index for the assignee_id attribute' do
        expect(database.value!.data.dig('tickets', 'index', 'assignee_id')).to match({
          2 => [ticket_1_id],
          0 => [ticket_2_id]
        })
      end

      it 'generates database index for the organization_id attribute' do
        expect(database.value!.data.dig('tickets', 'index', 'organization_id')).to match({
          101 => [ticket_1_id],
          0 => [ticket_2_id]
        })
      end
    end

    context 'when invalid record is provided' do
      let(:input) do
        {
          'foo' => user_json,
          'organizations' => organization_json,
          'tickets' => ticket_json
        }
      end

      it 'returns a failure' do
        expect(database.failure).to be_a(Errors::GenerateDatabase)
      end
    end

    context 'when invalid data is provided' do
      let(:organization_json) do
        [
          {
            "_id" => 102,
            "random_attribute" => 123
          }
        ]
      end

      it 'returns a failure' do
        expect(database.failure).to be_a(Errors::GenerateDatabase)
      end
    end
  end
end
