# frozen_string_literal: true

require 'models/user'
require 'models/organization'
require 'models/ticket'

require 'dry/monads'

class Repository
  include Dry::Monads[:try, :result]

  attr_reader :database

  def initialize(database)
    @database = database
  end

  def available_records
    Try { database.available_records }.to_result
  end

  def search(record:, search_term:, value:)
    Try do
      case record
        in 'users' | 'organizations' | 'tickets' => matched_record
        method("search_#{matched_record}")
          .call(search_term, value)
          .then { |results| method("search_#{matched_record}_associations").call(results) }
        in
        []
      end
    end.to_result
  end

  private

  def search_users(search_term, value)
    search_records('users')
      .call(search_term, value)
      .map { |record| Models::User.new(record.transform_keys(&:to_sym)) }
  end

  def search_users_associations(users)
    users.map do |user|
      user.with_associations(
        submitted_tickets: search_tickets('submitter_id', user._id),
        assigned_tickets: search_tickets('assignee_id', user._id),
        organization: search_organizations('_id', user.organization_id).first
      )
    end
  end

  def search_organizations(search_term, value)
    search_records('organizations')
      .call(search_term, value)
      .map { |record| Models::Organization.new(record.transform_keys(&:to_sym)) }
  end

  def search_organizations_associations(organizations)
    organizations.map do |organization|
      organization.with_associations(
        tickets: search_tickets('organization_id', organization._id),
        users: search_users('organization_id', organization._id)
      )
    end
  end

  def search_tickets(search_term, value)
    search_records('tickets')
      .call(search_term, value)
      .map { |record| Models::Ticket.new(record.transform_keys(&:to_sym)) }
  end

  def search_tickets_associations(tickets)
    tickets.map do |ticket|
      ticket.with_associations(
        submitter: search_users('_id', ticket.submitter_id).first,
        assignee: search_users('_id', ticket.assignee_id).first,
        organization: search_organizations('_id', ticket.organization_id).first
      )
    end
  end

  def search_records(record)
    lambda do |search_term, value|
      if database.schema.dig(record, search_term, 'primary_key')
        [database.get_record(record: record, key: value)].compact
      else
        search_by_index(record, search_term, value)
      end
    end
  end

  def search_by_index(record, search_term, value)
    database
      .search_index(record: record, paths: [search_term, *value])
      .map { |index| database.get_record(record: record, key: index) }
  end
end
