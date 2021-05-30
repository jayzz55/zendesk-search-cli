# frozen_string_literal: true

require 'generators/database'
require 'services/fetch_schema'
require 'repository'
require 'json'
require 'dry/monads'
require 'dry/monads/do'

class SearchApp
  include Dry::Monads[:try, :result]

  class << self
    include Dry::Monads::Do.for(:init)
    include Dry::Monads[:try, :result]

    def init(user_json:, organization_json:, ticket_json:)
      parsed_user_json = yield parse_json(user_json)
      parsed_organization_json = yield parse_json(organization_json)
      parsed_ticket_json = yield parse_json(ticket_json)

      db = yield Generators::Database.call(
        'users' => parsed_user_json,
        'organizations' => parsed_organization_json,
        'tickets' => parsed_ticket_json
      )

      Success(new(Repository.new(db)))
    end

    private

    def parse_json(json)
      Try[JSON::ParserError] { JSON.parse(json) }.to_result
    end
  end

  attr_reader :repo

  def initialize(repo)
    @repo = repo
  end

  def available_records
    Success(repo.available_records)
  end

  def get_search_terms_for(record:)
    Services::FetchSchema.call(record: record).fmap(&:keys)
  end
end
