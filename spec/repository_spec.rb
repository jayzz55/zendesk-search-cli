# frozen_string_literal: true

require 'spec_helper'
require 'repository'
require 'models/database'

describe Repository do
  let(:repository) { described_class.new(database) }
  let(:database) { Models::Database.new(db_data, schema) }
  let(:schema) do
    {
      'users' => {
        '_id' => { type: 'Integer', 'primary_key' => true },
        'organization_id' => { type: 'Integer' }
      },
      'organizations' => {
        '_id' => { type: 'Integer', 'primary_key' => true }
      },
      'tickets' => {
        '_id' => { type: 'String', 'primary_key' => true },
        'submitter_id' => { type: 'Integer' },
        'assignee_id' => { type: 'Integer' },
        'organization_id' => { type: 'Integer' }
      }
    }
  end
  let(:db_data) do
    {
      'users' => {
        1 => user_data_1,
        2 => user_data_2,
        'index' => {
          'organization_id' => { 101 => [1], 999 => [2] }
        }
      },
      'organizations' => {
        101 => organization_data_1,
        102 => organization_data_2
      },
      'tickets' => {
        '74341f74-9c79-49d5-9611-87ef9b6eb75f' => ticket_data_1,
        '9270ed79-35eb-4a38-a46f-35725197ea8d' => ticket_data_2,
        'index' => {
          'submitter_id' => {
            1 => ['74341f74-9c79-49d5-9611-87ef9b6eb75f'],
            999 => ['9270ed79-35eb-4a38-a46f-35725197ea8d']
          },
          'assignee_id' => {
            1 => ['74341f74-9c79-49d5-9611-87ef9b6eb75f'],
            999 => ['9270ed79-35eb-4a38-a46f-35725197ea8d']
          },
          'organization_id' => {
            101 => ['74341f74-9c79-49d5-9611-87ef9b6eb75f'],
            999 => ['9270ed79-35eb-4a38-a46f-35725197ea8d']
          }
        }
      }
    }
  end
  let(:user_data_1) do
    {
      '_id' => 1,
      'organization_id' => 101
    }
  end
  let(:user_data_2) do
    {
      '_id' => 2,
      'organization_id' => 999
    }
  end
  let(:organization_data_1) do
    {
      '_id' => 101
    }
  end
  let(:organization_data_2) do
    {
      '_id' => 102
    }
  end
  let(:ticket_data_1) do
    {
      '_id' => '74341f74-9c79-49d5-9611-87ef9b6eb75f' ,
      'submitter_id' => 1,
      'assignee_id' => 1,
      'organization_id' => 101
    }
  end
  let(:ticket_data_2) do
    {
      '_id' => '9270ed79-35eb-4a38-a46f-35725197ea8d',
      'submitter_id' => 999,
      'assignee_id' => 999,
      'organization_id' => 999
    }
  end

  describe '.available_records' do
    subject(:available_records) { repository.available_records }

    it 'returns a Success' do
      expect(available_records.success?).to eq true
    end

    it 'returns all the available_records' do
      expect(available_records.value!).to eq ['users', 'organizations', 'tickets']
    end
  end

  describe '.search' do
    subject(:search_results) do
      repository.search(record: record, search_term: search_term, value: value)
    end

    context 'when searching for users' do
      context 'with _id 1' do
        let(:record) { 'users' }
        let(:search_term) { '_id' }
        let(:value) { 1 }

        it 'returns a Success' do
          expect(search_results.success?).to eq true
        end

        it 'returns a collection of Models::User' do
          expect(search_results.value!).to all(be_a(Models::User))
        end

        it 'returns 1 user' do
          expect(search_results.value!.size).to eq 1
        end

        it 'has associated_submitted_tickets' do
          expect(search_results.value!.first.associated_submitted_tickets).to eq(
            [Models::Ticket.new(ticket_data_1)]
          )
        end

        it 'has associated_assigned_tickets' do
          expect(search_results.value!.first.associated_assigned_tickets).to eq(
            [Models::Ticket.new(ticket_data_1)]
          )
        end

        it 'has associated_organization' do
          expect(search_results.value!.first.associated_organization).to eq(
            Models::Organization.new(organization_data_1)
          )
        end
      end

      context 'with _id 2' do
        let(:record) { 'users' }
        let(:search_term) { '_id' }
        let(:value) { 2 }

        it 'returns a Success' do
          expect(search_results.success?).to eq true
        end

        it 'returns a collection of Models::User' do
          expect(search_results.value!).to all(be_a(Models::User))
        end

        it 'returns 1 user' do
          expect(search_results.value!.size).to eq 1
        end

        it 'has no associated_submitted_tickets' do
          expect(search_results.value!.first.associated_submitted_tickets).to be_empty
        end

        it 'has no associated_assigned_tickets' do
          expect(search_results.value!.first.associated_assigned_tickets).to be_empty
        end

        it 'has no associated_organization' do
          expect(search_results.value!.first.associated_organization).to be_nil
        end
      end
    end

    context 'when searching for organizations' do
      context 'with _id 101' do
        let(:record) { 'organizations' }
        let(:search_term) { '_id' }
        let(:value) { 101 }

        it 'returns a Success' do
          expect(search_results.success?).to eq true
        end

        it 'returns a collection of Models::Organization' do
          expect(search_results.value!).to all(be_a(Models::Organization))
        end

        it 'returns 1 organization' do
          expect(search_results.value!.size).to eq 1
        end

        it 'has associated_tickets' do
          expect(search_results.value!.first.associated_tickets).to eq(
            [Models::Ticket.new(ticket_data_1)]
          )
        end

        it 'has associated_users' do
          expect(search_results.value!.first.associated_users).to eq(
            [Models::User.new(user_data_1)]
          )
        end
      end

      context 'with _id 102' do
        let(:record) { 'organizations' }
        let(:search_term) { '_id' }
        let(:value) { 102 }

        it 'returns a Success' do
          expect(search_results.success?).to eq true
        end

        it 'returns a collection of Models::Organization' do
          expect(search_results.value!).to all(be_a(Models::Organization))
        end

        it 'returns 1 organization' do
          expect(search_results.value!.size).to eq 1
        end

        it 'has no associated_tickets' do
          expect(search_results.value!.first.associated_tickets).to be_empty
        end

        it 'has no associated_users' do
          expect(search_results.value!.first.associated_users).to be_empty
        end
      end
    end

    context 'when searching for tickets' do
      context 'with _id 74341f74-9c79-49d5-9611-87ef9b6eb75f' do
        let(:record) { 'tickets' }
        let(:search_term) { '_id' }
        let(:value) { '74341f74-9c79-49d5-9611-87ef9b6eb75f' }

        it 'returns a Success' do
          expect(search_results.success?).to eq true
        end

        it 'returns a collection of Models::Ticket' do
          expect(search_results.value!).to all(be_a(Models::Ticket))
        end

        it 'returns 1 ticket' do
          expect(search_results.value!.size).to eq 1
        end

        it 'has associated_submitter' do
          expect(search_results.value!.first.associated_submitter).to eq(
            Models::User.new(user_data_1)
          )
        end

        it 'has associated_assignee' do
          expect(search_results.value!.first.associated_assignee).to eq(
            Models::User.new(user_data_1)
          )
        end

        it 'has associated_organization' do
          expect(search_results.value!.first.associated_organization).to eq(
            Models::Organization.new(organization_data_1)
          )
        end
      end

      context 'with _id 9270ed79-35eb-4a38-a46f-35725197ea8d' do
        let(:record) { 'tickets' }
        let(:search_term) { '_id' }
        let(:value) { '9270ed79-35eb-4a38-a46f-35725197ea8d' }

        it 'returns a Success' do
          expect(search_results.success?).to eq true
        end

        it 'returns a collection of Models::Ticket' do
          expect(search_results.value!).to all(be_a(Models::Ticket))
        end

        it 'returns 1 ticket' do
          expect(search_results.value!.size).to eq 1
        end
        it 'has no associated_submitter' do
          expect(search_results.value!.first.associated_submitter).to be_nil
        end

        it 'has no associated_assignee' do
          expect(search_results.value!.first.associated_assignee).to be_nil
        end

        it 'has no associated_organization' do
          expect(search_results.value!.first.associated_organization).to be_nil
        end
      end
    end
  end
end
