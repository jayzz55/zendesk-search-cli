# frozen_string_literal: true

require 'services/generate_database'
require 'services/fetch_schema'
require 'validators/search_term'
require 'parsers/search_value'
require 'repository'
require 'json'
require 'dry/monads'
require 'dry/monads/do'
require 'errors/invalid_search_value'

class SearchApp
  include Dry::Monads[:try, :result]
  include Dry::Monads::Do.for(:search_for)

  class << self
    include Dry::Monads::Do.for(:init)
    include Dry::Monads[:try, :result]

    def init(user_json:, organization_json:, ticket_json:)
      parsed_user_json = yield parse_json(user_json)
      parsed_organization_json = yield parse_json(organization_json)
      parsed_ticket_json = yield parse_json(ticket_json)

      db = yield Services::GenerateDatabase.call(
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

  def validate_search_term(record:, search_term:)
    get_search_terms_for(record: record).bind do |search_terms|
      Validators::SearchTerm.call(search_terms: search_terms, value: search_term)
    end
  end

  def search_for(record:, search_term:, value:)
    schema = yield Services::FetchSchema.call(record: record)
    yield Validators::SearchTerm.call(search_terms: schema.keys, value: search_term)
    parsed_value = yield Parsers::SearchValue
                   .call(type: schema.dig(search_term, 'type'), value: value)
                   .to_result(Errors::InvalidSearchValue.new("search value #{value} is invalid"))
    result = repo.search(
      record: record, search_term: search_term, value: parsed_value
    )

    Success(result)
  end
end
